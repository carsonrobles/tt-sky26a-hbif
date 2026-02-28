/*
 * Copyright (c) 2024 Carson Robles
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_hbif_carsonrobles (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);


  assign uio_oe[0] = 1'b1;
  assign uio_oe[1] = 1'b1;
  assign uio_oe[2] = 1'b1;
  assign uio_oe[3] = 1'b0;
  assign uio_oe[4] = 1'b1;
  assign uio_oe[5] = 1'b1;
  assign uio_oe[6] = 1'b1;
  assign uio_oe[7] = 1'b1;

  assign uio_out[0] = 1'b0;
  assign uio_out[1] = 1'b0;
  assign uio_out[2] = 1'b0;
  //assign uio_out[3] = 1'b0;
  assign uio_out[4] = 1'b0;
  assign uio_out[5] = 1'b0;
  assign uio_out[6] = 1'b0;
  assign uio_out[7] = 1'b0;

  assign uo_out[0] = 1'b0;
  assign uo_out[1] = 1'b0;
  assign uo_out[2] = 1'b0;
  assign uo_out[3] = 1'b0;
  assign uo_out[4] = 1'b0;
  assign uo_out[5] = 1'b0;
  assign uo_out[6] = 1'b0;
  assign uo_out[7] = 1'b0;

  tthbif u_tthbif (
    .clk_i     ( clk   ),
    .rst_ni    ( rst_n ),

    .en_i      ( ena   ),

    .uart_rx_i ( uio_in[3]  ),
    .uart_tx_o ( uio_out[4] )
  );

endmodule
