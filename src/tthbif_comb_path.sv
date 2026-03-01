`default_nettype none

module tthbif_comb_path #(
  parameter int NUM_TAP,
  parameter int NUM_BUF_PER_TAP
) (
  input  wire [$clog2(NUM_TAP)-1:0] tap_sel_i,

  input  wire                       sig_i,
  output wire                       sig_o
);

  wire [NUM_TAP:0] tap;

  assign tap[0] = sig_i;

  for (genvar gi=0; gi<NUM_TAP; gi++) begin: g_tap

    wire [NUM_BUF_PER_TAP:0] tap_local;

    assign tap_local[0] = tap[gi];
    assign tap[gi+1]    = tap_local[NUM_BUF_PER_TAP];

    for (genvar gj=0; gj<NUM_BUF_PER_TAP; gj++) begin: g_inv

`ifdef SIMULATION
      assign tap_local[gj+1] = tap_local[gj];
`else
      wire inv_local;

      sky130_fd_sc_hd__inv_1 u_inv0_dont_touch (
        .A ( tap_local[gj]   ),
        .Y ( inv_local       )
      );

      sky130_fd_sc_hd__inv_1 u_inv1_dont_touch (
        .A ( inv_local       ),
        .Y ( tap_local[gj+1] )
      );
`endif

    end: g_inv

  end: g_tap

  assign sig_o = tap[tap_sel_i];

endmodule
