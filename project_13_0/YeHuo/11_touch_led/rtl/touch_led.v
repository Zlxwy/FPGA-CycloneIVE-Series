module touch_led
(
  input   wire    sys_clk,
  input   wire    sys_rst_n,
  input   wire    touch_in,
  
  output  reg     led_out
);

reg   touch_1;
reg   touch_2;
wire  touch_flag;

always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0) begin
    touch_1 <= 1'b1;
    touch_2 <= 1'b1;
    end
  else begin
    touch_1 <= touch_in;
    touch_2 <= touch_1;
    end

assign touch_flag = (~touch_1) & touch_2;//当touch_1为低电平，且touch_2为高电平时，touch_flag置高电平

always @(posedge touch_flag or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    led_out <= 1'b1;
  else
    led_out <= ~led_out;

endmodule