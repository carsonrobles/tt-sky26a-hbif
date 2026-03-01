module rf #(
  parameter int DEPTH,
  parameter int DATA_WIDTH
) (
  input                            clk_i,
  input                            rst_ni,

  input                            en_i,
  input                            we_i,
  input        [$clog2(DEPTH)-1:0] addr_i,
  input        [   DATA_WIDTH-1:0] data_i,
  output logic [   DATA_WIDTH-1:0] data_o,

  // TODO: config outputs
  output       [              1:0] rx_comb_tap_sel_o,
  output       [              1:0] rx_flop_tap_sel_o,
  output       [              1:0] tx_comb_tap_sel_o,
  output       [              1:0] tx_flop_tap_sel_o
);

  logic [DEPTH-1:0][DATA_WIDTH-1:0] mem;

  always_ff @(posedge clk_i) begin
    if (~rst_ni) begin
      mem <= '0;
    end else begin
      if (en_i & we_i) begin
        mem[addr_i] <= data_i;
      end
    end
  end

  always_ff @(posedge clk_i) begin
    data_o <= mem[addr_i];
  end

  assign rx_comb_tap_sel_o = mem[0][1:0];
  assign rx_flop_tap_sel_o = mem[0][3:2];
  assign tx_comb_tap_sel_o = mem[1][1:0];
  assign tx_flop_tap_sel_o = mem[1][3:2];

endmodule
