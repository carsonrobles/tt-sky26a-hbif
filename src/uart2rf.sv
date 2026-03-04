module uart2rf #(
  parameter int RF_ADDR_WIDTH,
  parameter int RF_DATA_WIDTH
) (
  input                            clk_i,
  input                            rst_ni,

  input                            uart_data_valid_i,
  input        [              7:0] uart_data_i,
  output logic                     uart_data_valid_o,
  output       [              7:0] uart_data_o,

  output                           rf_en_o,
  output logic                     rf_we_o,
  output logic [RF_ADDR_WIDTH-1:0] rf_addr_o,
  output       [RF_DATA_WIDTH-1:0] rf_data_o,
  input        [RF_DATA_WIDTH-1:0] rf_data_i
);

  typedef enum {
    IDLE,
    EMIT
  } state_t;

  state_t fsm;
  state_t fsm_d;

  always_ff @(posedge clk_i) begin
    if (~rst_ni)
      fsm <= IDLE;
    else
      fsm <= fsm_d;
  end

  always_comb begin
    case (fsm)
      IDLE:
        if (uart_data_valid_i)
          fsm_d = EMIT;
        else
          fsm_d = IDLE;
      EMIT:
        if (uart_data_valid_i)
          fsm_d = IDLE;
        else
          fsm_d = EMIT;
      default:
        fsm_d = IDLE;
    endcase
  end

  assign rf_en_o   = uart_data_valid_i & (fsm == EMIT);
  assign rf_data_o = uart_data_i[3:0];

  always_ff @(posedge clk_i) begin
    if (uart_data_valid_i & (fsm == IDLE)) begin
      rf_we_o   <= uart_data_i[7];
      rf_addr_o <= uart_data_i[6:0];
    end
  end

  always_ff @(posedge clk_i) begin
    if (~rst_ni)
      uart_data_valid_o <= 1'b0;
    else
      uart_data_valid_o <= rf_en_o;
  end

  assign uart_data_o = {4'b0, rf_data_i};

endmodule
