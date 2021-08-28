module isZero#(parameter DATA_SIZE = 8)
              (input [DATA_SIZE-1:0] in, output out);
    reg outReg;
    
    assign out = outReg;
    
    always @* begin
        outReg = (in == 0);
    end
endmodule
