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

