module equal#(parameter DATA_SIZE = 8)
             (input [DATA_SIZE-1:0] in0, input [DATA_SIZE-1:0] in1, output out);
    reg outReg;
    
    assign out = outReg;
    
    always @* begin
        outReg = (in0 == in1);
    end
endmodule
