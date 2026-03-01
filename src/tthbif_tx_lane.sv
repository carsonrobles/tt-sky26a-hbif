`default_nettype none

module tthbif_tx_lane (
  input  wire       clk_i,
  input  wire       rst_ni,

  input  wire [1:0] comb_tap_sel_i,
  input  wire [1:0] flop_tap_sel_i,

  input  wire       tx_i,
  output wire       tx_o
);

  localparam int NUM_TAP         = 4;
  localparam int NUM_BUF_PER_TAP = 4;

  wire tx_flop;

  tthbif_flop_path #(
    .NUM_TAP ( NUM_TAP )
  ) u_tthbif_flop_path (
    .clk_i     ( clk_i          ),
    .rst_ni    ( rst_ni         ),
  
    .tap_sel_i ( flop_tap_sel_i ),
  
    .sig_i     ( tx_i           ),
    .sig_o     ( tx_flop        )
  );

  tthbif_comb_path #(
    .NUM_TAP         ( NUM_TAP         ),
    .NUM_BUF_PER_TAP ( NUM_BUF_PER_TAP )
  ) u_tthbif_comb_path (
    .tap_sel_i ( comb_tap_sel_i ),
  
    .sig_i     ( tx_flop        ),
    .sig_o     ( tx_o           )
  );

endmodule
