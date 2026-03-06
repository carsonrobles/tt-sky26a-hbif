module tthbif_top #(
  parameter int NUM_LANES = 1
) (
  input                  clk_i,
  input                  rst_ni,

  input                  en_i,

  input                  uart_rx_i,
  output                 uart_tx_o,

  input  [NUM_LANES-1:0] tthbif_rx_i,
  output [NUM_LANES-1:0] tthbif_tx_o
);

  logic       uart_rx_data_valid;
  logic [7:0] uart_rx_data;

  logic       uart_tx_data_ready;
  logic       uart_tx_data_valid;
  logic [7:0] uart_tx_data;

  // TODO:
  // sync reset
  // sync uart rx

  // probably make this faster baud... less flops for counters
  // also, make the clks per bit configurable, in case the clock is run slower than 66MHz

//`define STUB_UART
`ifdef STUB_UART
  wire _uart_unused = uart_rx_i;
  assign uart_tx_o = 1'b0;
`else
  uart #(
    .CLKS_PER_BIT ( 578 ) // CLK=66.667MHz BAUD=115200
  ) u_uart (
    .clk_i           ( clk_i              ),
    .rst_ni          ( rst_ni             ),
  
    .en_i            ( en_i               ),
  
    .rx_data_valid_o ( uart_rx_data_valid ),
    .rx_data_o       ( uart_rx_data       ),
  
    .tx_data_ready_o ( uart_tx_data_ready ),
    .tx_data_valid_i ( uart_tx_data_valid ),
    .tx_data_i       ( uart_tx_data       ),
  
    .rx_i            ( uart_rx_i          ),
    .tx_o            ( uart_tx_o          )
  );
`endif

  localparam int RF_ADDR_WIDTH = 5;
  localparam int RF_DATA_WIDTH = 4;

  wire                     rf_en;
  wire                     rf_we;
  wire [RF_ADDR_WIDTH-1:0] rf_addr;
  wire [RF_DATA_WIDTH-1:0] rf_wdata;
  wire [RF_DATA_WIDTH-1:0] rf_rdata;

  uart2rf #(
    .RF_ADDR_WIDTH ( RF_ADDR_WIDTH ),
    .RF_DATA_WIDTH ( RF_DATA_WIDTH )
  ) u_uart2rf (
    .clk_i             ( clk_i              ),
    .rst_ni            ( rst_ni             ),

    .uart_data_valid_i ( uart_rx_data_valid ),
    .uart_data_i       ( uart_rx_data       ),
    .uart_data_valid_o ( uart_tx_data_valid ),
    .uart_data_o       ( uart_tx_data       ),

    .rf_en_o           ( rf_en              ),
    .rf_we_o           ( rf_we              ),
    .rf_addr_o         ( rf_addr            ),
    .rf_data_o         ( rf_wdata           ),
    .rf_data_i         ( rf_rdata           )
  );

  rf_pkg::hw_in_t  rf_in;
  rf_pkg::hw_out_t rf_out;

  assign rf_in = '0;

  rf u_rf (
    .clk_i    ( clk_i    ),
    .rst_ni   ( rst_ni   ),

    .en_i     ( rf_en    ),
    .we_i     ( rf_we    ),
    .addr_i   ( rf_addr  ),
    .data_i   ( rf_wdata ),
    .data_o   ( rf_rdata ),

    .hw_in_i  ( rf_in    ),
    .hw_out_o ( rf_out   )
  );

  wire [NUM_LANES-1:0]      rx_lane_en;
  wire [NUM_LANES-1:0]      tx_lane_en;

  wire [NUM_LANES-1:0][1:0] rx_comb_tap_sel;
  wire [NUM_LANES-1:0]      rx_flop_tap_sel;
  wire [NUM_LANES-1:0][1:0] tx_comb_tap_sel;
  wire [NUM_LANES-1:0]      tx_flop_tap_sel;

  assign rx_lane_en[0]      = rf_out.RX0_CFG1.enable;
  assign rx_lane_en[1]      = rf_out.RX1_CFG1.enable;
  assign rx_lane_en[2]      = rf_out.RX2_CFG1.enable;
  assign rx_lane_en[3]      = rf_out.RX3_CFG1.enable;

  assign tx_lane_en[0]      = rf_out.TX0_CFG1.enable;
  assign tx_lane_en[1]      = rf_out.TX1_CFG1.enable;
  assign tx_lane_en[2]      = rf_out.TX2_CFG1.enable;
  assign tx_lane_en[3]      = rf_out.TX3_CFG1.enable;

  assign rx_comb_tap_sel[0] = rf_out.RX0_CFG0.p_comb_tap_sel;
  assign rx_flop_tap_sel[0] = rf_out.RX0_CFG1.p_flop_tap_sel;
  assign rx_comb_tap_sel[1] = rf_out.RX1_CFG0.p_comb_tap_sel;
  assign rx_flop_tap_sel[1] = rf_out.RX1_CFG1.p_flop_tap_sel;
  assign rx_comb_tap_sel[2] = rf_out.RX2_CFG0.p_comb_tap_sel;
  assign rx_flop_tap_sel[2] = rf_out.RX2_CFG1.p_flop_tap_sel;
  assign rx_comb_tap_sel[3] = rf_out.RX3_CFG0.p_comb_tap_sel;
  assign rx_flop_tap_sel[3] = rf_out.RX3_CFG1.p_flop_tap_sel;

  assign tx_comb_tap_sel[0] = rf_out.TX0_CFG0.p_comb_tap_sel;
  assign tx_flop_tap_sel[0] = rf_out.TX0_CFG1.p_flop_tap_sel;
  assign tx_comb_tap_sel[1] = rf_out.TX1_CFG0.p_comb_tap_sel;
  assign tx_flop_tap_sel[1] = rf_out.TX1_CFG1.p_flop_tap_sel;
  assign tx_comb_tap_sel[2] = rf_out.TX2_CFG0.p_comb_tap_sel;
  assign tx_flop_tap_sel[2] = rf_out.TX2_CFG1.p_flop_tap_sel;
  assign tx_comb_tap_sel[3] = rf_out.TX3_CFG0.p_comb_tap_sel;
  assign tx_flop_tap_sel[3] = rf_out.TX3_CFG1.p_flop_tap_sel;

  wire [NUM_LANES-1:0] tthbif_rx;
  wire [NUM_LANES-1:0] tthbif_tx;

  tthbif #(
    .NUM_LANES            ( NUM_LANES ),
  
    .NUM_FLOP_TAP         ( 2         ),
    .NUM_COMB_TAP         ( 4         ),
    .NUM_BUF_PER_COMB_TAP ( 4         )
  ) u_tthbif (
    .clk_i             ( clk_i             ),
    .rst_ni            ( rst_ni            ),
  
    .en_i              ( en_i              ),

    .rx_lane_en_i      ( rx_lane_en        ),
    .tx_lane_en_i      ( tx_lane_en        ),
  
    .rx_comb_tap_sel_i ( rx_comb_tap_sel   ),
    .rx_flop_tap_sel_i ( rx_flop_tap_sel   ),
    .tx_comb_tap_sel_i ( tx_comb_tap_sel   ),
    .tx_flop_tap_sel_i ( tx_flop_tap_sel   ),
  
    .rx_i              ( tthbif_rx_i       ),
    .tx_o              ( tthbif_tx_o       ),

    .rx_o              ( tthbif_rx         ),
    .tx_i              ( tthbif_tx         )
  );

  // loop back
  assign tthbif_tx = tthbif_rx;

endmodule
