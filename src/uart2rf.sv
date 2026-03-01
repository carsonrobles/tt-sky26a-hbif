module uart2rf #(
  parameter int RF_ADDR_WIDTH,
  parameter int RF_DATA_WIDTH
) (
  input                      clk_i,
  input                      rst_ni,

  input                      uart_data_valid_i,
  input  [              7:0] uart_data_i,
  output logic               uart_data_valid_o,
  output [              7:0] uart_data_o,

  output                     rf_en_o,
  output                     rf_we_o,
  output [RF_ADDR_WIDTH-1:0] rf_addr_o,
  output [RF_DATA_WIDTH-1:0] rf_data_o,
  input  [RF_DATA_WIDTH-1:0] rf_data_i
);

  assign rf_en_o   = uart_data_valid_i;
  assign rf_we_o   = uart_data_i[7];
  assign rf_addr_o = uart_data_i[6:4];
  assign rf_data_o = uart_data_i[3:0];

  always_ff @(posedge clk_i) begin
    if (~rst_ni)
      uart_data_valid_o <= 1'b0;
    else
      uart_data_valid_o <= uart_data_valid_i;
  end

  assign uart_data_o = {4'b0, rf_data_i};

endmodule
