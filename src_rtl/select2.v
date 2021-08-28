module select2#(parameter DATA_SIZE = 8)
               (input [DATA_SIZE-1:0] in0, input [DATA_SIZE-1:0] in1, input sel0, input sel1, output [DATA_SIZE-1:0] out);
    reg [DATA_SIZE-1:0] outReg;
    
    assign out = outReg;
    
    always @* begin
        outReg = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        if (sel0 && !sel1)
            outReg = in0;
        else if (!sel0 && sel1)
            outReg = in1;
        else if (sel0 && sel1)
        begin
            $display("%m: sel0 and sel1 are both on!");
            $finish;
        end
    end
endmodule
