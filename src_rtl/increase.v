module increase#(parameter DATA_SIZE = 8)
                (input [DATA_SIZE-1:0] in, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] outReg;
    
    assign out = outReg;
    
    always @* begin
        outReg = in+1;
    end
endmodule
