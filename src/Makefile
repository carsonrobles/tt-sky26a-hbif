# -----------------------------------------------------------------------------
# Verilator Lint Makefile (search from current directory only)
# -----------------------------------------------------------------------------

# Find all SV/V sources recursively under the current directory
ALL_SRCS := $(shell find . -type f \( -name "*.sv" -o -name "*.v" \))

# Put package files first (common naming patterns)
PKG_SRCS := $(filter %_pkg.sv %package%.sv,$(ALL_SRCS))

# Exclude testbenches by default (remove this if you want to lint TBs too)
TB_SRCS := $(filter %_tb.sv %_tb.v,$(ALL_SRCS))

# Everything else
NONPKG_SRCS := $(filter-out $(PKG_SRCS) $(TB_SRCS),$(ALL_SRCS))

# Final ordered list
SRCS := $(HOME)/.ciel/ciel/sky130/versions/0fe599b2afb6708d281543108caf8310912f54af/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd__blackbox.v $(PKG_SRCS) $(NONPKG_SRCS)

# -----------------------------------------------------------------------------
# User Configuration
# -----------------------------------------------------------------------------

# Optional top module (uncomment if you want)
# TOP := tthbif_top

# Include directories for `include directives (not module lookup)
INC_DIRS :=
INCLUDES := $(foreach dir,$(INC_DIRS),-I$(dir))

# Optional macro defines
DEFINES :=

# -----------------------------------------------------------------------------
# Verilator Flags
# -----------------------------------------------------------------------------

VERILATOR_FLAGS := \
	--lint-only \
	--sv \
	--language 1800-2012 \
	-Wall \
	-Wno-fatal \
	$(INCLUDES) \
	$(DEFINES)

ifdef TOP
VERILATOR_FLAGS += --top-module $(TOP)
endif

# -----------------------------------------------------------------------------
# Targets
# -----------------------------------------------------------------------------

.PHONY: lint
lint:
	@echo "Running Verilator lint from: $$(pwd)"
	@echo "Found $$(echo "$(SRCS)" | wc -w) source files"
	@echo "Package files:"
	@echo "  $(PKG_SRCS)"
	verilator $(VERILATOR_FLAGS) $(SRCS)

.PHONY: files
files:
	@echo "All sources:"
	@printf '%s\n' $(ALL_SRCS)
	@echo
	@echo "Ordered sources:"
	@printf '%s\n' $(SRCS)

.PHONY: clean
clean:
	rm -rf obj_dir
