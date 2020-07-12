module fifo_n#(parameter DATA_SIZE = 8)
    (input clk, input [DATA_SIZE-1:0] inData, input read, input write, output [DATA_SIZE-1:0] outData, output isFull, output isEmpty);

reg [DATA_SIZE-1:0] regs[3:0];
reg [1:0] readHead;
reg [1:0] writeHead;
reg isEmptyReg;
reg isFullReg;

assign outData = regs[readHead];
assign isEmpty = isEmptyReg;
assign isFull = isFullReg;

wire [1:0] nextReadHead = readHead+1;
wire [1:0] nextWriteHead = writeHead+1;

// It's seems we can't just replace nextReadHead by readHead+1
always @(posedge clk)
begin
    // The MSB of data is not used now so don't print it
    if (read == 1 && isEmptyReg == 0) begin
        $display("%m being read, data %h", regs[readHead][DATA_SIZE-2:0]);
        if (!write && nextReadHead == writeHead) begin
            isEmptyReg <= 1;
        end
        isFullReg <= 0;
        readHead <= nextReadHead;
    end
    if (write == 1 && isFullReg == 0) begin
        $display("%m being write, data %h", inData[DATA_SIZE-2:0]);
        regs[writeHead] <= inData;
        if (!read && nextWriteHead == readHead) begin
            isFullReg <= 1;
        end
        isEmptyReg <= 0;
        writeHead <= nextWriteHead;
    end
end
endmodule

