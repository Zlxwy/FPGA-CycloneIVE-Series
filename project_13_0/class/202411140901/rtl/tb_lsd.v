`timescale 1ns/1ns
module tb_lsd();

reg clk;
reg rst;
wire[3:0] led;

initial begin
    clk <= 0;
    rst <= 0;
    #20
    rst <= 1;
end

always #10 clk <= ~clk;

lsd lsd_inst(
    .clk(clk),
    .rst(rst),

    .led(led)
);
endmodule