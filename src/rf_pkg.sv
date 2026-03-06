// -----------------------------------------------------------------------------
// Auto-generated package: typed register structs and HW interface structs
// -----------------------------------------------------------------------------
package rf_pkg;

typedef struct packed {
  logic [1:0] n_comb_tap_sel;
  logic [1:0] p_comb_tap_sel;
} RX0_CFG0_t;

typedef struct packed {
  logic        output_enable;
  logic        enable;
  logic        n_flop_tap_sel;
  logic        p_flop_tap_sel;
} RX0_CFG1_t;

typedef struct packed {
  logic [1:0] n_comb_tap_sel;
  logic [1:0] p_comb_tap_sel;
} RX1_CFG0_t;

typedef struct packed {
  logic        output_enable;
  logic        enable;
  logic        n_flop_tap_sel;
  logic        p_flop_tap_sel;
} RX1_CFG1_t;

typedef struct packed {
  logic [1:0] n_comb_tap_sel;
  logic [1:0] p_comb_tap_sel;
} RX2_CFG0_t;

typedef struct packed {
  logic        output_enable;
  logic        enable;
  logic        n_flop_tap_sel;
  logic        p_flop_tap_sel;
} RX2_CFG1_t;

typedef struct packed {
  logic [1:0] n_comb_tap_sel;
  logic [1:0] p_comb_tap_sel;
} RX3_CFG0_t;

typedef struct packed {
  logic        output_enable;
  logic        enable;
  logic        n_flop_tap_sel;
  logic        p_flop_tap_sel;
} RX3_CFG1_t;

typedef struct packed {
  logic [1:0] n_comb_tap_sel;
  logic [1:0] p_comb_tap_sel;
} TX0_CFG0_t;

typedef struct packed {
  logic        output_enable;
  logic        enable;
  logic        n_flop_tap_sel;
  logic        p_flop_tap_sel;
} TX0_CFG1_t;

typedef struct packed {
  logic [1:0] n_comb_tap_sel;
  logic [1:0] p_comb_tap_sel;
} TX1_CFG0_t;

typedef struct packed {
  logic        output_enable;
  logic        enable;
  logic        n_flop_tap_sel;
  logic        p_flop_tap_sel;
} TX1_CFG1_t;

typedef struct packed {
  logic [1:0] n_comb_tap_sel;
  logic [1:0] p_comb_tap_sel;
} TX2_CFG0_t;

typedef struct packed {
  logic        output_enable;
  logic        enable;
  logic        n_flop_tap_sel;
  logic        p_flop_tap_sel;
} TX2_CFG1_t;

typedef struct packed {
  logic [1:0] n_comb_tap_sel;
  logic [1:0] p_comb_tap_sel;
} TX3_CFG0_t;

typedef struct packed {
  logic        output_enable;
  logic        enable;
  logic        n_flop_tap_sel;
  logic        p_flop_tap_sel;
} TX3_CFG1_t;

typedef struct packed {
  logic [1:0] function_select;
  logic        tx_sdr_ddr;
  logic        rx_sdr_ddr;
} IF_CFG0_t;

typedef struct packed {
  logic [1:0] test_select;
  logic        freeze_result;
  logic        enable_reset_n;
} TEST_CFG0_t;

typedef struct packed {
  logic        reserved;
  logic        rx_tx_select;
  logic [1:0] lane_select;
} TEST_CFG1_t;

typedef struct packed {
  logic [3:0] sync_length;
} TEST_CFG2_t;

typedef struct packed {
  logic [3:0] test_length;
} TEST_CFG3_t;

typedef struct packed {
  logic [1:0] reserved;
  logic        test_done;
  logic        sync_successful;
} TEST_RES0_t;

typedef struct packed {
  logic [3:0] error_count_0;
} TEST_RES1_t;

typedef struct packed {
  logic [3:0] error_count_1;
} TEST_RES2_t;

typedef struct packed {
  logic [3:0] error_count_2;
} TEST_RES3_t;

typedef struct packed {
  logic [3:0] error_count_3;
} TEST_RES4_t;

typedef struct packed {
  logic       TEST_RES0_we;
  TEST_RES0_t TEST_RES0;
  logic       TEST_RES1_we;
  TEST_RES1_t TEST_RES1;
  logic       TEST_RES2_we;
  TEST_RES2_t TEST_RES2;
  logic       TEST_RES3_we;
  TEST_RES3_t TEST_RES3;
  logic       TEST_RES4_we;
  TEST_RES4_t TEST_RES4;
} hw_in_t;

typedef struct packed {
  RX0_CFG0_t RX0_CFG0;
  RX0_CFG1_t RX0_CFG1;
  RX1_CFG0_t RX1_CFG0;
  RX1_CFG1_t RX1_CFG1;
  RX2_CFG0_t RX2_CFG0;
  RX2_CFG1_t RX2_CFG1;
  RX3_CFG0_t RX3_CFG0;
  RX3_CFG1_t RX3_CFG1;
  TX0_CFG0_t TX0_CFG0;
  TX0_CFG1_t TX0_CFG1;
  TX1_CFG0_t TX1_CFG0;
  TX1_CFG1_t TX1_CFG1;
  TX2_CFG0_t TX2_CFG0;
  TX2_CFG1_t TX2_CFG1;
  TX3_CFG0_t TX3_CFG0;
  TX3_CFG1_t TX3_CFG1;
  IF_CFG0_t IF_CFG0;
  TEST_CFG0_t TEST_CFG0;
  TEST_CFG1_t TEST_CFG1;
  TEST_CFG2_t TEST_CFG2;
  TEST_CFG3_t TEST_CFG3;
  TEST_RES0_t TEST_RES0;
  TEST_RES1_t TEST_RES1;
  TEST_RES2_t TEST_RES2;
  TEST_RES3_t TEST_RES3;
  TEST_RES4_t TEST_RES4;
} hw_out_t;

endpackage : rf_pkg
