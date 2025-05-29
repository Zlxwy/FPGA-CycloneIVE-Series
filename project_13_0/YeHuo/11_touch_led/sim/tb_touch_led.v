`timescale 1ns/1ns
module tb_touch_led();

reg   sys_clk;
reg   sys_rst_n;
reg   touch_in;

wire  led_out;

initial begin
  sys_clk = 1'b1;
  sys_rst_n <= 1'b0;
  touch_in <= 1'b1;
  #20
  sys_rst_n <= 1'b1;
  #200
  touch_in <= 1'b0;
  #300
  touch_in <= 1'b1;
  #400
  touch_in <= 1'b0;
  #500
  touch_in <= 1'b1;
  end

always #10 sys_clk = ~sys_clk;

touch_led touch_led_inst
(
  .sys_clk    (sys_clk),
  .sys_rst_n  (sys_rst_n),
  .touch_in   (touch_in),
  
  .led_out    (led_out)
);

endmodule