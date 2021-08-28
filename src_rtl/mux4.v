module mux4#(parameter DATA_SIZE = 8)
       (input [DATA_SIZE-1:0] in0, input [DATA_SIZE-1:0] in1, input [DATA_SIZE-1:0] in2, input [DATA_SIZE-1:0] in3, input [1:0] sel, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] outReg;
    
    assign out = outReg;
    
    always @* begin
        case (sel)
            0: outReg = in0;
            1: outReg = in1;
            2: outReg = in2;
            3: outReg = in3;
        endcase
    end
endmodule
