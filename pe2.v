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

`define DIR_U0          0
`define DIR_U1          1
`define DIR_D0          2
`define DIR_D1          3
`define DIR_L0          4
`define DIR_L1          5
`define DIR_R0          6
`define DIR_R1          7

`define DATA_SEL_INC    0
`define DATA_SEL_DEC    1
`define DATA_SEL_TOKEN  2
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

`define STATE_INIT              0
`define STATE_ALREADY_FWD_NEAR  1
`define STATE_ALREADY_FWD_FAR   2
`define STATE_DELAY_FWD_NEAR    3
`define STATE_DONT_DELAY_FWD    4
`define STATE_WAIT_ARRIVE       5

`define INST_SIZE       32
`define DATA_SIZE       8 

module select2#(parameter DATA_SIZE = 8)
               (input [DATA_SIZE-1:0] in0, input [DATA_SIZE-1:0] in1, input sel0, input sel1, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] out;
    
    always @* begin
        out = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        if (sel0 && !sel1)
            out = in0;
        else if (!sel0 && sel1)
            out = in1;
        else if (sel0 && sel1)
        begin
            $display("%m: sel0 and sel1 are both on!");
            $finish;
        end
    end
endmodule

module mux2#(parameter DATA_SIZE = 8)
       (input [DATA_SIZE-1:0] in0, input [DATA_SIZE-1:0] in1, input sel, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] out;
    
    always @* begin
        case (sel)
            0: out = in0;
            1: out = in1;
        endcase
    end
endmodule

module mux4#(parameter DATA_SIZE = 8)
       (input [DATA_SIZE-1:0] in0, input [DATA_SIZE-1:0] in1, input [DATA_SIZE-1:0] in2, input [DATA_SIZE-1:0] in3, input [1:0] sel, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] out;
    
    always @* begin
        case (sel)
            0: out = in0;
            1: out = in1;
            2: out = in2;
            3: out = in3;
        endcase
    end
endmodule

module mux8#(parameter DATA_SIZE = 8)
       (input [7:0][DATA_SIZE-1:0] in, input [2:0] sel, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] out;
    
    always @* begin
        out = in[sel];
    end
endmodule

module increase#(parameter DATA_SIZE = 8)
                (input [DATA_SIZE-1:0] in, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] out;
    
    always @* begin
        out = in+1;
    end
endmodule

module decrease#(parameter DATA_SIZE = 8)
                (input [DATA_SIZE-1:0] in, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] out;
    
    always @* begin
        out = in-1;
    end
endmodule

module equal#(parameter DATA_SIZE = 8)
             (input [DATA_SIZE-1:0] in0, input [DATA_SIZE-1:0] in1, output out);
    reg out;
    
    always @* begin
        out = (in0 == in1);
    end
endmodule

module isZero#(parameter DATA_SIZE = 8)
              (input [DATA_SIZE-1:0] in, output out);
    reg out;
    
    always @* begin
        out = (in == 0);
    end
endmodule

module notZero#(parameter DATA_SIZE = 8)
               (input [DATA_SIZE-1:0] in, output out);
    reg out;
    
    always @* begin
        out = (in != 0);
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
     input dataHiMatchTag, input dataLoIsZero, input predIsTrue, input [`DATA_SIZE-1:0] dataHiIn,
     output [7:0] readInputs,
     output [7:0] writeOutputs,
     output writeDataHi, output [`DATA_SIZE-1:0] dataHiOut,
     output writeDataLo, output [`DATA_SIZE-1:0] dataLoOut, output [1:0] dataLoSel,
     output [2:0] aluIn0Sel, output [2:0] aluIn1Sel, output aluIn1FromData, output [3:0] aluFuncSel);
    
    reg [7:0] readInputs;
    reg [7:0] writeOutputs;
    reg writeDataHi;
    reg writeDataLo;
    reg [`DATA_SIZE-1:0] dataHiOut;
    reg [`DATA_SIZE-1:0] dataLoOut;
    reg [1:0] dataLoSel;
    reg [2:0] aluIn0Sel;
    reg [2:0] aluIn1Sel;
    reg aluIn1FromData;
    reg [3:0] aluFuncSel;
    
    wire [ 5:0]  op;
    wire [13:0] imm;
    wire [ 2:0] arg0, arg1, arg2, arg3;
    
    instFieldDecoder dec(inst, op, imm, arg0, arg1, arg2, arg3);
    
    // Only used in OP_SYNC but verilog don't allow local scope wire
    wire [3:0] distNear = imm[7:4];
    wire [3:0] distFar  = imm[3:0];
    wire [3:0] delay = distFar - distNear;
    
    always @* begin    
        readInputs = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
        writeOutputs = {1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};
        writeDataHi = 1'b0;
        writeDataLo = 1'b0;
        dataHiOut = 8'bxxxxxxxx;
        dataLoOut = 8'bxxxxxxxx;
        dataLoSel = 2'bxx;
        aluIn0Sel = 3'bxxx;
        aluIn1Sel = 3'bxxx;
        aluIn1FromData = 1'bx;
        aluFuncSel = 3'bxxx;
    
        case (op)
            `OP_NOP: begin
            end
            `OP_DISCARD: begin
                aluFuncSel = `ALU_FUNC_IN1;
                if (isInputReadys[arg0])
                    readInputs[arg0] = 1;
                if (isInputReadys[arg1])
                    readInputs[arg1] = 1;
                if (isInputReadys[arg2])
                    readInputs[arg2] = 1;
                if (isInputReadys[arg3])
                    readInputs[arg3] = 1;
            end
            `OP_MOV1_2: begin
                aluIn1Sel = arg0;
                aluIn1FromData = 0;
                aluFuncSel = `ALU_FUNC_IN1;
                if (isInputReadys[arg0] && !isOutputFulls[arg1] && !isOutputFulls[arg2]) begin
                    readInputs[arg0] = 1;
                    writeOutputs[arg1] = 1;
                    writeOutputs[arg2] = 1;
                end
            end
            `OP_MOV2_1: begin
                dataHiOut = dataHiIn;
                writeDataHi = 1;
                if (isOutputFulls[arg2]) begin
                    $display("Tag matching unit jammed in %m\n");
                    $finish;
                end
                if (isInputReadys[arg1] && !isOutputFulls[arg2]) begin
                    aluIn1Sel = arg1;
                    aluIn1FromData = 0;
                    aluFuncSel = `ALU_FUNC_IN1;
                    readInputs[arg1] = 1;
                    writeOutputs[arg2] = 1;
                end
                else if (isInputReadys[arg0] && !isOutputFulls[arg2]) begin
                    aluIn1Sel = arg0;
                    aluIn1FromData = 0;
                    aluFuncSel = `ALU_FUNC_IN1;
                    readInputs[arg0] = 1;
                    writeOutputs[arg2] = 1;
                end
            end
            `OP_ADD: begin
                if (isInputReadys[arg0] && isInputReadys[arg1] && !isOutputFulls[arg2]) begin
                    aluIn0Sel = arg0;
                    aluIn1Sel = arg1;
                    aluIn1FromData = 0;
                    aluFuncSel = `ALU_FUNC_ADD;
                    readInputs[arg0] = 1;
                    readInputs[arg1] = 1;
                    writeOutputs[arg2] = 1;
                end
            end
            `OP_AND: begin
                if (isInputReadys[arg0] && isInputReadys[arg1] && !isOutputFulls[arg2]) begin
                    aluIn0Sel = arg0;
                    aluIn1Sel = arg1;
                    aluIn1FromData = 0;
                    aluFuncSel = `ALU_FUNC_AND;
                    readInputs[arg0] = 1;
                    readInputs[arg1] = 1;
                    writeOutputs[arg2] = 1;
                end
            end
            `OP_SYNC: begin
                dataHiOut = dataHiIn;
                writeDataHi = 1;
                aluIn1Sel = arg0;
                aluIn1FromData = 0;
                aluFuncSel = `ALU_FUNC_IN1;
                case (dataHiIn)
                    `STATE_INIT: begin
                        if (isInputReadys[arg0] && isInputReadys[arg1] && isInputReadys[arg2] && delay == 0) begin
                            dataHiOut = `STATE_WAIT_ARRIVE;
                            dataLoOut = distFar - 1;
                            writeDataLo = 1;
                            dataLoSel = `DATA_SEL_DECODE;
                            readInputs[arg1] = 1;
                            readInputs[arg2] = 1;
                            writeOutputs[arg1] = 1;
                            writeOutputs[arg2] = 1;
                        end
                        else if (isInputReadys[arg0] && (isInputReadys[arg1] || distNear==0) && (!isInputReadys[arg2] || delay>0)) begin
                            dataHiOut = `STATE_ALREADY_FWD_FAR;
                            readInputs[arg1] = isInputReadys[arg1];
                            writeOutputs[arg2] = 1;
                        end
                        else if (isInputReadys[arg0] && !(isInputReadys[arg1] || distNear==0) && isInputReadys[arg2]) begin
                            dataHiOut = `STATE_ALREADY_FWD_NEAR;
                            readInputs[arg2] = 1;
                            writeOutputs[arg1] = 1;
                        end
                    end
                    `STATE_ALREADY_FWD_NEAR: begin
                        if (isInputReadys[arg1]) begin
                            dataHiOut = `STATE_WAIT_ARRIVE;
                            dataLoOut = distFar - 1;
                            writeDataLo = 1;
                            dataLoSel = `DATA_SEL_DECODE;
                            readInputs[arg1] = 1;
                            writeOutputs[arg2] = 1;
                        end
                    end
                    `STATE_ALREADY_FWD_FAR: begin
                        if (isInputReadys[arg2] && delay<=1 && distNear==0) begin
                            if (!isOutputFulls[arg3]) begin
                                dataHiOut = `STATE_INIT;
                                readInputs[arg0] = 1;
                                readInputs[arg2] = 1;
                                writeOutputs[arg3] = 1;
                            end
                        end
                        else if (isInputReadys[arg2] && delay<=1 && distNear>0) begin
                            dataHiOut = `STATE_WAIT_ARRIVE;
                            dataLoOut = distNear - 1;
                            writeDataLo = 1;
                            dataLoSel = `DATA_SEL_DECODE;
                            readInputs[arg2] = 1;
                            writeOutputs[arg1] = 1;
                        end
                        else if (isInputReadys[arg2] && delay>1) begin
                            dataHiOut = `STATE_DELAY_FWD_NEAR;
                            dataLoOut = delay - 2;
                            writeDataLo = 1;
                            dataLoSel = `DATA_SEL_DECODE;
                        end
                        else begin
                            dataHiOut = `STATE_DONT_DELAY_FWD;
                        end
                    end
                    `STATE_DELAY_FWD_NEAR: begin
                        if (dataLoIsZero && distNear>0) begin
                            dataHiOut = `STATE_WAIT_ARRIVE;
                            dataLoOut = distNear - 1;
                            writeDataLo = 1;
                            dataLoSel = `DATA_SEL_DECODE;
                            readInputs[arg2] = 1;
                            writeOutputs[arg1] = 1;
                        end
                        else if (dataLoIsZero && distNear==0) begin
                            if (!isOutputFulls[arg3]) begin
                                dataHiOut = `STATE_INIT;
                                readInputs[arg0] = 1;
                                readInputs[arg2] = 1;
                                writeOutputs[arg3] = 1;
                            end
                        end
                        else begin
                            writeDataLo = 1;
                            dataLoSel = `DATA_SEL_DEC;
                        end
                    end
                    `STATE_DONT_DELAY_FWD: begin
                        if (isInputReadys[arg2] && distNear>0) begin
                            dataHiOut = `STATE_WAIT_ARRIVE;
                            dataLoOut = distNear - 1;
                            writeDataLo = 1;
                            dataLoSel = `DATA_SEL_DECODE;
                            readInputs[arg2] = 1;
                            writeOutputs[arg1] = 1;
                        end
                        else if (isInputReadys[arg2] && distNear==0) begin
                            if (!isOutputFulls[arg3]) begin
                                dataHiOut = `STATE_INIT;
                                readInputs[arg0] = 1;
                                readInputs[arg2] = 1;
                                writeOutputs[arg3] = 1;
                            end
                        end
                    end
                    `STATE_WAIT_ARRIVE: begin
                        if (dataLoIsZero) begin
                            if (!isOutputFulls[arg3]) begin
                                dataHiOut = `STATE_INIT;
                                readInputs[arg0] = 1;
                                writeOutputs[arg3] = 1;
                            end
                        end
                        else begin
                            writeDataLo = 1;
                            dataLoSel = `DATA_SEL_DEC;
                        end
                    end
                    default: begin
                        $display("Illegal state in %m\n");
                        $finish;
                    end
                endcase
            end
            `OP_SWITCH_PRED: begin
                aluIn0Sel = arg1;   // This is used to produce predIsTrue
                if (isInputReadys[arg0] && isInputReadys[arg1]) begin
                    aluIn1Sel = arg0;
                    aluIn1FromData = 0;
                    aluFuncSel = `ALU_FUNC_IN1;
                    if (predIsTrue && !isOutputFulls[arg2]) begin
                        readInputs[arg0] = 1;
                        readInputs[arg1] = 1;
                        writeOutputs[arg2] = 1;
                    end
                    else if (!predIsTrue && !isOutputFulls[arg3]) begin
                        readInputs[arg0] = 1;
                        readInputs[arg1] = 1;
                        writeOutputs[arg3] = 1;
                    end
                end
            end
            `OP_SWITCH_TAG: begin
                if (isInputReadys[arg1] && !isOutputFulls[arg3]) begin
                    aluIn1Sel = arg1;
                    aluIn1FromData = 0;
                    aluFuncSel = `ALU_FUNC_IN1;
                    readInputs[arg1] = 1;
                    writeOutputs[arg3] = 1;
                end
                else if (isInputReadys[arg0]) begin
                    aluIn1Sel = arg0;
                    aluIn1FromData = 0;
                    aluFuncSel = `ALU_FUNC_IN1;
                    if (dataHiMatchTag && !isOutputFulls[arg2]) begin
                        readInputs[arg0] = 1;
                        writeOutputs[arg2] = 1;
                    end
                    else if (!dataHiMatchTag && !isOutputFulls[arg3]) begin
                        readInputs[arg0] = 1;
                        writeOutputs[arg3] = 1;
                    end
                end
            end
            `OP_COMBINE_TAG: begin
                if (isInputReadys[arg0] && isInputReadys[arg1] && !isOutputFulls[arg2]) begin
                    aluIn0Sel = arg0;
                    aluIn1Sel = arg1;
                    aluIn1FromData = 0;
                    aluFuncSel = `ALU_FUNC_1H_0H;
                    readInputs[arg0] = 1;
                    readInputs[arg1] = 1;
                    writeOutputs[arg2] = 1;
                end
            end
            `OP_NEW_TAG: begin
                if (isInputReadys[arg0] && isInputReadys[arg1] && !isOutputFulls[arg2]) begin
                    aluIn0Sel = arg0;
                    aluIn1Sel = arg1;
                    aluIn1FromData = 0;
                    aluFuncSel = `ALU_FUNC_1H_0L;
                    readInputs[arg0] = 1;
                    readInputs[arg1] = 1;
                    writeOutputs[arg2] = 1;
                end
            end
            `OP_STORE_TAG: begin
                aluIn1Sel = arg0;   // This is used to produce dataHiMatchTag
                if (isInputReadys[arg0] && !isOutputFulls[arg1]) begin
                    aluIn1FromData = 0;
                    aluFuncSel = `ALU_FUNC_IN1;
                    readInputs[arg0] = 1;
                    writeOutputs[arg1] = 1;
                    if (dataHiMatchTag) begin
                        dataLoSel = `DATA_SEL_TOKEN;
                        writeDataLo = 1;
                    end
                end
            end
            `OP_RESTORE_TAG: begin
                aluIn1Sel = arg0;   // This is used to produce dataHiMatchTag
                if (isInputReadys[arg0] && !isOutputFulls[arg1]) begin
                    readInputs[arg0] = 1;
                    writeOutputs[arg1] = 1;
                    if (dataHiMatchTag) begin
                        aluIn0Sel = arg0;
                        aluIn1FromData = 1;
                        aluFuncSel = `ALU_FUNC_1L_0L;
                    end
                    else begin
                        aluIn1FromData = 0;
                        aluFuncSel = `ALU_FUNC_IN1;
                    end
                end
            end
            `OP_LOOP_HEAD: begin
                aluIn0Sel = arg1;   // This is used to produce predIsTrue
                if (isInputReadys[arg1] && !predIsTrue) begin
                    dataLoSel = `DATA_SEL_INC;
                    writeDataLo = 1;
                    readInputs[arg1] = 1;
                end
                if (isInputReadys[arg1] && predIsTrue && isInputReadys[arg2] && !isOutputFulls[arg3]) begin
                    aluIn1Sel = arg2;
                    aluIn1FromData = 0;
                    aluFuncSel = `ALU_FUNC_IN1;
                    readInputs[arg1] = 1;
                    readInputs[arg2] = 1;
                    writeOutputs[arg3] = 1;
                end
                else if (isInputReadys[arg0] && !dataLoIsZero && !isOutputFulls[arg3]) begin
                    dataLoSel = `DATA_SEL_DEC;
                    writeDataLo = 1;
                    aluIn1Sel = arg0;
                    aluIn1FromData = 0;
                    aluFuncSel = `ALU_FUNC_IN1;
                    readInputs[arg0] = 1;
                    writeOutputs[arg3] = 1;
                end
            end
            `OP_INV_DATA: begin
                if (isInputReadys[arg0] && !isOutputFulls[arg1]) begin
                    aluIn0Sel = arg0;
                    aluIn1FromData = 1;
                    aluFuncSel = `ALU_FUNC_0H_1L;
                    readInputs[arg0] = 1;
                    writeOutputs[arg1] = 1;
                end
            end
            `OP_ADD_DATA: begin
                if (isInputReadys[arg0] && !isOutputFulls[arg1]) begin
                    aluIn0Sel = arg0;
                    aluIn1FromData = 1;
                    aluFuncSel = `ALU_FUNC_ADD;
                    readInputs[arg0] = 1;
                    writeOutputs[arg1] = 1;
                end
            end
            `OP_LT_DATA: begin
                if (isInputReadys[arg0] && !isOutputFulls[arg1]) begin
                    aluIn0Sel = arg0;
                    aluIn1FromData = 1;
                    aluFuncSel = `ALU_FUNC_LT;
                    readInputs[arg0] = 1;
                    writeOutputs[arg1] = 1;
                end
            end
            `OP_EQ_DATA: begin
                if (isInputReadys[arg0] && !isOutputFulls[arg1]) begin
                    aluIn0Sel = arg0;
                    aluIn1FromData = 1;
                    aluFuncSel = `ALU_FUNC_EQ;
                    readInputs[arg0] = 1;
                    writeOutputs[arg1] = 1;
                end
            end
            `OP_NE_DATA: begin
                if (isInputReadys[arg0] && !isOutputFulls[arg1]) begin
                    aluIn0Sel = arg0;
                    aluIn1FromData = 1;
                    aluFuncSel = `ALU_FUNC_NE;
                    readInputs[arg0] = 1;
                    writeOutputs[arg1] = 1;
                end
            end
            `OP_ST: begin
                if (isInputReadys[arg0] && isInputReadys[arg1] && !isOutputFulls[arg2]) begin
                    aluIn0Sel = arg0;
                    aluIn1Sel = arg1;
                    aluIn1FromData = 0;
                    aluFuncSel = `ALU_FUNC_ST;
                    readInputs[arg0] = 1;
                    readInputs[arg1] = 1;
                    writeOutputs[arg2] = 1;
                end
            end
            default: begin
                $display("Illegal opcode in %m\n");
                $finish;
            end
        endcase
    end
    
endmodule

module alu(input [`DATA_SIZE*2-1:0] inData0,
           input [`DATA_SIZE*2-1:0] inData1,
           input [3:0] funcSel,
           output [`DATA_SIZE*2-1:0] outData);
    
    reg [`DATA_SIZE*2-1:0] outData;
    
    always @(inData0, inData1, funcSel) begin
        outData = 32'bx;
        case (funcSel)
            `ALU_FUNC_IN1:      outData = inData1;
            `ALU_FUNC_ADD:      outData = {inData0[`DATA_SIZE*2-1:`DATA_SIZE], inData0[`DATA_SIZE-1:0] + inData1[`DATA_SIZE-1:0]};
            `ALU_FUNC_MUL:      outData = {inData0[`DATA_SIZE*2-1:`DATA_SIZE], inData0[`DATA_SIZE-1:0] * inData1[`DATA_SIZE-1:0]};
            `ALU_FUNC_AND:      outData = {inData0[`DATA_SIZE*2-1:`DATA_SIZE], inData0[`DATA_SIZE-1:0] & inData1[`DATA_SIZE-1:0]};
            `ALU_FUNC_1H_0L:    outData = {inData1[`DATA_SIZE*2-1:`DATA_SIZE], inData0[`DATA_SIZE-1:0]};
            `ALU_FUNC_1L_0L:    outData = {inData1[`DATA_SIZE-1:0],            inData0[`DATA_SIZE-1:0]};
            `ALU_FUNC_1H_0H:    outData = {inData1[`DATA_SIZE*2-1:`DATA_SIZE], inData0[`DATA_SIZE*2-1:`DATA_SIZE]};
            `ALU_FUNC_0H_1L:    outData = {inData0[`DATA_SIZE*2-1:`DATA_SIZE], inData1[`DATA_SIZE-1:0]};
            `ALU_FUNC_LT: begin
                outData = 0;
                outData[`DATA_SIZE*2-1:`DATA_SIZE] = inData0[`DATA_SIZE*2-1:`DATA_SIZE];
                outData[0] = inData0[`DATA_SIZE-1:0] < inData1[`DATA_SIZE-1:0] ? 1 : 0;
            end
            `ALU_FUNC_EQ: begin
                outData = 0;
                outData[`DATA_SIZE*2-1:`DATA_SIZE] = inData0[`DATA_SIZE*2-1:`DATA_SIZE];
                outData[0] = inData0[`DATA_SIZE-1:0] == inData1[`DATA_SIZE-1:0] ? 1 : 0;
            end
            `ALU_FUNC_NE: begin
                outData = 0;
                outData[`DATA_SIZE*2-1:`DATA_SIZE] = inData0[`DATA_SIZE*2-1:`DATA_SIZE];
                outData[0] = (inData0[`DATA_SIZE-1:0] != inData1[`DATA_SIZE-1:0]) ? 1 : 0;
            end
            `ALU_FUNC_ST: begin
                outData = inData0;
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
           input [7:0] readOutDatas);
     
    /* The default op is to consume all inputs and produce no outputs */
    
    parameter OP0 = `OP_NOP;
    parameter Imm0 = 0;
    parameter Arg00 = `DIR_U0;
    parameter Arg01 = `DIR_D0;
    parameter Arg02 = `DIR_L0;
    parameter Arg03 = `DIR_R0;
    
    parameter OP1 = `OP_NOP;
    parameter Imm1 = 0;
    parameter Arg10 = `DIR_U1;
    parameter Arg11 = `DIR_D1;
    parameter Arg12 = `DIR_L1;
    parameter Arg13 = `DIR_R1;
    
    parameter DataLo = 0;
    parameter DataHi = 0;
    
    parameter U0Tok0 = -1;
    parameter U0Tok1 = -1;
    parameter U1Tok0 = -1;
    parameter U1Tok1 = -1;
    parameter D0Tok0 = -1;
    parameter D0Tok1 = -1;
    parameter D1Tok0 = -1;
    parameter D1Tok1 = -1;
    parameter L0Tok0 = -1;
    parameter L0Tok1 = -1;
    parameter L1Tok0 = -1;
    parameter L1Tok1 = -1;
    parameter R0Tok0 = -1;
    parameter R0Tok1 = -1;
    parameter R1Tok0 = -1;
    parameter R1Tok1 = -1;
    
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
    wire dataHiMatchTag [1:0];
    wire predIsTrue [1:0];
    wire [7:0] readInputs [1:0];
    wire [7:0] writeOutputs [1:0];
    wire writeDataHi [1:0];
    wire writeDataLo [1:0];
    wire [`DATA_SIZE-1:0] nextDataHi [1:0];
    wire [`DATA_SIZE-1:0] nextDataLo [1:0];
    wire [1:0] dataLoSel [1:0];
    wire [2:0] aluIn0Sel [1:0];
    wire [2:0] aluIn1Sel [1:0];
    wire aluIn1FromData [1:0];
    wire [3:0] aluFuncSel [1:0];
    
    wire [`DATA_SIZE*2-1:0] aluIn0 [1:0];
    wire [`DATA_SIZE*2-1:0] aluIn1 [1:0];
    wire [`DATA_SIZE*2-1:0] aluIn1Temp [1:0];
    
    wire [`DATA_SIZE-1:0] tagFromToken [1:0];
    wire [`DATA_SIZE-1:0] tagToStore [1:0];
    wire [`DATA_SIZE-1:0] predFromToken [1:0];
    wire [`DATA_SIZE-1:0] selectedDataLo [1:0];
    
    /* The logic of insts[0] */
    
    instDecoder dec0 (insts[0],
                      inDataReadys,
                      isOutputFulls,
                      dataHiMatchTag[0],
                      dataLoIsZero,
                      predIsTrue[0],
                      storedData[`DATA_SIZE*2-1:`DATA_SIZE],
                      readInputs[0],
                      writeOutputs[0],
                      writeDataHi[0], nextDataHi[0],
                      writeDataLo[0], nextDataLo[0], dataLoSel[0],
                      aluIn0Sel[0], aluIn1Sel[0], aluIn1FromData[0], aluFuncSel[0]);
                      
    mux8#(`DATA_SIZE*2) aluIn0Mux0(inDatas, aluIn0Sel[0], aluIn0[0]);
    mux8#(`DATA_SIZE*2) aluIn1TempMux0(inDatas, aluIn1Sel[0], aluIn1Temp[0]);
    mux2#(`DATA_SIZE*2) aluIn1Mux0(aluIn1Temp[0], storedData, aluIn1FromData[0], aluIn1[0]);
    mux4#(`DATA_SIZE) dataLoInMux0(increasedDataLo, decreasedDataLo, tagToStore[0], nextDataLo[0], dataLoSel[0], selectedDataLo[0]);
    
    /* To reduce the amount of mux, the tokens to match tags are always aluIn0,
       and the pred tokens are always aluIn1Temp. */
    assign tagFromToken[0] = aluIn1Temp[0][`DATA_SIZE*2-1:`DATA_SIZE];
    assign tagToStore[0] = aluIn1Temp[0][`DATA_SIZE-1:0];
    assign predFromToken[0] = aluIn0[0][`DATA_SIZE-1:0];
    
    equal#(`DATA_SIZE) tagEqual0(tagFromToken[0], storedData[`DATA_SIZE*2-1:`DATA_SIZE], dataHiMatchTag[0]);
    notZero#(`DATA_SIZE) predTrue0(predFromToken[0], predIsTrue[0]);
    
    alu alu0(aluIn0[0], aluIn1[0], aluFuncSel[0], aluOuts[0]);
    
    /* The logic of insts[1] */
    
        instDecoder dec1 (insts[1],
                      inDataReadys,
                      isOutputFulls,
                      dataHiMatchTag[1],
                      dataLoIsZero,
                      predIsTrue[1],
                      storedData[`DATA_SIZE*2-1:`DATA_SIZE],
                      readInputs[1],
                      writeOutputs[1],
                      writeDataHi[1], nextDataHi[1],
                      writeDataLo[1], nextDataLo[1], dataLoSel[1],
                      aluIn0Sel[1], aluIn1Sel[1], aluIn1FromData[1], aluFuncSel[1]);
                      
    mux8#(`DATA_SIZE*2) aluIn0Mux1(inDatas, aluIn0Sel[1], aluIn0[1]);
    mux8#(`DATA_SIZE*2) aluIn1TempMux1(inDatas, aluIn1Sel[1], aluIn1Temp[1]);
    mux2#(`DATA_SIZE*2) aluIn1Mux1(aluIn1Temp[1], storedData, aluIn1FromData[1], aluIn1[1]);
    mux4#(`DATA_SIZE) dataLoInMux1(increasedDataLo, decreasedDataLo, tagToStore[1], nextDataLo[1], dataLoSel[1], selectedDataLo[1]);
    
    /* To reduce the amount of mux, the tokens to match tags are always aluIn0,
       and the pred tokens are always aluIn1Temp. */
    assign tagFromToken[1] = aluIn1Temp[1][`DATA_SIZE*2-1:`DATA_SIZE];
    assign tagToStore[1] = aluIn1Temp[1][`DATA_SIZE-1:0];
    assign predFromToken[1] = aluIn0[1][`DATA_SIZE-1:0];
    
    equal#(`DATA_SIZE) tagEqual1(tagFromToken[1], storedData[`DATA_SIZE*2-1:`DATA_SIZE], dataHiMatchTag[1]);
    notZero#(`DATA_SIZE) predTrue1(predFromToken[1], predIsTrue[1]);
    
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
    
    initial begin
        insts[0][31:26] = OP0;
        insts[0][25:12] = Imm0;
        insts[0][11:9] = Arg00;
        insts[0][8:6] = Arg01;
        insts[0][5:3] = Arg02;
        insts[0][2:0] = Arg03;
        
        insts[1][31:26] = OP1;
        insts[1][25:12] = Imm1;
        insts[1][11:9] = Arg10;
        insts[1][8:6] = Arg11;
        insts[1][5:3] = Arg12;
        insts[1][2:0] = Arg13;
        
        storedData[`DATA_SIZE*2-1:`DATA_SIZE] = DataHi;
        storedData[`DATA_SIZE-1:0] = DataLo;
        
        // Initialize tokens
        // Problem: What if FIFO has its initial block?
        
        outFIFO_U0.isFull = 0;
        outFIFO_U0.readHead = 0;
        if (U0Tok1 != -1 && U0Tok0 == -1) begin
            $display("%m: Token 0 can't be -1 while token 1 is not -1");
            $finish;
        end
        else if (U0Tok1 != -1 && U0Tok0 != -1) begin
            outFIFO_U0.isEmpty = 0;
            outFIFO_U0.regs[0] = U0Tok0;
            outFIFO_U0.regs[1] = U0Tok1;
            outFIFO_U0.writeHead = 2;
        end
        else if (U0Tok0 != -1) begin
            outFIFO_U0.isEmpty = 0;
            outFIFO_U0.regs[0] = U0Tok0;
            outFIFO_U0.writeHead = 1;
        end
        else begin
            outFIFO_U0.isEmpty = 1;
            outFIFO_U0.writeHead = 0;
        end
        
        outFIFO_U1.isFull = 0;
        outFIFO_U1.readHead = 0;
        if (U1Tok1 != -1 && U1Tok0 == -1) begin
            $display("%m: Token 0 can't be -1 while token 1 is not -1");
            $finish;
        end
        else if (U1Tok1 != -1 && U1Tok0 != -1) begin
            outFIFO_U1.isEmpty = 0;
            outFIFO_U1.regs[0] = U1Tok0;
            outFIFO_U1.regs[1] = U1Tok1;
            outFIFO_U1.writeHead = 2;
        end
        else if (U1Tok0 != -1) begin
            outFIFO_U1.isEmpty = 0;
            outFIFO_U1.regs[0] = U1Tok0;
            outFIFO_U1.writeHead = 1;
        end
        else begin
            outFIFO_U1.isEmpty = 1;
            outFIFO_U1.writeHead = 0;
        end
        
        outFIFO_D0.isFull = 0;
        outFIFO_D0.readHead = 0;
        if (D0Tok1 != -1 && D0Tok0 == -1) begin
            $display("%m: Token 0 can't be -1 while token 1 is not -1");
            $finish;
        end
        else if (D0Tok1 != -1 && D0Tok0 != -1) begin
            outFIFO_D0.isEmpty = 0;
            outFIFO_D0.regs[0] = D0Tok0;
            outFIFO_D0.regs[1] = D0Tok1;
            outFIFO_D0.writeHead = 2;
        end
        else if (D0Tok0 != -1) begin
            outFIFO_D0.isEmpty = 0;
            outFIFO_D0.regs[0] = D0Tok0;
            outFIFO_D0.writeHead = 1;
        end
        else begin
            outFIFO_D0.isEmpty = 1;
            outFIFO_D0.writeHead = 0;
        end
        
        outFIFO_D1.isFull = 0;
        outFIFO_D1.readHead = 0;
        if (D1Tok1 != -1 && D1Tok0 == -1) begin
            $display("%m: Token 0 can't be -1 while token 1 is not -1");
            $finish;
        end
        else if (D1Tok1 != -1 && D1Tok0 != -1) begin
            outFIFO_D1.isEmpty = 0;
            outFIFO_D1.regs[0] = D1Tok0;
            outFIFO_D1.regs[1] = D1Tok1;
            outFIFO_D1.writeHead = 2;
        end
        else if (D1Tok0 != -1) begin
            outFIFO_D1.isEmpty = 0;
            outFIFO_D1.regs[0] = D1Tok0;
            outFIFO_D1.writeHead = 1;
        end
        else begin
            outFIFO_D1.isEmpty = 1;
            outFIFO_D1.writeHead = 0;
        end
        
        outFIFO_L0.isFull = 0;
        outFIFO_L0.readHead = 0;
        if (L0Tok1 != -1 && L0Tok0 == -1) begin
            $display("%m: Token 0 can't be -1 while token 1 is not -1");
            $finish;
        end
        else if (L0Tok1 != -1 && L0Tok0 != -1) begin
            outFIFO_L0.isEmpty = 0;
            outFIFO_L0.regs[0] = L0Tok0;
            outFIFO_L0.regs[1] = L0Tok1;
            outFIFO_L0.writeHead = 2;
        end
        else if (L0Tok0 != -1) begin
            outFIFO_L0.isEmpty = 0;
            outFIFO_L0.regs[0] = L0Tok0;
            outFIFO_L0.writeHead = 1;
        end
        else begin
            outFIFO_L0.isEmpty = 1;
            outFIFO_L0.writeHead = 0;
        end
        
        outFIFO_L1.isFull = 0;
        outFIFO_L1.readHead = 0;
        if (L1Tok1 != -1 && L1Tok0 == -1) begin
            $display("%m: Token 0 can't be -1 while token 1 is not -1");
            $finish;
        end
        else if (L1Tok1 != -1 && L1Tok0 != -1) begin
            outFIFO_L1.isEmpty = 0;
            outFIFO_L1.regs[0] = L1Tok0;
            outFIFO_L1.regs[1] = L1Tok1;
            outFIFO_L1.writeHead = 2;
        end
        else if (L1Tok0 != -1) begin
            outFIFO_L1.isEmpty = 0;
            outFIFO_L1.regs[0] = L1Tok0;
            outFIFO_L1.writeHead = 1;
        end
        else begin
            outFIFO_L1.isEmpty = 1;
            outFIFO_L1.writeHead = 0;
        end
        
        outFIFO_R0.isFull = 0;
        outFIFO_R0.readHead = 0;
        if (R0Tok1 != -1 && R0Tok0 == -1) begin
            $display("%m: Token 0 can't be -1 while token 1 is not -1");
            $finish;
        end
        else if (R0Tok1 != -1 && R0Tok0 != -1) begin
            outFIFO_R0.isEmpty = 0;
            outFIFO_R0.regs[0] = R0Tok0;
            outFIFO_R0.regs[1] = R0Tok1;
            outFIFO_R0.writeHead = 2;
        end
        else if (R0Tok0 != -1) begin
            outFIFO_R0.isEmpty = 0;
            outFIFO_R0.regs[0] = R0Tok0;
            outFIFO_R0.writeHead = 1;
        end
        else begin
            outFIFO_R0.isEmpty = 1;
            outFIFO_R0.writeHead = 0;
        end
        
        outFIFO_R1.isFull = 0;
        outFIFO_R1.readHead = 0;
        if (R1Tok1 != -1 && R1Tok0 == -1) begin
            $display("%m: Token 0 can't be -1 while token 1 is not -1");
            $finish;
        end
        else if (R1Tok1 != -1 && R1Tok0 != -1) begin
            outFIFO_R1.isEmpty = 0;
            outFIFO_R1.regs[0] = R1Tok0;
            outFIFO_R1.regs[1] = R1Tok1;
            outFIFO_R1.writeHead = 2;
        end
        else if (R1Tok0 != -1) begin
            outFIFO_R1.isEmpty = 0;
            outFIFO_R1.regs[0] = R1Tok0;
            outFIFO_R1.writeHead = 1;
        end
        else begin
            outFIFO_R1.isEmpty = 1;
            outFIFO_R1.writeHead = 0;
        end
    end
    
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

