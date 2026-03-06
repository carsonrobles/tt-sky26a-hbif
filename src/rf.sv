// -----------------------------------------------------------------------------
// Auto-generated SystemVerilog register file
// -----------------------------------------------------------------------------

module rf (
  input  logic                 clk_i,
  input  logic                 rst_ni,

  input  logic                 en_i,
  input  logic                 we_i,
  input  logic [4:0]           addr_i,
  input  logic [3:0]           data_i,
  output logic [3:0]           data_o,

  input  rf_pkg::hw_in_t        hw_in_i,
  output rf_pkg::hw_out_t       hw_out_o
);

  // Raw register storage
  logic [3:0] RX0_CFG0_q;
  logic [3:0] RX0_CFG1_q;
  logic [3:0] RX1_CFG0_q;
  logic [3:0] RX1_CFG1_q;
  logic [3:0] RX2_CFG0_q;
  logic [3:0] RX2_CFG1_q;
  logic [3:0] RX3_CFG0_q;
  logic [3:0] RX3_CFG1_q;
  logic [3:0] TX0_CFG0_q;
  logic [3:0] TX0_CFG1_q;
  logic [3:0] TX1_CFG0_q;
  logic [3:0] TX1_CFG1_q;
  logic [3:0] TX2_CFG0_q;
  logic [3:0] TX2_CFG1_q;
  logic [3:0] TX3_CFG0_q;
  logic [3:0] TX3_CFG1_q;
  logic [3:0] IF_CFG0_q;
  logic [3:0] TEST_CFG0_q;
  logic [3:0] TEST_CFG1_q;
  logic [3:0] TEST_CFG2_q;
  logic [3:0] TEST_CFG3_q;
  logic [3:0] TEST_RES0_q;
  logic [3:0] TEST_RES1_q;
  logic [3:0] TEST_RES2_q;
  logic [3:0] TEST_RES3_q;
  logic [3:0] TEST_RES4_q;

  // HW typed outputs
  assign hw_out_o.RX0_CFG0 = rf_pkg::RX0_CFG0_t'(RX0_CFG0_q);
  assign hw_out_o.RX0_CFG1 = rf_pkg::RX0_CFG1_t'(RX0_CFG1_q);
  assign hw_out_o.RX1_CFG0 = rf_pkg::RX1_CFG0_t'(RX1_CFG0_q);
  assign hw_out_o.RX1_CFG1 = rf_pkg::RX1_CFG1_t'(RX1_CFG1_q);
  assign hw_out_o.RX2_CFG0 = rf_pkg::RX2_CFG0_t'(RX2_CFG0_q);
  assign hw_out_o.RX2_CFG1 = rf_pkg::RX2_CFG1_t'(RX2_CFG1_q);
  assign hw_out_o.RX3_CFG0 = rf_pkg::RX3_CFG0_t'(RX3_CFG0_q);
  assign hw_out_o.RX3_CFG1 = rf_pkg::RX3_CFG1_t'(RX3_CFG1_q);
  assign hw_out_o.TX0_CFG0 = rf_pkg::TX0_CFG0_t'(TX0_CFG0_q);
  assign hw_out_o.TX0_CFG1 = rf_pkg::TX0_CFG1_t'(TX0_CFG1_q);
  assign hw_out_o.TX1_CFG0 = rf_pkg::TX1_CFG0_t'(TX1_CFG0_q);
  assign hw_out_o.TX1_CFG1 = rf_pkg::TX1_CFG1_t'(TX1_CFG1_q);
  assign hw_out_o.TX2_CFG0 = rf_pkg::TX2_CFG0_t'(TX2_CFG0_q);
  assign hw_out_o.TX2_CFG1 = rf_pkg::TX2_CFG1_t'(TX2_CFG1_q);
  assign hw_out_o.TX3_CFG0 = rf_pkg::TX3_CFG0_t'(TX3_CFG0_q);
  assign hw_out_o.TX3_CFG1 = rf_pkg::TX3_CFG1_t'(TX3_CFG1_q);
  assign hw_out_o.IF_CFG0 = rf_pkg::IF_CFG0_t'(IF_CFG0_q);
  assign hw_out_o.TEST_CFG0 = rf_pkg::TEST_CFG0_t'(TEST_CFG0_q);
  assign hw_out_o.TEST_CFG1 = rf_pkg::TEST_CFG1_t'(TEST_CFG1_q);
  assign hw_out_o.TEST_CFG2 = rf_pkg::TEST_CFG2_t'(TEST_CFG2_q);
  assign hw_out_o.TEST_CFG3 = rf_pkg::TEST_CFG3_t'(TEST_CFG3_q);
  assign hw_out_o.TEST_RES0 = rf_pkg::TEST_RES0_t'(TEST_RES0_q);
  assign hw_out_o.TEST_RES1 = rf_pkg::TEST_RES1_t'(TEST_RES1_q);
  assign hw_out_o.TEST_RES2 = rf_pkg::TEST_RES2_t'(TEST_RES2_q);
  assign hw_out_o.TEST_RES3 = rf_pkg::TEST_RES3_t'(TEST_RES3_q);
  assign hw_out_o.TEST_RES4 = rf_pkg::TEST_RES4_t'(TEST_RES4_q);

  // Sequential write logic
  // - HW writes have priority over SW writes per register
  // - HW writes are independent, so multiple registers can update in one cycle
  always_ff @(posedge clk_i) begin
    if (~rst_ni) begin
      RX0_CFG0_q <= 4'd0;
      RX0_CFG1_q <= 4'd0;
      RX1_CFG0_q <= 4'd0;
      RX1_CFG1_q <= 4'd0;
      RX2_CFG0_q <= 4'd0;
      RX2_CFG1_q <= 4'd0;
      RX3_CFG0_q <= 4'd0;
      RX3_CFG1_q <= 4'd0;
      TX0_CFG0_q <= 4'd0;
      TX0_CFG1_q <= 4'd0;
      TX1_CFG0_q <= 4'd0;
      TX1_CFG1_q <= 4'd0;
      TX2_CFG0_q <= 4'd0;
      TX2_CFG1_q <= 4'd0;
      TX3_CFG0_q <= 4'd0;
      TX3_CFG1_q <= 4'd0;
      IF_CFG0_q <= 4'd0;
      TEST_CFG0_q <= 4'd0;
      TEST_CFG1_q <= 4'd0;
      TEST_CFG2_q <= 4'd0;
      TEST_CFG3_q <= 4'd0;
      TEST_RES0_q <= 4'd0;
      TEST_RES1_q <= 4'd0;
      TEST_RES2_q <= 4'd0;
      TEST_RES3_q <= 4'd0;
      TEST_RES4_q <= 4'd0;
    end else begin
      if (en_i && we_i && (addr_i == 5'd0)) begin
        RX0_CFG0_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd1)) begin
        RX0_CFG1_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd2)) begin
        RX1_CFG0_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd3)) begin
        RX1_CFG1_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd4)) begin
        RX2_CFG0_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd5)) begin
        RX2_CFG1_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd6)) begin
        RX3_CFG0_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd7)) begin
        RX3_CFG1_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd8)) begin
        TX0_CFG0_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd9)) begin
        TX0_CFG1_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd10)) begin
        TX1_CFG0_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd11)) begin
        TX1_CFG1_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd12)) begin
        TX2_CFG0_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd13)) begin
        TX2_CFG1_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd14)) begin
        TX3_CFG0_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd15)) begin
        TX3_CFG1_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd16)) begin
        IF_CFG0_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd17)) begin
        TEST_CFG0_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd18)) begin
        TEST_CFG1_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd19)) begin
        TEST_CFG2_q <= data_i;
      end
      if (en_i && we_i && (addr_i == 5'd20)) begin
        TEST_CFG3_q <= data_i;
      end
      if (hw_in_i.TEST_RES0_we) begin
        TEST_RES0_q <= 4'(hw_in_i.TEST_RES0);
      end else begin
        if (en_i && we_i && (addr_i == 5'd21)) begin
          TEST_RES0_q <= data_i;
        end
      end
      if (hw_in_i.TEST_RES1_we) begin
        TEST_RES1_q <= 4'(hw_in_i.TEST_RES1);
      end else begin
        if (en_i && we_i && (addr_i == 5'd22)) begin
          TEST_RES1_q <= data_i;
        end
      end
      if (hw_in_i.TEST_RES2_we) begin
        TEST_RES2_q <= 4'(hw_in_i.TEST_RES2);
      end else begin
        if (en_i && we_i && (addr_i == 5'd23)) begin
          TEST_RES2_q <= data_i;
        end
      end
      if (hw_in_i.TEST_RES3_we) begin
        TEST_RES3_q <= 4'(hw_in_i.TEST_RES3);
      end else begin
        if (en_i && we_i && (addr_i == 5'd24)) begin
          TEST_RES3_q <= data_i;
        end
      end
      if (hw_in_i.TEST_RES4_we) begin
        TEST_RES4_q <= 4'(hw_in_i.TEST_RES4);
      end else begin
        if (en_i && we_i && (addr_i == 5'd25)) begin
          TEST_RES4_q <= data_i;
        end
      end
    end
  end

  // SW read mux
  always_ff @(posedge clk_i) begin
    if (en_i) begin
      unique case (addr_i)
        5'd0: data_o <= RX0_CFG0_q;
        5'd1: data_o <= RX0_CFG1_q;
        5'd2: data_o <= RX1_CFG0_q;
        5'd3: data_o <= RX1_CFG1_q;
        5'd4: data_o <= RX2_CFG0_q;
        5'd5: data_o <= RX2_CFG1_q;
        5'd6: data_o <= RX3_CFG0_q;
        5'd7: data_o <= RX3_CFG1_q;
        5'd8: data_o <= TX0_CFG0_q;
        5'd9: data_o <= TX0_CFG1_q;
        5'd10: data_o <= TX1_CFG0_q;
        5'd11: data_o <= TX1_CFG1_q;
        5'd12: data_o <= TX2_CFG0_q;
        5'd13: data_o <= TX2_CFG1_q;
        5'd14: data_o <= TX3_CFG0_q;
        5'd15: data_o <= TX3_CFG1_q;
        5'd16: data_o <= IF_CFG0_q;
        5'd17: data_o <= TEST_CFG0_q;
        5'd18: data_o <= TEST_CFG1_q;
        5'd19: data_o <= TEST_CFG2_q;
        5'd20: data_o <= TEST_CFG3_q;
        5'd21: data_o <= TEST_RES0_q;
        5'd22: data_o <= TEST_RES1_q;
        5'd23: data_o <= TEST_RES2_q;
        5'd24: data_o <= TEST_RES3_q;
        5'd25: data_o <= TEST_RES4_q;
        default: data_o <= 4'd0;
      endcase
    end
  end

endmodule : rf
