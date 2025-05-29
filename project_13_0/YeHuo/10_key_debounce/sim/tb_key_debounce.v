`timescale 1ns/1ns
module tb_key_debounce();

reg       sys_clk;
reg       sys_rst_n;
reg       key_in;
wire      led_out;
reg[7:0]  tb_cnt;//模拟按键保持按下的时间计数，计250个数
//0~19时模拟按键松开状态，20~69时模拟按键按下抖动状态，70~149时模拟按键按下状态，150~199模拟按键松开抖动状态，200~249模拟按键松开状态

initial begin
  sys_clk = 1'b1;
  sys_rst_n <= 1'b0;
  #20
  sys_rst_n <= 1'b1;
  end

always #10 sys_clk = ~sys_clk;

always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    tb_cnt <= 8'd0;
  else if(tb_cnt == 8'd249)
    tb_cnt <= 8'd0;
  else
    tb_cnt <= tb_cnt + 8'd1;

always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)//如果复位信号有效
    key_in <= 1'b1;//按键输入作高电平，模拟松开状态
  else if(((tb_cnt >= 8'd20)&&(tb_cnt <= 8'd69))
       || ((tb_cnt >= 8'd150)&&(tb_cnt <= 8'd199)))//如果计数在抖动时间范围内
    key_in <= {$random}%2;//按键输入随机变化的信号，模拟抖动状态
  else if((tb_cnt >= 8'd70)&&(tb_cnt <= 8'd149))//如果计数在按下时间范围内
    key_in <= 1'b0;//按键输入作低电平，模拟按下状态
  else//其他——复位信号无效、不在抖动范围、不在按下范围
    key_in <= 1'b1;//按键输入作高电平，模拟松开状态

key_debounce
#(
  .cntMAX_1   (20'd24),
  .cntMAX_2   (20'd23)
)
key_debounce_inst
(
  .sys_clk    (sys_clk),
  .sys_rst_n  (sys_rst_n),
  .key_in     (key_in),
  
  .led_out    (led_out)
);

endmodule