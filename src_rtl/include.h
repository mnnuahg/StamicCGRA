`define OP_NOP          0   // nop         in
`define OP_MOV1_2       1   // mov1_2      in, out0, out1
`define OP_MOV2_1       2   // mov2_1      in0, in1, out
`define OP_ADD          3
`define OP_MUL          4
`define OP_AND          5
`define OP_SWITCH_PRED  6   // switch_pred in, pred_in, true_out, false_out
`define OP_SWITCH_TAG   7   // switch_tag  in0, in1, out0, out1
`define OP_SYNC         8   // sync        imm_dist, in, sig_near, sig_far, out
`define OP_COMBINE_TAG  9   // combine_tag old_tag_in, new_tag_in, out
`define OP_NEW_TAG      10  // new_tag     old_tag_in, new_tag_in, out
`define OP_STORE_TAG    11  // store_tag   in, out
`define OP_RESTORE_TAG  12  // restore_tag in, out
`define OP_LOOP_HEAD    13  // loop_head   first_in, pred_in, looped_in, out
`define OP_INV_DATA     14  // inv_data    in, out
`define OP_ADD_DATA     15  // add_data    in, out
`define OP_LT_DATA      16  // lt_data     in, out
`define OP_EQ_DATA      17  // eq_data     in, out
`define OP_NE_DATA      18  // eq_data     in, out
`define OP_ST           19  // st          addr_in, data_in, sig_out
`define OP_DISCARD      20  // discard     in0, in1, in2, in3
`define OP_TOK_TO_BUS   21  // tok_to_bus  imm_n, in, sig_bus, out_bus
`define OP_BUS_TO_TOK   22  // bus_to_tok  imm_n, in_bus, sig_bus, out
`define OP_BUS_AND_BIT  23  // bus_and_bit imm_exclsb, imm_n1, imm_n2, in_bus, out_bus
`define OP_BUS_OR_BIT   24  // bus_nand_bit imm_exclsb, imm_n1, imm_n2, in_bus, out_bus
`define OP_BUS_NAND_BIT 25  // bus_or_bit imm_exclsb, imm_n1, imm_n2, in_bus, out_bus
`define OP_BUS_NOR_BIT  26  // bus_nor_bit imm_exclsb, imm_n1, imm_n2, in_bus, out_bus
`define OP_TAG_MATCHER  27  // tag_matcher imm_n, sig_bus, data_bus
`define OP_MATCHER_CTRL 28  // match_ctrl imm_n, imm_numInput, tag_sync_bus, out_sync_bus
`define OP_STORE_TAG2   29  // store_tag2 in_bus, out_sig_bus
`define OP_RESTORE_TAG2 30  // restore_tag tag_in_bus, data_in_bus, out
`define OP_BUS_FWD_LH   31  // bus_fwd_lh in_bus, out_bus
`define OP_BUS_CFWD_HI  32  // bus_cfwd_hi in_sig_bus, out_bus
`define OP_SELECT_PRED  33  // select_pred true_in, false_in, pred, out
`define OP_OX           34  // ox in0, in1, out

`define DIR_U0          0
`define DIR_U1          1
`define DIR_D0          2
`define DIR_D1          3
`define DIR_L0          4
`define DIR_L1          5
`define DIR_R0          6
`define DIR_R1          7
`define DIR_HB          0
`define DIR_VB          1

`define ALU_IN_SEL_HBUS 8
`define ALU_IN_SEL_VBUS 9
`define ALU_IN_SEL_DATA 10

`define DATA_SEL_INC    0
`define DATA_SEL_DEC    1
`define DATA_SEL_ALUIN0 2
`define DATA_SEL_DECODE 3

`define ALU_FUNC_IN1    0
`define ALU_FUNC_1H_0L  1   // the output is the high part of arg1 concat the low part of arg0
`define ALU_FUNC_1L_0L  2   // the output is the low part of arg1 concat the low part of arg0
`define ALU_FUNC_1H_0H  3
`define ALU_FUNC_0H_1L  4
`define ALU_FUNC_ADD    5
`define ALU_FUNC_MUL    6
`define ALU_FUNC_AND    7
`define ALU_FUNC_LT     8
`define ALU_FUNC_EQ     9
`define ALU_FUNC_NE     10
`define ALU_FUNC_ST     11
// We can define only 16 ALU functions now

`define STATE_INIT              0
`define STATE_ALREADY_FWD_NEAR  1
`define STATE_ALREADY_FWD_FAR   2
`define STATE_DELAY_FWD_NEAR    3
`define STATE_DONT_DELAY_FWD    4
`define STATE_WAIT_ARRIVE       5

`define VALID_PART_NONE 0
`define VALID_PART_HI   1
`define VALID_PART_LO   2
`define VALID_PART_ALL  3

`define INST_SIZE       32
`define DATA_SIZE       8 
`define LG_DATA_SIZE    3

