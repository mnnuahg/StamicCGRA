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
            `OP_SELECT_PRED: begin
                aluFuncSelReg = `ALU_FUNC_IN1;
                aluIn0SelReg = arg2;
                if (isInputReadys[arg0] && isInputReadys[arg1] && isInputReadys[arg2] && !isOutputFulls[arg3]) begin
                    readInputsReg[arg0] = 1;
                    readInputsReg[arg1] = 1;
                    readInputsReg[arg2] = 1;
                    writeOutputsReg[arg3] = 1;
                    if (aluIn0LoNotZero) begin
                        aluIn1SelReg = arg0;
                    end
                    else begin
                        aluIn1SelReg = arg1;
                    end
                end
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
            `OP_OX: begin
                aluFuncSelReg = `ALU_FUNC_IN1;
                if (!isOutputFulls[arg2]) begin
                    if (isInputReadys[arg0]) begin
                        aluIn1SelReg = arg0;
                        readInputsReg[arg0] = 1;
                        writeOutputsReg[arg2] = 1;
                    end
                    else if (isInputReadys[arg1]) begin
                        aluIn1SelReg = arg1;
                        readInputsReg[arg1] = 1;
                        writeOutputsReg[arg2] = 1;
                    end
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
