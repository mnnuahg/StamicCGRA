module mux12#(parameter DATA_SIZE = 8)
       (input [7:0][DATA_SIZE-1:0] in0_7,
        input [DATA_SIZE-1:0] in8,
        input [DATA_SIZE-1:0] in9,
        input [DATA_SIZE-1:0] in10,
        input [DATA_SIZE-1:0] in11, 
        input [3:0] sel, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] outReg;
    
    assign out = outReg;
    
    always @* begin
        if (sel[3] == 0)
            outReg = in0_7[sel];
        else if (sel == 8)
            outReg = in8;
        else if (sel == 9)
            outReg = in9;
        else if (sel == 10)
            outReg = in10;
        else
            outReg = in11;
    end
endmodule
