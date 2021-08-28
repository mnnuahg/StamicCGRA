module mux8#(parameter DATA_SIZE = 8)
       (input [7:0][DATA_SIZE-1:0] in, input [2:0] sel, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] outReg;
    
    assign out = outReg;
    
    always @* begin
        outReg = in[sel];
    end
endmodule
