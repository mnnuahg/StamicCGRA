`include "assert.v"

// initZero means whether to initialize the FIFO so it contains a token with zero value
module fifo_n#(parameter DATA_SIZE = 8)
    (input clk, input [DATA_SIZE-1:0] inData, input read, input write, output [DATA_SIZE-1:0] outData, output isFull, output isEmpty);

reg [DATA_SIZE-1:0] regs[3:0];
reg [1:0] readHead;
reg [1:0] writeHead;
reg isEmpty;
reg isFull;

assign outData = regs[readHead];

assert ass0(clk, !isEmpty || !read);
assert ass1(clk, !isFull || !write);
assert ass2(clk, !(isEmpty && isFull));

wire [1:0] nextReadHead = readHead+1;
wire [1:0] nextWriteHead = writeHead+1;

// It's seems we can't just replace nextReadHead by readHead+1
always @(posedge clk)
begin
    if (read == 1 && isEmpty == 0) begin
        $display("%m being read, data %h", regs[readHead]);
        if (!write && nextReadHead == writeHead) begin
            isEmpty <= 1;
        end
        isFull <= 0;
        readHead <= nextReadHead;
    end
    if (write == 1 && isFull == 0) begin
        $display("%m being write, data %h", inData);
        regs[writeHead] <= inData;
        if (!read && nextWriteHead == readHead) begin
            isFull <= 1;
        end
        isEmpty <= 0;
        writeHead <= nextWriteHead;
    end
end
endmodule

