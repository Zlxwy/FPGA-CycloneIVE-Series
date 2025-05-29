`timescale 1ns/1ns
module time_cnt_tb();

reg clk,rst;
wire[5:0] hour,minute,second;

initial begin
    clk <= 0;
    rst <= 0;
    #20
    rst <= 1;
end

always #10 clk = ~clk;

time_cnt time_cnt_inst(
    .clk        (clk),
    .rst        (rst),
    .hour       (hour),
    .minute     (minute),
    .second     (second)
);
defparam time_cnt_inst.cnt_1s_MAX = 26'd5;

endmodule