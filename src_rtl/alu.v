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
                $display("Store %d to %d", inData1[`DATA_SIZE-1:0], inData0[`DATA_SIZE-1:0]);
            end
        endcase
    end
endmodule
