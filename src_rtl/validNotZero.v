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
