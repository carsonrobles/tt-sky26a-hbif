`default_nettype none

module tthbif_flop_path #(
  parameter int NUM_TAP
) (
  input  wire                       clk_i,
  input  wire                       rst_ni,

  input  wire [$clog2(NUM_TAP)-1:0] tap_sel_i,

  input  wire                       sig_i,
  output wire                       sig_o
);

  logic [NUM_TAP-1:0] tap;

  always_ff @(posedge clk_i) begin
    if (~rst_ni) begin
      tap <= '0;
    end else begin
      tap[0] <= sig_i;

      for (int i=1; i<NUM_TAP; i++) begin
        tap[i] <= tap[i-1];
      end
    end
  end

  assign sig_o = tap[tap_sel_i];

endmodule
