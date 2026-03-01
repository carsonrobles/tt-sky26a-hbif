/*
 * Copyright (c) 2026 Carson Robles
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

  localparam int NUM_LANES = 8;

  wire [NUM_LANES-1:0] tthbif_rx;
  wire [NUM_LANES-1:0] tthbif_tx;

  assign tthbif_rx             = ui_in[NUM_LANES-1:0];
  assign uo_out[NUM_LANES-1:0] = tthbif_tx;

  tthbif_top #(
    .NUM_LANES ( NUM_LANES )
  ) u_tthbif_top (
    .clk_i       ( clk        ),
    .rst_ni      ( rst_n      ),

    .en_i        ( ena        ),

    .uart_rx_i   ( uio_in[3]  ),
    .uart_tx_o   ( uio_out[4] ),

    .tthbif_rx_i ( tthbif_rx  ),
    .tthbif_tx_o ( tthbif_tx  )
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
  assign uio_out[3] = 1'b0;
  assign uio_out[5] = 1'b0;
  assign uio_out[6] = 1'b0;
  assign uio_out[7] = 1'b0;

  wire _unused = ^{
    uio_in[0],
    uio_in[1],
    uio_in[2],
    uio_in[4],
    uio_in[5],
    uio_in[6],
    uio_in[7]
  };

endmodule
