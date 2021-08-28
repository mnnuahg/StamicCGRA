module instFieldDecoder(input [`INST_SIZE-1:0] inst,
                        output [5:0] op, 
                        output [13:0] imm,
                        output [2:0] arg0, output [2:0] arg1, output [2:0] arg2, output [2:0] arg3);
    assign   op = inst[31:26];
    assign  imm = inst[25:12];
    assign arg0 = inst[11:9];
    assign arg1 = inst[8:6];
    assign arg2 = inst[5:3];
    assign arg3 = inst[2:0];
endmodule
