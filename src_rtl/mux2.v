module mux2#(parameter DATA_SIZE = 8)
       (input [DATA_SIZE-1:0] in0, input [DATA_SIZE-1:0] in1, input sel, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] outReg;
    
    assign out = outReg;
    
    always @* begin
        case (sel)
            0: outReg = in0;
            1: outReg = in1;
        endcase
    end
endmodule
