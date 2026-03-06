#!/usr/bin/env python3
# regfile_gen.py
#
# Generates two SystemVerilog files from a CSV memory map:
#   <module>_pkg.sv  : packed typedefs (per-reg structs + hw_in_t/hw_out_t)
#   <module>.sv      : regfile module using explicit package references (<pkg>::type)
#
# CSV format:
#   Address,Name,SW Access,HW Access,Reset Value,Reg[N],Reg[N-1],...,Reg[0]
#
# Rules:
# - Register width is inferred from the Reg[x] columns (must be contiguous).
# - Duplicate Name or Address is an error (also error if two names sanitize to same SV identifier).
# - "Merged cells" behavior:
#     a non-empty cell starts a field; subsequent blank cells extend that field
#     until the next non-empty cell (or end).
#   Example (4b):
#     Reg[3]=error_count, Reg[2]=, Reg[1]=, Reg[0]=  --> logic [3:0] error_count;
#     Reg[1]=p_sel, Reg[0]=                           --> logic [1:0] p_sel;
# - Reset Value is REQUIRED.
# - Port naming:
#     inputs end with _i, outputs end with _o
#     clk_i, rst_ni
# - SW interface names:
#     en_i, we_i, addr_i, data_i, data_o
# - HW interface:
#     single struct input  : <pkg>::hw_in_t  hw_in_i
#     single struct output : <pkg>::hw_out_t hw_out_o
#   hw_in_t contains, per HW-writable register:
#     logic <REG>_we;
#     <REG>_t <REG>;
#   hw_out_t contains, per HW-readable register:
#     <REG>_t <REG>;

from __future__ import annotations

import argparse
import csv
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import List, Tuple


@dataclass(frozen=True)
class Access:
    r: bool
    w: bool


@dataclass(frozen=True)
class Reg:
    addr: int
    name: str
    ident: str
    sw: Access
    hw: Access
    # ordered MSB -> LSB, one entry per bit column
    bit_cells: List[str]
    width: int
    reset: int


# -----------------------------
# Parsing helpers
# -----------------------------

def parse_access(val: str) -> Access:
    v = (val or "").strip().upper()
    return Access(r=("R" in v), w=("W" in v))


def parse_reset_value(val: str, width: int, reg_name: str) -> int:
    v = (val or "").strip()
    if not v:
        raise RuntimeError(f"Register '{reg_name}': Reset Value cannot be empty")

    # Support:
    #   0
    #   15
    #   0xF
    #   0b1010
    #   4'hA
    #   8'd3
    #   4'b0011
    sv_lit = re.fullmatch(r"(?i)(\d+)'([bdh])([0-9a-f_xz?]+)", v)
    if sv_lit:
        lit_width = int(sv_lit.group(1))
        base_ch = sv_lit.group(2).lower()
        digits = sv_lit.group(3).replace("_", "")
        if any(ch in digits.lower() for ch in ("x", "z", "?")):
            raise RuntimeError(
                f"Register '{reg_name}': Reset Value '{v}' contains x/z/? which is not supported"
            )
        base = {"b": 2, "d": 10, "h": 16}[base_ch]
        try:
            parsed = int(digits, base)
        except ValueError as e:
            raise RuntimeError(
                f"Register '{reg_name}': invalid Reset Value '{v}'"
            ) from e

        if lit_width > width:
            raise RuntimeError(
                f"Register '{reg_name}': Reset Value '{v}' width ({lit_width}) "
                f"exceeds register width ({width})"
            )
        if parsed >= (1 << width):
            raise RuntimeError(
                f"Register '{reg_name}': Reset Value '{v}' does not fit in {width} bits"
            )
        return parsed

    try:
        parsed = int(v, 0)
    except ValueError as e:
        raise RuntimeError(
            f"Register '{reg_name}': invalid Reset Value '{v}'"
        ) from e

    if parsed < 0:
        raise RuntimeError(
            f"Register '{reg_name}': negative Reset Value '{v}' is not supported"
        )
    if parsed >= (1 << width):
        raise RuntimeError(
            f"Register '{reg_name}': Reset Value '{v}' does not fit in {width} bits"
        )
    return parsed


def sanitize_ident(name: str) -> str:
    """Sanitize a register name into a legal SystemVerilog identifier."""
    s = re.sub(r"[^A-Za-z0-9_]", "_", name.strip())
    s = re.sub(r"_+", "_", s).strip("_")
    if not s:
        s = "unnamed"
    if not (s[0].isalpha() or s[0] == "_"):
        s = "_" + s
    return s


def sanitize_field_name(name: str) -> str:
    """Sanitize a field label into a legal SystemVerilog identifier."""
    s = (name or "").strip().lower()
    s = s.replace("/", "_")
    s = s.replace("-", "_")
    s = s.replace(" ", "_")
    s = re.sub(r"[^a-zA-Z0-9_]", "", s)
    s = re.sub(r"_+", "_", s).strip("_")
    if not s:
        s = "reserved"
    if not (s[0].isalpha() or s[0] == "_"):
        s = "f_" + s
    return s


def detect_reg_columns(headers: List[str]) -> List[Tuple[int, str]]:
    """
    Return list of (bit_index, column_name) sorted MSB->LSB.
    Requires contiguous bits.
    """
    reg_cols: List[Tuple[int, str]] = []
    for h in headers:
        m = re.fullmatch(r"Reg\[(\d+)\]", h.strip())
        if m:
            reg_cols.append((int(m.group(1)), h))

    if not reg_cols:
        raise RuntimeError("No Reg[x] columns found in CSV header")

    reg_cols.sort(reverse=True)  # MSB -> LSB

    bits = [b for b, _ in reg_cols]
    expected = list(range(max(bits), min(bits) - 1, -1))
    if bits != expected:
        raise RuntimeError(
            f"Reg columns must be contiguous. Found bits {bits}, expected {expected}"
        )
    return reg_cols


def load_csv(path: Path) -> Tuple[List[Reg], int]:
    with path.open("r", encoding="utf-8-sig", newline="") as f:
        reader = csv.DictReader(f)
        if not reader.fieldnames:
            raise RuntimeError("CSV is missing a header row")

        required = ["Address", "Name", "SW Access", "HW Access", "Reset Value"]
        for col in required:
            if col not in reader.fieldnames:
                raise RuntimeError(f"Missing required column: {col}")

        reg_cols = detect_reg_columns(reader.fieldnames)
        width = len(reg_cols)

        regs: List[Reg] = []
        seen_names = {}
        seen_addrs = {}
        seen_idents = {}

        for line_num, row in enumerate(reader, start=2):
            raw_addr = (row.get("Address") or "").strip()
            raw_name = (row.get("Name") or "").strip()
            raw_sw = (row.get("SW Access") or "").strip()
            raw_hw = (row.get("HW Access") or "").strip()
            raw_reset = (row.get("Reset Value") or "").strip()

            # allow totally blank-ish lines
            if not raw_addr and not raw_name and not raw_sw and not raw_hw and not raw_reset:
                continue

            if not raw_addr:
                raise RuntimeError(f"Line {line_num}: missing Address")
            if not raw_name:
                raise RuntimeError(f"Line {line_num}: missing Name")
            if not raw_reset:
                raise RuntimeError(f"Line {line_num}: missing Reset Value")

            try:
                addr = int(raw_addr, 0)
            except ValueError as e:
                raise RuntimeError(f"Line {line_num}: invalid Address '{raw_addr}'") from e

            if raw_name in seen_names:
                raise RuntimeError(
                    f"Line {line_num}: duplicate Name '{raw_name}' "
                    f"(first seen on line {seen_names[raw_name]})"
                )
            if addr in seen_addrs:
                raise RuntimeError(
                    f"Line {line_num}: duplicate Address {addr} "
                    f"(first seen on line {seen_addrs[addr]})"
                )

            ident = sanitize_ident(raw_name)
            if ident in seen_idents and seen_idents[ident] != raw_name:
                raise RuntimeError(
                    f"Line {line_num}: Name '{raw_name}' sanitizes to '{ident}', "
                    f"which collides with '{seen_idents[ident]}'"
                )

            sw = parse_access(raw_sw)
            hw = parse_access(raw_hw)
            reset = parse_reset_value(raw_reset, width, raw_name)

            bit_cells = [(row.get(col_name) or "").strip() for _, col_name in reg_cols]

            regs.append(
                Reg(
                    addr=addr,
                    name=raw_name,
                    ident=ident,
                    sw=sw,
                    hw=hw,
                    bit_cells=bit_cells,
                    width=width,
                    reset=reset,
                )
            )

            seen_names[raw_name] = line_num
            seen_addrs[addr] = line_num
            seen_idents[ident] = raw_name

    regs.sort(key=lambda r: r.addr)
    return regs, width


# -----------------------------
# Field packing (merged-cell interpretation)
# -----------------------------

def build_struct_fields(reg: Reg) -> List[Tuple[int, int, str]]:
    """
    Interpret merged cells:
      - non-empty starts a new field at that bit
      - blanks extend the current field
      - blanks before any field become reserved bits (singletons)
    Returns list of (msb, lsb, field_name) MSB->LSB.
    """
    result: List[Tuple[int, int, str]] = []
    reserved_count = 0

    current_name: str | None = None
    current_msb: int | None = None
    current_lsb: int | None = None

    for idx, raw in enumerate(reg.bit_cells):
        bit = reg.width - 1 - idx

        if raw.strip():
            # start new field
            if current_name is not None:
                result.append((current_msb, current_lsb, current_name))
            current_name = sanitize_field_name(raw)
            current_msb = bit
            current_lsb = bit
        else:
            # extend current field, or create singleton reserved if none active
            if current_name is not None:
                current_lsb = bit
            else:
                reserved_count += 1
                result.append((bit, bit, f"reserved_{reserved_count}"))

    if current_name is not None:
        result.append((current_msb, current_lsb, current_name))

    # Ensure unique field names within the struct (in case CSV repeats names in separate regions)
    used = set()
    unique_result: List[Tuple[int, int, str]] = []
    for msb, lsb, nm in result:
        base = nm
        if base not in used:
            used.add(base)
            unique_result.append((msb, lsb, base))
        else:
            k = 2
            while f"{base}_{k}" in used:
                k += 1
            nm2 = f"{base}_{k}"
            used.add(nm2)
            unique_result.append((msb, lsb, nm2))

    return unique_result


def emit_reg_typedef(reg: Reg) -> List[str]:
    lines: List[str] = []
    lines.append("typedef struct packed {")
    for msb, lsb, field_name in build_struct_fields(reg):
        w = msb - lsb + 1
        if w == 1:
            lines.append(f"  logic        {field_name};")
        else:
            lines.append(f"  logic [{w-1}:0] {field_name};")
    lines.append(f"}} {reg.ident}_t;")
    return lines


# -----------------------------
# SV generation
# -----------------------------

def generate_pkg(module: str, regs: List[Reg], width: int) -> str:
    pkg_name = f"{module}_pkg"
    out: List[str] = []

    out.append("// -----------------------------------------------------------------------------")
    out.append("// Auto-generated package: typed register structs and HW interface structs")
    out.append("// -----------------------------------------------------------------------------")
    out.append(f"package {pkg_name};")
    out.append("")

    # Per-register typed structs
    for r in regs:
        out.extend(emit_reg_typedef(r))
        out.append("")

    # HW input struct: <REG>_we + <REG>_t <REG>
    out.append("typedef struct packed {")
    for r in regs:
        if r.hw.w:
            out.append(f"  logic       {r.ident}_we;")
            out.append(f"  {r.ident}_t {r.ident};")
    out.append("} hw_in_t;")
    out.append("")

    # HW output struct: <REG>_t <REG>
    out.append("typedef struct packed {")
    for r in regs:
        if r.hw.r:
            out.append(f"  {r.ident}_t {r.ident};")
    out.append("} hw_out_t;")
    out.append("")

    out.append(f"endpackage : {pkg_name}")
    out.append("")
    return "\n".join(out)


def generate_module(module: str, regs: List[Reg], width: int, addr_bits: int) -> str:
    pkg = f"{module}_pkg"
    out: List[str] = []

    out.append("// -----------------------------------------------------------------------------")
    out.append("// Auto-generated SystemVerilog register file")
    out.append("// -----------------------------------------------------------------------------")
    out.append("")
    out.append(f"module {module} (")
    out.append("  input  logic                 clk_i,")
    out.append("  input  logic                 rst_ni,")
    out.append("")
    out.append("  input  logic                 en_i,")
    out.append("  input  logic                 we_i,")
    out.append(f"  input  logic [{addr_bits-1}:0]           addr_i,")
    out.append(f"  input  logic [{width-1}:0]           data_i,")
    out.append(f"  output logic [{width-1}:0]           data_o,")
    out.append("")
    out.append(f"  input  {pkg}::hw_in_t        hw_in_i,")
    out.append(f"  output {pkg}::hw_out_t       hw_out_o")
    out.append(");")
    out.append("")

    # Raw storage for each register
    out.append("  // Raw register storage")
    for r in regs:
        out.append(f"  logic [{width-1}:0] {r.ident}_q;")
    out.append("")

    # HW typed outputs: cast raw bits into the per-reg struct type
    out.append("  // HW typed outputs")
    for r in regs:
        if r.hw.r:
            out.append(f"  assign hw_out_o.{r.ident} = {pkg}::{r.ident}_t'({r.ident}_q);")
    out.append("")

    # Sequential write logic
    out.append("  // Sequential write logic")
    out.append("  // - HW writes have priority over SW writes per register")
    out.append("  // - HW writes are independent, so multiple registers can update in one cycle")
    out.append("  always_ff @(posedge clk_i) begin")
    out.append("    if (~rst_ni) begin")
    for r in regs:
        out.append(f"      {r.ident}_q <= {width}'d{r.reset};")
    out.append("    end else begin")

    for r in regs:
        if r.hw.w:
            out.append(f"      if (hw_in_i.{r.ident}_we) begin")
            # Cast struct to vector via size-cast; packed structs are integral.
            out.append(f"        {r.ident}_q <= {width}'(hw_in_i.{r.ident});")
            out.append("      end else begin")
            if r.sw.w:
                out.append(f"        if (en_i && we_i && (addr_i == {addr_bits}'d{r.addr})) begin")
                out.append(f"          {r.ident}_q <= data_i;")
                out.append("        end")
            out.append("      end")
        elif r.sw.w:
            out.append(f"      if (en_i && we_i && (addr_i == {addr_bits}'d{r.addr})) begin")
            out.append(f"        {r.ident}_q <= data_i;")
            out.append("      end")

    out.append("    end")
    out.append("  end")
    out.append("")

    # SW read mux - preserved as flopped output
    out.append("  // SW read mux")
    out.append("  always_ff @(posedge clk_i) begin")
    out.append("    if (en_i) begin")
    out.append("      unique case (addr_i)")
    for r in regs:
        if r.sw.r:
            out.append(f"        {addr_bits}'d{r.addr}: data_o <= {r.ident}_q;")
    out.append(f"        default: data_o <= {width}'d0;")
    out.append("      endcase")
    out.append("    end")
    out.append("  end")
    out.append("")
    out.append(f"endmodule : {module}")
    out.append("")
    return "\n".join(out)


# -----------------------------
# CLI
# -----------------------------

def main() -> int:
    ap = argparse.ArgumentParser(
        description="Generate <module>.sv and <module>_pkg.sv from a CSV memory map."
    )
    ap.add_argument("csv", type=Path, help="Input CSV file")
    ap.add_argument("--module", required=True, help="Module name (required)")
    ap.add_argument("--addr-bits", type=int, default=8, help="Address bus width for addr_i")
    ap.add_argument("--outdir", default=".", help="Output directory")
    args = ap.parse_args()

    try:
        regs, width = load_csv(args.csv)

        outdir = Path(args.outdir)
        outdir.mkdir(parents=True, exist_ok=True)

        pkg_text = generate_pkg(args.module, regs, width)
        mod_text = generate_module(args.module, regs, width, args.addr_bits)

        pkg_path = outdir / f"{args.module}_pkg.sv"
        mod_path = outdir / f"{args.module}.sv"

        pkg_path.write_text(pkg_text, encoding="utf-8")
        mod_path.write_text(mod_text, encoding="utf-8")

        print(f"Wrote {pkg_path}")
        print(f"Wrote {mod_path}")
        return 0

    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
