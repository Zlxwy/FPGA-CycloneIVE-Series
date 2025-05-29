`timescale 1ns/1ns
module running_led_tb();

reg clk,rst;
wire[3:0] led;

initial begin
    clk <= 0;
    rst <= 0;
    #20
    rst <= 1;
end

always #10 clk = ~clk;

running_led running_led_inst(
    .clk        (clk),
    .rst        (rst),
    .led        (led)
);
defparam running_led_inst.cnt_500ms_MAX = 10;

endmodule