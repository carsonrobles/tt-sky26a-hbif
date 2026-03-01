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

  assign uart_tx_data_valid = uart_rx_data_valid;
  assign uart_tx_data       = uart_rx_data;

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
    .CLKS_PER_BIT ( 6875 ) // CLK=66.667MHz BAUD=9600
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

  tthbif #(
    .NUM_LANES            ( 1 ),
  
    .NUM_FLOP_TAP         ( 4 ),
    .NUM_COMB_TAP         ( 4 ),
    .NUM_BUF_PER_COMB_TAP ( 4 )
  ) u_tthbif (
    .clk_i             ( clk_i       ),
    .rst_ni            ( rst_ni      ),
  
    .en_i              ( en_i        ),
  
    .rx_flop_tap_sel_i ( 2'b11       ), // TODO: RF
    .rx_comb_tap_sel_i ( 2'b11       ), // TODO: RF
    .tx_flop_tap_sel_i ( 2'b11       ), // TODO: RF
    .tx_comb_tap_sel_i ( 2'b11       ), // TODO: RF
  
    .rx_i              ( tthbif_rx_i ),
    .tx_o              ( tthbif_tx_o )
  );

endmodule
