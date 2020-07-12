`include "fifo_n.v"

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

module select2#(parameter DATA_SIZE = 8)
               (input [DATA_SIZE-1:0] in0, input [DATA_SIZE-1:0] in1, input sel0, input sel1, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] outReg;
    
    assign out = outReg;
    
    always @* begin
        outReg = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        if (sel0 && !sel1)
            outReg = in0;
        else if (!sel0 && sel1)
            outReg = in1;
        else if (sel0 && sel1)
        begin
            $display("%m: sel0 and sel1 are both on!");
            $finish;
        end
    end
endmodule

module mux2#(parameter DATA_SIZE = 8)
       (input [DATA_SIZE-1:0] in0, input [DATA_SIZE-1:0] in1, input sel, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] outReg;
    
    assign out = outReg;
    
    always @* begin
        case (sel)
            0: outReg = in0;
            1: outReg = in1;
        endcase
    end
endmodule

module mux4#(parameter DATA_SIZE = 8)
       (input [DATA_SIZE-1:0] in0, input [DATA_SIZE-1:0] in1, input [DATA_SIZE-1:0] in2, input [DATA_SIZE-1:0] in3, input [1:0] sel, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] outReg;
    
    assign out = outReg;
    
    always @* begin
        case (sel)
            0: outReg = in0;
            1: outReg = in1;
            2: outReg = in2;
            3: outReg = in3;
        endcase
    end
endmodule

module mux8#(parameter DATA_SIZE = 8)
       (input [7:0][DATA_SIZE-1:0] in, input [2:0] sel, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] outReg;
    
    assign out = outReg;
    
    always @* begin
        outReg = in[sel];
    end
endmodule

module mux12#(parameter DATA_SIZE = 8)
       (input [7:0][DATA_SIZE-1:0] in0_7,
        input [DATA_SIZE-1:0] in8,
        input [DATA_SIZE-1:0] in9,
        input [DATA_SIZE-1:0] in10,
        input [DATA_SIZE-1:0] in11, 
        input [3:0] sel, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] outReg;
    
    assign out = outReg;
    
    always @* begin
        if (sel[3] == 0)
            outReg = in0_7[sel];
        else if (sel == 8)
            outReg = in8;
        else if (sel == 9)
            outReg = in9;
        else if (sel == 10)
            outReg = in10;
        else
            outReg = in11;
    end
endmodule

module increase#(parameter DATA_SIZE = 8)
                (input [DATA_SIZE-1:0] in, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] outReg;
    
    assign out = outReg;
    
    always @* begin
        outReg = in+1;
    end
endmodule

module decrease#(parameter DATA_SIZE = 8)
                (input [DATA_SIZE-1:0] in, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] outReg;
    
    assign out = outReg;
    
    always @* begin
        outReg = in-1;
    end
endmodule

module equal#(parameter DATA_SIZE = 8)
             (input [DATA_SIZE-1:0] in0, input [DATA_SIZE-1:0] in1, output out);
    reg outReg;
    
    assign out = outReg;
    
    always @* begin
        outReg = (in0 == in1);
    end
endmodule

module isZero#(parameter DATA_SIZE = 8)
              (input [DATA_SIZE-1:0] in, output out);
    reg outReg;
    
    assign out = outReg;
    
    always @* begin
        outReg = (in == 0);
    end
endmodule

module validNotZero#(parameter DATA_SIZE = 8)
               (input [DATA_SIZE-1:0] in, input [2:0] validBits, input excludeLSB, output out);
    reg outReg;
    
    assign out = outReg;
    wire [DATA_SIZE-1:0] power = validBits == 0 ? 0 : (1 << validBits);
    wire [DATA_SIZE-1:0] validMask = power-1;
    
    always @* begin
        outReg = excludeLSB ? ((in[`DATA_SIZE-1:1] & validMask[`DATA_SIZE-1:1]) != 0) : ((in & validMask) != 0);
    end
endmodule

module validAllOn#(parameter DATA_SIZE = 8)
               (input [DATA_SIZE-1:0] in, input [2:0] validBits, input excludeLSB, output out);
    reg outReg;
    
    assign out = outReg;
    wire [DATA_SIZE-1:0] power = validBits == 0 ? 0 : (1 << validBits);
    wire [DATA_SIZE-1:0] validMask = power-1;
    
    always @* begin
        outReg = excludeLSB ? ((in[`DATA_SIZE-1:1] & validMask[`DATA_SIZE-1:1]) == validMask[`DATA_SIZE-1:1]) : ((in & validMask) == validMask);
    end
endmodule

module busOutMux(input [`DATA_SIZE*2-1:0] instOut0, input [`DATA_SIZE*2-1:0] instOut1,
                 input [1:0] validPart0, input [1:0] validPart1,
                 input [`LG_DATA_SIZE:0] extraBitToSet0, input [`LG_DATA_SIZE:0] extraBitToSet1, 
                 input [1:0] extraBitValue0, input [1:0] extraBitValue1,
                 output [`DATA_SIZE*2-1:0] out);
    reg [`DATA_SIZE*2-1:0] outReg;
    reg [`DATA_SIZE*2-1:0] validMask;
    
    assign out[0]  = validMask[0]  ? outReg[0]  : 1'bz;
    assign out[1]  = validMask[1]  ? outReg[1]  : 1'bz;
    assign out[2]  = validMask[2]  ? outReg[2]  : 1'bz;
    assign out[3]  = validMask[3]  ? outReg[3]  : 1'bz;
    assign out[4]  = validMask[4]  ? outReg[4]  : 1'bz;
    assign out[5]  = validMask[5]  ? outReg[5]  : 1'bz;
    assign out[6]  = validMask[6]  ? outReg[6]  : 1'bz;
    assign out[7]  = validMask[7]  ? outReg[7]  : 1'bz;
    assign out[8]  = validMask[8]  ? outReg[8]  : 1'bz;
    assign out[9]  = validMask[9]  ? outReg[9]  : 1'bz;
    assign out[10] = validMask[10] ? outReg[10] : 1'bz;
    assign out[11] = validMask[11] ? outReg[11] : 1'bz;
    assign out[12] = validMask[12] ? outReg[12] : 1'bz;
    assign out[13] = validMask[13] ? outReg[13] : 1'bz;
    assign out[14] = validMask[14] ? outReg[14] : 1'bz;
    assign out[15] = validMask[15] ? outReg[15] : 1'bz;
    
    always @* begin
        validMask = 0;
        outReg = 16'bxxxxxxxxxxxxxxxx;
    
        if (validPart0 == `VALID_PART_ALL) begin
            outReg = instOut0;
            validMask = 16'b1111111111111111;
        end
        if (validPart1 == `VALID_PART_ALL) begin
            outReg = instOut1;
            validMask = 16'b1111111111111111;
        end
    
        if (validPart0 == `VALID_PART_HI) begin
            outReg[`DATA_SIZE*2-1:`DATA_SIZE] = instOut0[`DATA_SIZE*2-1:`DATA_SIZE];
            validMask = validMask | 16'b1111111100000000;
        end
        if (validPart1 == `VALID_PART_HI) begin
            outReg[`DATA_SIZE*2-1:`DATA_SIZE] = instOut1[`DATA_SIZE*2-1:`DATA_SIZE];
            validMask = validMask | 16'b1111111100000000;
        end
        
        if (validPart0 == `VALID_PART_LO) begin
            outReg[`DATA_SIZE-1:0] = instOut0[`DATA_SIZE-1:0];
            validMask = validMask | 16'b0000000011111111;
        end
        if (validPart1 == `VALID_PART_LO) begin
            outReg[`DATA_SIZE-1:0] = instOut1[`DATA_SIZE-1:0];
            validMask = validMask | 16'b0000000011111111;
        end
        
        if (extraBitValue0[1] == 1) begin
            outReg[extraBitToSet0] = extraBitValue0[0];
            validMask[extraBitToSet0] = 1;
        end
        if (extraBitValue1[1] == 1) begin
            outReg[extraBitToSet1] = extraBitValue1[0];
            validMask[extraBitToSet1] = 1;
        end
    end
endmodule

module instFieldDecoder(input [`INST_SIZE-1:0] inst,
                        output [5:0] op, 
                        output [13:0] imm,
                        output [2:0] arg0, output [2:0] arg1, output [2:0] arg2, output [2:0] arg3);
    assign   op = inst[31:26];
    assign  imm = inst[25:12];
    assign arg0 = inst[11:9];
    assign arg1 = inst[8:6];
    assign arg2 = inst[5:3];
    assign arg3 = inst[2:0];
endmodule

module instDecoder
    (input [`INST_SIZE-1:0] inst,
     input [7:0] isInputReadys,
     input [7:0] isOutputFulls,
     input aluIn0LoNotZero, input aluIn0LoIsAllOn, input aluIn0HiEqDataHi, 
     input aluIn1LoNotZero, input aluIn1LoIsAllOn,
     input dataLoIsZero, 
     input [`DATA_SIZE-1:0] dataHiIn,
     output [7:0] readInputs,
     output [7:0] writeOutputs,
     output writeDataHi, output [`DATA_SIZE-1:0] dataHiOut,
     output writeDataLo, output [`DATA_SIZE-1:0] dataLoOut, output [1:0] dataLoSel,
     output [3:0] aluIn0Sel, output [3:0] aluIn1Sel, output [3:0] aluFuncSel,
     output [2:0] aluIn0LoValidBits, output [2:0] aluIn1LoValidBits,
     output aluIn0LoExcludeLSB, output aluIn1LoExcludeLSB,
     output [1:0][1:0] busValidPart, output [1:0][`LG_DATA_SIZE:0] busExtraBitToSet, output [1:0][1:0] busExtraBitValue);
    
    reg [7:0] readInputsReg;
    reg [7:0] writeOutputsReg;
    reg writeDataHiReg;
    reg writeDataLoReg;
    reg [`DATA_SIZE-1:0] dataHiOutReg;
    reg [`DATA_SIZE-1:0] dataLoOutReg;
    reg [1:0] dataLoSelReg;
    reg [3:0] aluIn0SelReg;
    reg [3:0] aluIn1SelReg;
    reg [3:0] aluFuncSelReg;
    reg [2:0] aluIn0LoValidBitsReg;
    reg [2:0] aluIn1LoValidBitsReg;
    reg aluIn0LoExcludeLSBReg;
    reg aluIn1LoExcludeLSBReg;
    reg [1:0][1:0] busValidPartReg;
    reg [1:0][`LG_DATA_SIZE:0] busExtraBitToSetReg;
    reg [1:0][1:0] busExtraBitValueReg;
    
    assign readInputs = readInputsReg;
    assign writeOutputs = writeOutputsReg;
    assign writeDataHi = writeDataHiReg;
    assign writeDataLo = writeDataLoReg;
    assign dataHiOut = dataHiOutReg;
    assign dataLoOut = dataLoOutReg;
    assign dataLoSel = dataLoSelReg;
    assign aluIn0Sel = aluIn0SelReg;
    assign aluIn1Sel = aluIn1SelReg;
    assign aluFuncSel = aluFuncSelReg;
    assign aluIn0LoValidBits = aluIn0LoValidBitsReg;
    assign aluIn1LoValidBits = aluIn1LoValidBitsReg;
    assign aluIn0LoExcludeLSB = aluIn0LoExcludeLSBReg;
    assign aluIn1LoExcludeLSB = aluIn1LoExcludeLSBReg;
    assign busValidPart = busValidPartReg;
    assign busExtraBitToSet = busExtraBitToSetReg;
    assign busExtraBitValue = busExtraBitValueReg;
    
    wire [ 5:0]  op;
    wire [13:0] imm;
    wire [ 2:0] arg0, arg1, arg2, arg3;
    
    instFieldDecoder dec(inst, op, imm, arg0, arg1, arg2, arg3);
    
    // Only used in OP_SYNC but verilog don't allow local scope wire
    wire [3:0] distNear = imm[7:4];
    wire [3:0] distFar  = imm[3:0];
    wire [3:0] delay = distFar - distNear;
    
    always @* begin    
        readInputsReg = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
        writeOutputsReg = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
        writeDataHiReg = 1'b0;
        writeDataLoReg = 1'b0;
        dataHiOutReg = 8'bxxxxxxxx;
        dataLoOutReg = 8'bxxxxxxxx;
        dataLoSelReg = 2'bxx;
        aluIn0SelReg = 4'bxxxx;
        aluIn1SelReg = 4'bxxxx;
        aluFuncSelReg = 3'bxxx;
        busValidPartReg[0] = 2'b00;
        busValidPartReg[1] = 2'b00;
        busExtraBitToSetReg[0] = 4'bxxxx;
        busExtraBitToSetReg[1] = 4'bxxxx;
        busExtraBitValueReg[0] = 2'b0x;
        busExtraBitValueReg[1] = 2'b0x;
        
        /* This is number of valid bits, which is default to 8
           however, these wires has only 3 bits, so just set to 0 */
        aluIn0LoValidBitsReg = 0;
        aluIn1LoValidBitsReg = 0;
        aluIn0LoExcludeLSBReg = 0;
        aluIn1LoExcludeLSBReg = 0;
    
        case (op)
            `OP_NOP: begin
            end
            `OP_DISCARD: begin
                aluFuncSelReg = `ALU_FUNC_IN1;
                if (isInputReadys[arg0])
                    readInputsReg[arg0] = 1;
                if (isInputReadys[arg1])
                    readInputsReg[arg1] = 1;
                if (isInputReadys[arg2])
                    readInputsReg[arg2] = 1;
                if (isInputReadys[arg3])
                    readInputsReg[arg3] = 1;
            end
            `OP_MOV1_2: begin
                aluIn1SelReg = arg0;
                aluFuncSelReg = `ALU_FUNC_IN1;
                if (isInputReadys[arg0] && !isOutputFulls[arg1] && !isOutputFulls[arg2]) begin
                    readInputsReg[arg0] = 1;
                    writeOutputsReg[arg1] = 1;
                    writeOutputsReg[arg2] = 1;
                end
            end
            `OP_MOV2_1: begin
                dataHiOutReg = dataHiIn;
                writeDataHiReg = 1;
                if (isOutputFulls[arg2]) begin
                    $display("Tag matching unit jammed in %m\n");
                    $finish;
                end
                if (isInputReadys[arg1] && !isOutputFulls[arg2]) begin
                    aluIn1SelReg = arg1;
                    aluFuncSelReg = `ALU_FUNC_IN1;
                    readInputsReg[arg1] = 1;
                    writeOutputsReg[arg2] = 1;
                end
                else if (isInputReadys[arg0] && !isOutputFulls[arg2]) begin
                    aluIn1SelReg = arg0;
                    aluFuncSelReg = `ALU_FUNC_IN1;
                    readInputsReg[arg0] = 1;
                    writeOutputsReg[arg2] = 1;
                end
            end
            `OP_ADD: begin
                if (isInputReadys[arg0] && isInputReadys[arg1] && !isOutputFulls[arg2]) begin
                    aluIn0SelReg = arg0;
                    aluIn1SelReg = arg1;
                    aluFuncSelReg = `ALU_FUNC_ADD;
                    readInputsReg[arg0] = 1;
                    readInputsReg[arg1] = 1;
                    writeOutputsReg[arg2] = 1;
                end
            end
            `OP_AND: begin
                if (isInputReadys[arg0] && isInputReadys[arg1] && !isOutputFulls[arg2]) begin
                    aluIn0SelReg = arg0;
                    aluIn1SelReg = arg1;
                    aluFuncSelReg = `ALU_FUNC_AND;
                    readInputsReg[arg0] = 1;
                    readInputsReg[arg1] = 1;
                    writeOutputsReg[arg2] = 1;
                end
            end
            `OP_SYNC: begin
                dataHiOutReg = dataHiIn;
                writeDataHiReg = 1;
                aluIn1SelReg = arg0;
                aluFuncSelReg = `ALU_FUNC_IN1;
                case (dataHiIn)
                    `STATE_INIT: begin
                        if (isInputReadys[arg0] && isInputReadys[arg1] && isInputReadys[arg2] && delay == 0) begin
                            dataHiOutReg = `STATE_WAIT_ARRIVE;
                            dataLoOutReg = distFar - 1;
                            writeDataLoReg = 1;
                            dataLoSelReg = `DATA_SEL_DECODE;
                            readInputsReg[arg1] = 1;
                            readInputsReg[arg2] = 1;
                            writeOutputsReg[arg1] = 1;
                            writeOutputsReg[arg2] = 1;
                        end
                        else if (isInputReadys[arg0] && (isInputReadys[arg1] || distNear==0) && (!isInputReadys[arg2] || delay>0)) begin
                            dataHiOutReg = `STATE_ALREADY_FWD_FAR;
                            readInputsReg[arg1] = isInputReadys[arg1];
                            writeOutputsReg[arg2] = 1;
                        end
                        else if (isInputReadys[arg0] && !(isInputReadys[arg1] || distNear==0) && isInputReadys[arg2]) begin
                            dataHiOutReg = `STATE_ALREADY_FWD_NEAR;
                            readInputsReg[arg2] = 1;
                            writeOutputsReg[arg1] = 1;
                        end
                    end
                    `STATE_ALREADY_FWD_NEAR: begin
                        if (isInputReadys[arg1]) begin
                            dataHiOutReg = `STATE_WAIT_ARRIVE;
                            dataLoOutReg = distFar - 1;
                            writeDataLoReg = 1;
                            dataLoSelReg = `DATA_SEL_DECODE;
                            readInputsReg[arg1] = 1;
                            writeOutputsReg[arg2] = 1;
                        end
                    end
                    `STATE_ALREADY_FWD_FAR: begin
                        if (isInputReadys[arg2] && delay<=1 && distNear==0) begin
                            if (!isOutputFulls[arg3]) begin
                                dataHiOutReg = `STATE_INIT;
                                readInputsReg[arg0] = 1;
                                readInputsReg[arg2] = 1;
                                writeOutputsReg[arg3] = 1;
                            end
                        end
                        else if (isInputReadys[arg2] && delay<=1 && distNear>0) begin
                            dataHiOutReg = `STATE_WAIT_ARRIVE;
                            dataLoOutReg = distNear - 1;
                            writeDataLoReg = 1;
                            dataLoSelReg = `DATA_SEL_DECODE;
                            readInputsReg[arg2] = 1;
                            writeOutputsReg[arg1] = 1;
                        end
                        else if (isInputReadys[arg2] && delay>1) begin
                            dataHiOutReg = `STATE_DELAY_FWD_NEAR;
                            dataLoOutReg = delay - 2;
                            writeDataLoReg = 1;
                            dataLoSelReg = `DATA_SEL_DECODE;
                        end
                        else begin
                            dataHiOutReg = `STATE_DONT_DELAY_FWD;
                        end
                    end
                    `STATE_DELAY_FWD_NEAR: begin
                        if (dataLoIsZero && distNear>0) begin
                            dataHiOutReg = `STATE_WAIT_ARRIVE;
                            dataLoOutReg = distNear - 1;
                            writeDataLoReg = 1;
                            dataLoSelReg = `DATA_SEL_DECODE;
                            readInputsReg[arg2] = 1;
                            writeOutputsReg[arg1] = 1;
                        end
                        else if (dataLoIsZero && distNear==0) begin
                            if (!isOutputFulls[arg3]) begin
                                dataHiOutReg = `STATE_INIT;
                                readInputsReg[arg0] = 1;
                                readInputsReg[arg2] = 1;
                                writeOutputsReg[arg3] = 1;
                            end
                        end
                        else begin
                            writeDataLoReg = 1;
                            dataLoSelReg = `DATA_SEL_DEC;
                        end
                    end
                    `STATE_DONT_DELAY_FWD: begin
                        if (isInputReadys[arg2] && distNear>0) begin
                            dataHiOutReg = `STATE_WAIT_ARRIVE;
                            dataLoOutReg = distNear - 1;
                            writeDataLoReg = 1;
                            dataLoSelReg = `DATA_SEL_DECODE;
                            readInputsReg[arg2] = 1;
                            writeOutputsReg[arg1] = 1;
                        end
                        else if (isInputReadys[arg2] && distNear==0) begin
                            if (!isOutputFulls[arg3]) begin
                                dataHiOutReg = `STATE_INIT;
                                readInputsReg[arg0] = 1;
                                readInputsReg[arg2] = 1;
                                writeOutputsReg[arg3] = 1;
                            end
                        end
                    end
                    `STATE_WAIT_ARRIVE: begin
                        if (dataLoIsZero) begin
                            if (!isOutputFulls[arg3]) begin
                                dataHiOutReg = `STATE_INIT;
                                readInputsReg[arg0] = 1;
                                writeOutputsReg[arg3] = 1;
                            end
                        end
                        else begin
                            writeDataLoReg = 1;
                            dataLoSelReg = `DATA_SEL_DEC;
                        end
                    end
                    default: begin
                        $display("Illegal state in %m\n");
                        $finish;
                    end
                endcase
            end
            `OP_SWITCH_PRED: begin
                aluIn0SelReg = arg1;   // This is used to produce aluIn0LoNotZero
                if (isInputReadys[arg0] && isInputReadys[arg1]) begin
                    aluIn1SelReg = arg0;
                    aluFuncSelReg = `ALU_FUNC_IN1;
                    if (aluIn0LoNotZero && !isOutputFulls[arg2]) begin
                        readInputsReg[arg0] = 1;
                        readInputsReg[arg1] = 1;
                        writeOutputsReg[arg2] = 1;
                    end
                    else if (!aluIn0LoNotZero && !isOutputFulls[arg3]) begin
                        readInputsReg[arg0] = 1;
                        readInputsReg[arg1] = 1;
                        writeOutputsReg[arg3] = 1;
                    end
                end
            end
            `OP_SWITCH_TAG: begin
                if (isInputReadys[arg1] && !isOutputFulls[arg3]) begin
                    aluIn1SelReg = arg1;
                    aluFuncSelReg = `ALU_FUNC_IN1;
                    readInputsReg[arg1] = 1;
                    writeOutputsReg[arg3] = 1;
                end
                else if (isInputReadys[arg0]) begin
                    aluIn0SelReg = arg0;
                    aluIn1SelReg = arg0;
                    aluFuncSelReg = `ALU_FUNC_IN1;
                    if (aluIn0HiEqDataHi && !isOutputFulls[arg2]) begin
                        readInputsReg[arg0] = 1;
                        writeOutputsReg[arg2] = 1;
                    end
                    else if (!aluIn0HiEqDataHi && !isOutputFulls[arg3]) begin
                        readInputsReg[arg0] = 1;
                        writeOutputsReg[arg3] = 1;
                    end
                end
            end
            `OP_COMBINE_TAG: begin
                if (isInputReadys[arg0] && isInputReadys[arg1] && !isOutputFulls[arg2]) begin
                    aluIn0SelReg = arg0;
                    aluIn1SelReg = arg1;
                    aluFuncSelReg = `ALU_FUNC_1H_0H;
                    readInputsReg[arg0] = 1;
                    readInputsReg[arg1] = 1;
                    writeOutputsReg[arg2] = 1;
                end
            end
            `OP_NEW_TAG: begin
                if (isInputReadys[arg0] && isInputReadys[arg1] && !isOutputFulls[arg2]) begin
                    aluIn0SelReg = arg0;
                    aluIn1SelReg = arg1;
                    aluFuncSelReg = `ALU_FUNC_1H_0L;
                    readInputsReg[arg0] = 1;
                    readInputsReg[arg1] = 1;
                    writeOutputsReg[arg2] = 1;
                end
            end
            `OP_STORE_TAG: begin
                aluIn0SelReg = arg0;   // This is used to produce aluIn0HiEqDataHi
                aluIn1SelReg = arg0;
                if (isInputReadys[arg0] && !isOutputFulls[arg1]) begin
                    aluFuncSelReg = `ALU_FUNC_IN1;
                    readInputsReg[arg0] = 1;
                    writeOutputsReg[arg1] = 1;
                    if (aluIn0HiEqDataHi) begin
                        dataLoSelReg = `DATA_SEL_ALUIN0;
                        writeDataLoReg = 1;
                    end
                end
            end
            `OP_RESTORE_TAG: begin
                aluIn0SelReg = arg0;   // This is used to produce aluIn0HiEqDataHi
                if (isInputReadys[arg0] && !isOutputFulls[arg1]) begin
                    readInputsReg[arg0] = 1;
                    writeOutputsReg[arg1] = 1;
                    if (aluIn0HiEqDataHi) begin
                        aluIn1SelReg = `ALU_IN_SEL_DATA;
                        aluFuncSelReg = `ALU_FUNC_1L_0L;
                    end
                    else begin
                        aluIn1SelReg = arg0;
                        aluFuncSelReg = `ALU_FUNC_IN1;
                    end
                end
            end
            `OP_LOOP_HEAD: begin
                aluIn0SelReg = arg1;   // This is used to produce aluIn0LoNotZero
                if (isInputReadys[arg1] && !aluIn0LoNotZero) begin
                    dataLoSelReg = `DATA_SEL_INC;
                    writeDataLoReg = 1;
                    readInputsReg[arg1] = 1;
                end
                if (isInputReadys[arg1] && aluIn0LoNotZero && isInputReadys[arg2] && !isOutputFulls[arg3]) begin
                    aluIn1SelReg = arg2;
                    aluFuncSelReg = `ALU_FUNC_IN1;
                    readInputsReg[arg1] = 1;
                    readInputsReg[arg2] = 1;
                    writeOutputsReg[arg3] = 1;
                end
                else if (isInputReadys[arg0] && !dataLoIsZero && !isOutputFulls[arg3]) begin
                    dataLoSelReg = `DATA_SEL_DEC;
                    writeDataLoReg = 1;
                    aluIn1SelReg = arg0;
                    aluFuncSelReg = `ALU_FUNC_IN1;
                    readInputsReg[arg0] = 1;
                    writeOutputsReg[arg3] = 1;
                end
            end
            `OP_INV_DATA: begin
                if (isInputReadys[arg0] && !isOutputFulls[arg1]) begin
                    aluIn0SelReg = arg0;
                    aluIn1SelReg = `ALU_IN_SEL_DATA;
                    aluFuncSelReg = `ALU_FUNC_0H_1L;
                    readInputsReg[arg0] = 1;
                    writeOutputsReg[arg1] = 1;
                end
            end
            `OP_ADD_DATA: begin
                if (isInputReadys[arg0] && !isOutputFulls[arg1]) begin
                    aluIn0SelReg = arg0;
                    aluIn1SelReg = `ALU_IN_SEL_DATA;
                    aluFuncSelReg = `ALU_FUNC_ADD;
                    readInputsReg[arg0] = 1;
                    writeOutputsReg[arg1] = 1;
                end
            end
            `OP_LT_DATA: begin
                if (isInputReadys[arg0] && !isOutputFulls[arg1]) begin
                    aluIn0SelReg = arg0;
                    aluIn1SelReg = `ALU_IN_SEL_DATA;
                    aluFuncSelReg = `ALU_FUNC_LT;
                    readInputsReg[arg0] = 1;
                    writeOutputsReg[arg1] = 1;
                end
            end
            `OP_EQ_DATA: begin
                if (isInputReadys[arg0] && !isOutputFulls[arg1]) begin
                    aluIn0SelReg = arg0;
                    aluIn1SelReg = `ALU_IN_SEL_DATA;
                    aluFuncSelReg = `ALU_FUNC_EQ;
                    readInputsReg[arg0] = 1;
                    writeOutputsReg[arg1] = 1;
                end
            end
            `OP_NE_DATA: begin
                if (isInputReadys[arg0] && !isOutputFulls[arg1]) begin
                    aluIn0SelReg = arg0;
                    aluIn1SelReg = `ALU_IN_SEL_DATA;
                    aluFuncSelReg = `ALU_FUNC_NE;
                    readInputsReg[arg0] = 1;
                    writeOutputsReg[arg1] = 1;
                end
            end
            `OP_ST: begin
                if (isInputReadys[arg0] && isInputReadys[arg1] && !isOutputFulls[arg2]) begin
                    aluIn0SelReg = arg0;
                    aluIn1SelReg = arg1;
                    aluFuncSelReg = `ALU_FUNC_ST;
                    readInputsReg[arg0] = 1;
                    readInputsReg[arg1] = 1;
                    writeOutputsReg[arg2] = 1;
                end
            end
            // tok_to_bus  imm_n, in, sig_bus, out_bus
            `OP_TOK_TO_BUS: begin
                busExtraBitToSetReg[arg1] = imm;
                aluIn0SelReg = {1'b1, arg1};    // Indicates to select bus instead of FIFO
                aluIn0LoValidBitsReg = 1;          // Used to detect signal bus[0]
                aluFuncSelReg = `ALU_FUNC_IN1;
                if (isInputReadys[arg0]) begin
                    busExtraBitValueReg[arg1] = 2'b11;
                    if (aluIn0LoIsAllOn) begin
                        aluIn1SelReg = arg0;
                        busValidPartReg[arg2] = `VALID_PART_ALL;
                        readInputsReg[arg0] = 1;
                    end
                end
                else begin
                    busExtraBitValueReg[arg1] = 2'b10;
                    /* Should still send something even if no token available
                       otherwise the listener of the bus may get random results */
                    if (aluIn0LoIsAllOn) begin
                        aluIn1SelReg = `ALU_IN_SEL_DATA;
                        busValidPartReg[arg2] = `VALID_PART_ALL;
                    end
                end
            end
            // bus_to_tok  imm_n, in_bus, sig_bus, out
            `OP_BUS_TO_TOK: begin
                busExtraBitToSetReg[arg1] = imm;
                aluIn0SelReg = {1'b1, arg1};    // Indicates to select bus instead of FIFO
                aluIn0LoValidBitsReg = 1;          // Used to detect signal bus[0]
                aluIn1SelReg = {1'b1, arg0};
                aluFuncSelReg = `ALU_FUNC_IN1;
                if (!isOutputFulls[arg2]) begin
                    busExtraBitValueReg[arg1] = 2'b11;
                    if (aluIn0LoIsAllOn)
                        writeOutputsReg[arg2] = 1;
                end
                else
                    busExtraBitValueReg[arg1] = 2'b10;
            end
            // bus_and_bit imm_n1, imm_n2, in_bus, out_bus
            `OP_BUS_AND_BIT: begin
                busExtraBitToSetReg[arg1] = imm[3:0];
                aluIn0SelReg = {1'b1, arg0};
                aluIn0LoValidBitsReg = imm[6:4];
                aluIn0LoExcludeLSBReg = imm[8];
                if (aluIn0LoIsAllOn)
                    busExtraBitValueReg[arg1] = 2'b11;
                else
                    busExtraBitValueReg[arg1] = 2'b10;
            end
            `OP_BUS_OR_BIT: begin
                busExtraBitToSetReg[arg1] = imm[3:0];
                aluIn0SelReg = {1'b1, arg0};
                aluIn0LoValidBitsReg = imm[6:4];
                aluIn0LoExcludeLSBReg = imm[8];
                if (aluIn0LoNotZero)
                    busExtraBitValueReg[arg1] = 2'b11;
                else
                    busExtraBitValueReg[arg1] = 2'b10;
            end
            `OP_BUS_NAND_BIT: begin
                busExtraBitToSetReg[arg1] = imm[3:0];
                aluIn0SelReg = {1'b1, arg0};
                aluIn0LoValidBitsReg = imm[6:4];
                aluIn0LoExcludeLSBReg = imm[8];
                if (aluIn0LoIsAllOn)
                    busExtraBitValueReg[arg1] = 2'b10;
                else
                    busExtraBitValueReg[arg1] = 2'b11;
            end
            `OP_BUS_NOR_BIT: begin
                busExtraBitToSetReg[arg1] = imm[3:0];
                aluIn0SelReg = {1'b1, arg0};
                aluIn0LoValidBitsReg = imm[6:4];
                aluIn0LoExcludeLSBReg = imm[8];
                if (aluIn0LoNotZero)
                    busExtraBitValueReg[arg1] = 2'b10;
                else
                    busExtraBitValueReg[arg1] = 2'b11;
            end
            // tag_matcher imm_n, sig_bus, data_bus
            `OP_TAG_MATCHER: begin
                /* Use one bit of dataHiIn as the state */
                if (dataHiIn[`DATA_SIZE-1] == 0) begin
                    aluIn0SelReg = {1'b1, arg1};
                    aluIn1SelReg = {1'b1, arg0};
                    aluIn1LoValidBitsReg = 1;
                    if (aluIn1LoNotZero == 0 && aluIn0HiEqDataHi == 1) begin
                        writeDataHiReg = 1;
                        dataHiOutReg = {1'b1, dataHiIn[`DATA_SIZE-2:0]};
                        writeDataLoReg = 1;
                        dataLoSelReg = `DATA_SEL_ALUIN0;
                    end
                end
                else begin
                    busExtraBitToSetReg[arg0] = imm;
                    busExtraBitValueReg[arg0] = 2'b11;
                    aluIn0SelReg = {1'b1, arg0};
                    aluIn1SelReg = `ALU_IN_SEL_DATA;
                    aluFuncSelReg = `ALU_FUNC_IN1;
                    aluIn0LoValidBitsReg = 1;
                    if (aluIn0LoNotZero == 1) begin
                        busValidPartReg[arg1] = `VALID_PART_ALL;
                        writeDataHiReg = 1;
                        dataHiOutReg = {1'b0, dataHiIn[`DATA_SIZE-2:0]};
                    end
                end
            end
            // match_ctrl imm_n, imm_numInput, tag_sync_bus, out_sync_bus
            `OP_MATCHER_CTRL: begin
                aluIn0SelReg = {1'b1, arg0};
                aluIn1SelReg = {1'b1, arg1};
                aluIn0LoValidBitsReg = imm[6:4];
                aluIn1LoValidBitsReg = imm[2:0];
                aluIn0LoExcludeLSBReg = 1;
                busExtraBitToSetReg[arg0] = 0;
                busExtraBitToSetReg[arg1] = imm[3:0];
                if (aluIn0LoIsAllOn == 1 && aluIn1LoNotZero == 0) begin
                    busExtraBitValueReg[arg0] = 2'b11;
                    busExtraBitValueReg[arg1] = 2'b11;
                end
                else begin
                    busExtraBitValueReg[arg0] = 2'b10;
                    busExtraBitValueReg[arg1] = 2'b10;
                end
            end
            // store_tag2 in_bus, out_sig_bus
            `OP_STORE_TAG2: begin
                aluIn0SelReg = {1'b1, arg0};
                aluIn1SelReg = `ALU_IN_SEL_DATA;
                aluFuncSelReg = `ALU_FUNC_1L_0L;
                busExtraBitToSetReg[arg1] = 0;
                busExtraBitValueReg[arg1] = 2'b10;
                if (dataHiIn[`DATA_SIZE-1] == 0) begin
                    if (aluIn0HiEqDataHi) begin
                        writeDataHiReg = 1;
                        dataHiOutReg = {1'b1, dataHiIn[`DATA_SIZE-2:0]};
                        writeDataLoReg = 1;
                        dataLoSelReg = `DATA_SEL_ALUIN0;
                    end
                end
                else begin
                    if (aluIn0HiEqDataHi) begin
                        busValidPartReg[arg1] = `VALID_PART_HI;
                        busExtraBitValueReg[arg1] = 2'b11;
                        writeDataHiReg = 1;
                        dataHiOutReg = {1'b0, dataHiIn[`DATA_SIZE-2:0]};
                    end
                end
            end
            // restore_tag tag_in_bus, data_in_bus, out
            `OP_RESTORE_TAG2: begin
                aluIn0SelReg = {1'b1, arg1};
                aluIn1SelReg = {1'b1, arg0};
                aluFuncSelReg = `ALU_FUNC_1H_0H;
                aluIn0LoValidBitsReg = 2;
                aluIn1LoValidBitsReg = 2;
                aluIn0LoExcludeLSBReg = 1;
                busExtraBitToSetReg[arg0] = 0;
                busExtraBitValueReg[arg0] = {1'b1, !aluIn0LoNotZero && !isOutputFulls[arg2]};
                busExtraBitToSetReg[arg1] = 0;
                if (aluIn1LoIsAllOn == 0) begin
                    busExtraBitValueReg[arg1] = 2'b11;
                end
                else begin
                    busExtraBitValueReg[arg1] = 2'b10;
                    writeOutputsReg[arg2] = 1;
                end
            end
            // bus_fwd_lh in_bus, out_bus
            `OP_BUS_FWD_LH: begin
                aluIn1SelReg = {1'b1, arg0};
                aluFuncSelReg = `ALU_FUNC_1L_0L;
                busValidPartReg[arg1] = `VALID_PART_HI;
            end
            // bus_cfwd_hi in_sig_bus, out_bus
            `OP_BUS_CFWD_HI: begin
                aluIn0SelReg = {1'b1, arg0};
                aluIn0LoValidBitsReg = 1;
                aluFuncSelReg = `ALU_FUNC_0H_1L;
                if (aluIn0LoNotZero == 1) begin
                    busValidPartReg[arg1] = `VALID_PART_HI;
                end
            end
        endcase
    end
endmodule

module alu(input [`DATA_SIZE*2-1:0] inData0,
           input [`DATA_SIZE*2-1:0] inData1,
           input [3:0] funcSel,
           output [`DATA_SIZE*2-1:0] outData);
    
    reg [`DATA_SIZE*2-1:0] outDataReg;
    
    assign outData = outDataReg;
    
    always @(inData0, inData1, funcSel) begin
        outDataReg = 32'bx;
        case (funcSel)
            `ALU_FUNC_IN1:      outDataReg = inData1;
            `ALU_FUNC_ADD:      outDataReg = {inData0[`DATA_SIZE*2-1:`DATA_SIZE], inData0[`DATA_SIZE-1:0] + inData1[`DATA_SIZE-1:0]};
            `ALU_FUNC_MUL:      outDataReg = {inData0[`DATA_SIZE*2-1:`DATA_SIZE], inData0[`DATA_SIZE-1:0] * inData1[`DATA_SIZE-1:0]};
            `ALU_FUNC_AND:      outDataReg = {inData0[`DATA_SIZE*2-1:`DATA_SIZE], inData0[`DATA_SIZE-1:0] & inData1[`DATA_SIZE-1:0]};
            `ALU_FUNC_1H_0L:    outDataReg = {inData1[`DATA_SIZE*2-1:`DATA_SIZE], inData0[`DATA_SIZE-1:0]};
            `ALU_FUNC_1L_0L:    outDataReg = {inData1[`DATA_SIZE-1:0],            inData0[`DATA_SIZE-1:0]};
            `ALU_FUNC_1H_0H:    outDataReg = {inData1[`DATA_SIZE*2-1:`DATA_SIZE], inData0[`DATA_SIZE*2-1:`DATA_SIZE]};
            `ALU_FUNC_0H_1L:    outDataReg = {inData0[`DATA_SIZE*2-1:`DATA_SIZE], inData1[`DATA_SIZE-1:0]};
            `ALU_FUNC_LT: begin
                outDataReg = 0;
                outDataReg[`DATA_SIZE*2-1:`DATA_SIZE] = inData0[`DATA_SIZE*2-1:`DATA_SIZE];
                outDataReg[0] = inData0[`DATA_SIZE-1:0] < inData1[`DATA_SIZE-1:0] ? 1 : 0;
            end
            `ALU_FUNC_EQ: begin
                outDataReg = 0;
                outDataReg[`DATA_SIZE*2-1:`DATA_SIZE] = inData0[`DATA_SIZE*2-1:`DATA_SIZE];
                outDataReg[0] = inData0[`DATA_SIZE-1:0] == inData1[`DATA_SIZE-1:0] ? 1 : 0;
            end
            `ALU_FUNC_NE: begin
                outDataReg = 0;
                outDataReg[`DATA_SIZE*2-1:`DATA_SIZE] = inData0[`DATA_SIZE*2-1:`DATA_SIZE];
                outDataReg[0] = (inData0[`DATA_SIZE-1:0] != inData1[`DATA_SIZE-1:0]) ? 1 : 0;
            end
            `ALU_FUNC_ST: begin
                outDataReg = inData0;
                $display("Popcount of %d is %d", inData0[`DATA_SIZE-1:0], inData1[`DATA_SIZE-1:0]);
            end
        endcase
    end
endmodule

module pe2(input clk,
           input [7:0][`DATA_SIZE*2-1:0] inDatas,
           input [7:0] inDataReadys,
           output [7:0] readInDatas,
           output [7:0][`DATA_SIZE*2-1:0] outDatas,
           output [7:0] outDataReadys,
           input [7:0] readOutDatas,
           inout [`DATA_SIZE*2-1:0] hBus, inout [`DATA_SIZE*2-1:0] vBus);
    
    reg [`INST_SIZE-1:0] insts [1:0];
    reg [`DATA_SIZE*2-1:0] storedData;
    
    wire [7:0] isOutputFulls;
    wire [7:0] isOutputEmptys;
    wire dataLoIsZero;
    wire [`DATA_SIZE-1:0] increasedDataLo;
    wire [`DATA_SIZE-1:0] decreasedDataLo;
    
    assign outDataReadys[0] = !isOutputEmptys[0];
    assign outDataReadys[1] = !isOutputEmptys[1];
    assign outDataReadys[2] = !isOutputEmptys[2];
    assign outDataReadys[3] = !isOutputEmptys[3];
    assign outDataReadys[4] = !isOutputEmptys[4];
    assign outDataReadys[5] = !isOutputEmptys[5];
    assign outDataReadys[6] = !isOutputEmptys[6];
    assign outDataReadys[7] = !isOutputEmptys[7];
    
    isZero#(`DATA_SIZE) dataLoZero(storedData[`DATA_SIZE-1:0], dataLoIsZero);
    increase#(`DATA_SIZE) incDataLo(storedData[`DATA_SIZE-1:0], increasedDataLo);
    decrease#(`DATA_SIZE) decDataLo(storedData[`DATA_SIZE-1:0], decreasedDataLo);
    
    /* The signals for the two instruction */
    
    wire [`DATA_SIZE*2-1:0] aluOuts [1:0];
    wire aluIn0LoNotZero [1:0];
    wire aluIn0LoIsAllOn [1:0];
    wire aluIn0HiEqDataHi [1:0];
    wire aluIn1LoNotZero [1:0];
    wire aluIn1LoIsAllOn [1:0];
    wire [7:0] readInputs [1:0];
    wire [7:0] writeOutputs [1:0];
    wire writeDataHi [1:0];
    wire writeDataLo [1:0];
    wire [`DATA_SIZE-1:0] nextDataHi [1:0];
    wire [`DATA_SIZE-1:0] nextDataLo [1:0];
    wire [1:0] dataLoSel [1:0];
    wire [3:0] aluIn0Sel [1:0];
    wire [3:0] aluIn1Sel [1:0];
    wire [3:0] aluFuncSel [1:0];
    wire [2:0] aluIn0LoValidBits [1:0];
    wire [2:0] aluIn1LoValidBits [1:0];
    wire aluIn0LoExcludeLSB [1:0];
    wire aluIn1LoExcludeLSB [1:0];
    wire [1:0][1:0] busValidPart [1:0];
    wire [1:0][`LG_DATA_SIZE:0] busExtraBitToSet [1:0];
    wire [1:0][1:0] busExtraBitValue [1:0];
    
    wire [`DATA_SIZE*2-1:0] aluIn0 [1:0];
    wire [`DATA_SIZE*2-1:0] aluIn1 [1:0];
    
    wire [`DATA_SIZE-1:0] selectedDataLo [1:0];
    
    
    /* The logic of insts[0] */
    
    instDecoder dec0(insts[0],
                     inDataReadys,
                     isOutputFulls,
                     aluIn0LoNotZero[0], aluIn0LoIsAllOn[0], aluIn0HiEqDataHi[0],
                     aluIn1LoNotZero[0], aluIn1LoIsAllOn[0],
                     dataLoIsZero,
                     storedData[`DATA_SIZE*2-1:`DATA_SIZE],
                     readInputs[0],
                     writeOutputs[0],
                     writeDataHi[0], nextDataHi[0],
                     writeDataLo[0], nextDataLo[0], dataLoSel[0],
                     aluIn0Sel[0], aluIn1Sel[0], aluFuncSel[0],
                     aluIn0LoValidBits[0], aluIn1LoValidBits[0],
                     aluIn0LoExcludeLSB[0], aluIn1LoExcludeLSB[0],
                     busValidPart[0], busExtraBitToSet[0], busExtraBitValue[0]);
                      
    mux12#(`DATA_SIZE*2) aluIn0Mux0(inDatas, hBus, vBus,           ,, aluIn0Sel[0], aluIn0[0]);
    mux12#(`DATA_SIZE*2) aluIn1Mux0(inDatas, hBus, vBus, storedData,, aluIn1Sel[0], aluIn1[0]);
    
    mux4#(`DATA_SIZE) dataLoInMux0(increasedDataLo, decreasedDataLo, aluIn0[0][`DATA_SIZE-1:0], nextDataLo[0], dataLoSel[0], selectedDataLo[0]);
    
    validNotZero#(`DATA_SIZE) aluIn0NE0(aluIn0[0][`DATA_SIZE-1:0], aluIn0LoValidBits[0], aluIn0LoExcludeLSB[0], aluIn0LoNotZero[0]);
    validAllOn  #(`DATA_SIZE) aluIn0AO0(aluIn0[0][`DATA_SIZE-1:0], aluIn0LoValidBits[0], aluIn0LoExcludeLSB[0], aluIn0LoIsAllOn[0]);

    validNotZero#(`DATA_SIZE) aluIn1NE0(aluIn1[0][`DATA_SIZE-1:0], aluIn1LoValidBits[0], aluIn1LoExcludeLSB[0], aluIn1LoNotZero[0]);
    validAllOn  #(`DATA_SIZE) aluIn1AO0(aluIn1[0][`DATA_SIZE-1:0], aluIn1LoValidBits[0], aluIn1LoExcludeLSB[0], aluIn1LoIsAllOn[0]);
    
    equal#(`DATA_SIZE-1) tagEqual0(aluIn0[0][`DATA_SIZE*2-2:`DATA_SIZE], storedData[`DATA_SIZE*2-2:`DATA_SIZE], aluIn0HiEqDataHi[0]);
    
    alu alu0(aluIn0[0], aluIn1[0], aluFuncSel[0], aluOuts[0]);
    
    /* The logic of insts[1] */
    
    instDecoder dec1(insts[1],
                     inDataReadys,
                     isOutputFulls,
                     aluIn0LoNotZero[1], aluIn0LoIsAllOn[1], aluIn0HiEqDataHi[1],
                     aluIn1LoNotZero[1], aluIn1LoIsAllOn[1],
                     dataLoIsZero,
                     storedData[`DATA_SIZE*2-1:`DATA_SIZE],
                     readInputs[1],
                     writeOutputs[1],
                     writeDataHi[1], nextDataHi[1],
                     writeDataLo[1], nextDataLo[1], dataLoSel[1],
                     aluIn0Sel[1], aluIn1Sel[1], aluFuncSel[1],
                     aluIn0LoValidBits[1], aluIn1LoValidBits[1],
                     aluIn0LoExcludeLSB[1], aluIn1LoExcludeLSB[1],
                     busValidPart[1], busExtraBitToSet[1], busExtraBitValue[1]);
                      
    mux12#(`DATA_SIZE*2) aluIn0Mux1(inDatas, hBus, vBus,           ,, aluIn0Sel[1], aluIn0[1]);
    mux12#(`DATA_SIZE*2) aluIn1Mux1(inDatas, hBus, vBus, storedData,, aluIn1Sel[1], aluIn1[1]);
    
    mux4#(`DATA_SIZE) dataLoInMux1(increasedDataLo, decreasedDataLo, aluIn0[1][`DATA_SIZE-1:0], nextDataLo[1], dataLoSel[1], selectedDataLo[1]);
    
    validNotZero#(`DATA_SIZE) aluIn0NE1(aluIn0[1][`DATA_SIZE-1:0], aluIn0LoValidBits[1], aluIn0LoExcludeLSB[1], aluIn0LoNotZero[1]);
    validAllOn  #(`DATA_SIZE) aluIn0AO1(aluIn0[1][`DATA_SIZE-1:0], aluIn0LoValidBits[1], aluIn0LoExcludeLSB[1], aluIn0LoIsAllOn[1]);

    validNotZero#(`DATA_SIZE) aluIn1NE1(aluIn1[1][`DATA_SIZE-1:0], aluIn1LoValidBits[1], aluIn1LoExcludeLSB[1], aluIn1LoNotZero[1]);
    validAllOn  #(`DATA_SIZE) aluIn1AO1(aluIn1[1][`DATA_SIZE-1:0], aluIn1LoValidBits[1], aluIn1LoExcludeLSB[1], aluIn1LoIsAllOn[1]);
    
    equal#(`DATA_SIZE-1) tagEqual1(aluIn0[1][`DATA_SIZE*2-2:`DATA_SIZE], storedData[`DATA_SIZE*2-2:`DATA_SIZE], aluIn0HiEqDataHi[1]);
    
    alu alu1(aluIn0[1], aluIn1[1], aluFuncSel[1], aluOuts[1]);
    
    /* Combine the output of both instruction */
    
    wire [`DATA_SIZE*2-1:0] dataToWrite [7:0];
    
    select2#(`DATA_SIZE*2) sel0(aluOuts[0], aluOuts[1], writeOutputs[0][0], writeOutputs[1][0], dataToWrite[0]);
    select2#(`DATA_SIZE*2) sel1(aluOuts[0], aluOuts[1], writeOutputs[0][1], writeOutputs[1][1], dataToWrite[1]);
    select2#(`DATA_SIZE*2) sel2(aluOuts[0], aluOuts[1], writeOutputs[0][2], writeOutputs[1][2], dataToWrite[2]);
    select2#(`DATA_SIZE*2) sel3(aluOuts[0], aluOuts[1], writeOutputs[0][3], writeOutputs[1][3], dataToWrite[3]);
    select2#(`DATA_SIZE*2) sel4(aluOuts[0], aluOuts[1], writeOutputs[0][4], writeOutputs[1][4], dataToWrite[4]);
    select2#(`DATA_SIZE*2) sel5(aluOuts[0], aluOuts[1], writeOutputs[0][5], writeOutputs[1][5], dataToWrite[5]);
    select2#(`DATA_SIZE*2) sel6(aluOuts[0], aluOuts[1], writeOutputs[0][6], writeOutputs[1][6], dataToWrite[6]);
    select2#(`DATA_SIZE*2) sel7(aluOuts[0], aluOuts[1], writeOutputs[0][7], writeOutputs[1][7], dataToWrite[7]);
    
    busOutMux hBusMux(aluOuts[0], aluOuts[1], busValidPart[0][0], busValidPart[1][0], busExtraBitToSet[0][0], busExtraBitToSet[1][0], busExtraBitValue[0][0], busExtraBitValue[1][0], hBus);
    busOutMux vBusMux(aluOuts[0], aluOuts[1], busValidPart[0][1], busValidPart[1][1], busExtraBitToSet[0][1], busExtraBitToSet[1][1], busExtraBitValue[0][1], busExtraBitValue[1][1], vBus);
    
    fifo_n#(`DATA_SIZE*2) outFIFO_U0 (clk, dataToWrite[0], readOutDatas[0], writeOutputs[0][0] | writeOutputs[1][0], outDatas[0], isOutputFulls[0], isOutputEmptys[0]);
    fifo_n#(`DATA_SIZE*2) outFIFO_U1 (clk, dataToWrite[1], readOutDatas[1], writeOutputs[0][1] | writeOutputs[1][1], outDatas[1], isOutputFulls[1], isOutputEmptys[1]);
    fifo_n#(`DATA_SIZE*2) outFIFO_D0 (clk, dataToWrite[2], readOutDatas[2], writeOutputs[0][2] | writeOutputs[1][2], outDatas[2], isOutputFulls[2], isOutputEmptys[2]);
    fifo_n#(`DATA_SIZE*2) outFIFO_D1 (clk, dataToWrite[3], readOutDatas[3], writeOutputs[0][3] | writeOutputs[1][3], outDatas[3], isOutputFulls[3], isOutputEmptys[3]);
    fifo_n#(`DATA_SIZE*2) outFIFO_L0 (clk, dataToWrite[4], readOutDatas[4], writeOutputs[0][4] | writeOutputs[1][4], outDatas[4], isOutputFulls[4], isOutputEmptys[4]);
    fifo_n#(`DATA_SIZE*2) outFIFO_L1 (clk, dataToWrite[5], readOutDatas[5], writeOutputs[0][5] | writeOutputs[1][5], outDatas[5], isOutputFulls[5], isOutputEmptys[5]);
    fifo_n#(`DATA_SIZE*2) outFIFO_R0 (clk, dataToWrite[6], readOutDatas[6], writeOutputs[0][6] | writeOutputs[1][6], outDatas[6], isOutputFulls[6], isOutputEmptys[6]);
    fifo_n#(`DATA_SIZE*2) outFIFO_R1 (clk, dataToWrite[7], readOutDatas[7], writeOutputs[0][7] | writeOutputs[1][7], outDatas[7], isOutputFulls[7], isOutputEmptys[7]);
    
    assign readInDatas[0] = readInputs[0][0] | readInputs[1][0];
    assign readInDatas[1] = readInputs[0][1] | readInputs[1][1];
    assign readInDatas[2] = readInputs[0][2] | readInputs[1][2];
    assign readInDatas[3] = readInputs[0][3] | readInputs[1][3];
    assign readInDatas[4] = readInputs[0][4] | readInputs[1][4];
    assign readInDatas[5] = readInputs[0][5] | readInputs[1][5];
    assign readInDatas[6] = readInputs[0][6] | readInputs[1][6];
    assign readInDatas[7] = readInputs[0][7] | readInputs[1][7];
    
    always @(posedge clk) begin
        if (writeDataHi[0] & writeDataHi[1])
        begin
            $display("%m: Both instruction want to modify DataHi!");
            $finish;
        end
        else if (writeDataHi[0]) begin
            storedData[`DATA_SIZE*2-1:`DATA_SIZE] <= nextDataHi[0];
        end
        else if (writeDataHi[1]) begin
            storedData[`DATA_SIZE*2-1:`DATA_SIZE] <= nextDataHi[1];
        end
        
        if (writeDataLo[0] & writeDataLo[1])
        begin
            $display("%m: Both instruction want to modify DataLo!");
            $finish;
        end
        else if (writeDataLo[0]) begin
            storedData[`DATA_SIZE-1:0] <= selectedDataLo[0];
        end
        else if (writeDataLo[1]) begin
            storedData[`DATA_SIZE-1:0] <= selectedDataLo[1];
        end
    end

endmodule

