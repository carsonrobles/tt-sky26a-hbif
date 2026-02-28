module tthbif (
  input        clk_i,
  input        rst_ni,

  input        en_i,

  input        uart_rx_i,
  output       uart_tx_o
);

  logic       uart_rx_data_valid;
  logic [7:0] uart_rx_data;

  logic       uart_tx_data_ready;
  logic       uart_tx_data_valid;
  logic [7:0] uart_tx_data;

  assign uart_tx_data_valid = uart_rx_data_valid;
  assign uart_tx_data       = uart_rx_data;

  uart #(
    .CLKS_PER_BIT ( 6875 )
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

  wire _unused = uart_tx_data_ready;

endmodule
