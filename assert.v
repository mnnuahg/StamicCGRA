// This idea is found by google

module assert(input clk, input in);
    always @(posedge clk) begin
        if(in == 0) begin
            $display("assert happened in %m\n");
            $finish;
        end
    end
endmodule
