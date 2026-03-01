`default_nettype none

module tthbif_rx_lane (
  input  wire       clk_i,
  input  wire       rst_ni,

  input  wire [1:0] comb_tap_sel_i,
  input  wire [1:0] flop_tap_sel_i,

  input  wire       rx_i,
  output wire       rx_o
);

  localparam int NUM_TAP         = 4;
  localparam int NUM_BUF_PER_TAP = 4;

  wire [NUM_TAP:0] comb_tap;

  assign comb_tap[0] = rx_i;

  for (genvar gi=0; gi<NUM_TAP; gi++) begin: g_tap

    wire [NUM_BUF_PER_TAP:0] comb_tap_local;

    assign comb_tap_local[0] = comb_tap[gi];
    assign comb_tap[gi+1]    = comb_tap_local[NUM_BUF_PER_TAP];

    for (genvar gj=0; gj<NUM_BUF_PER_TAP; gj++) begin: g_inv

      wire inv_local;

      sky130_fd_sc_hd__inv_1 u_inv0_dont_touch (
        .A ( comb_tap_local[gj]   ),
        .Y ( inv_local            )
      );

      sky130_fd_sc_hd__inv_1 u_inv1_dont_touch (
        .A ( inv_local            ),
        .Y ( comb_tap_local[gj+1] )
      );

    end: g_inv

  end: g_tap

  logic [NUM_TAP-1:0] flop_tap;

  always_ff @(posedge clk_i) begin
    if (~rst_ni) begin
      flop_tap <= '0;
    end else begin
      flop_tap[0] <= comb_tap[comb_tap_sel_i];

      for (int i=1; i<NUM_TAP; i++) begin
        flop_tap[i] <= flop_tap[i-1];
      end
    end
  end

  assign rx_o = flop_tap[flop_tap_sel_i];

endmodule
