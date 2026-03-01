module tthbif #(
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
`define STUB_UART
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

  // TODO: hook up UART to small RF

  wire [NUM_LANES-1:0] tthbif_rx;
  wire [NUM_LANES-1:0] tthbif_tx;

  for (genvar gi=0; gi<NUM_LANES; gi++) begin: g_lanes

    tthbif_rx_lane u_rx_lane (
      .clk_i          ( clk_i           ),
      .rst_ni         ( rst_ni          ),
    
      .comb_tap_sel_i ( 2'b11           ), // TODO: RF
      .flop_tap_sel_i ( 2'b11           ), // TODO: RF
    
      .rx_i           ( tthbif_rx_i[gi] ),
      .rx_o           ( tthbif_rx[gi]   )
    );

    tthbif_tx_lane u_tx_lane (
      .clk_i          ( clk_i           ),
      .rst_ni         ( rst_ni          ),
    
      .comb_tap_sel_i ( 2'b11           ), // TODO: RF
      .flop_tap_sel_i ( 2'b11           ), // TODO: RF
    
      .tx_i           ( tthbif_tx[gi]   ),
      .tx_o           ( tthbif_tx_o[gi] )
    );

    // loop back for now
    assign tthbif_tx[gi] = tthbif_rx[gi];

  end: g_lanes

  wire _unused = uart_tx_data_ready;

endmodule
