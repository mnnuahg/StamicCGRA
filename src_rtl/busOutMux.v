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
