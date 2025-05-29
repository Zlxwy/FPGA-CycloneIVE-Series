module key_debounce
#(
  parameter cntMAX_1 = 20'd999_999,//计数最大值
  parameter cntMAX_2 = 20'd999_998//计数次大值
)
(
  input   wire    sys_clk,
  input   wire    sys_rst_n,
  input   wire    key_in,
  
  output  reg     led_out
);

reg[19:0]   cnt;//计数20ms，0~999999计数，需要20位
reg         key_flag;//cnt计满20ms后，key_flag才会产生一个高电平脉冲

always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)//如果复位信号有效
    cnt <= 20'd0;//计数值清零
  else if(key_in == 1'b1)//如果按键为高电平（没按下状态）
    cnt <= 20'd0;//计数值清零
  else if(cnt == cntMAX_1)//如果按键不是高电平（按下状态），且计数值到达了最大值
    cnt <= cntMAX_1;//让计数值保持在最大值
  else//其他——复位信号无效、按键为低电平（按下状态）、计数没到最大值
    cnt <= cnt + 20'd1;//计数值加1

//在这个块中，key_flag会保持一个时钟周期的高电平
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)//如果复位信号有效
    key_flag <= 1'b0;//按键标志位置低电平
  else if(cnt == cntMAX_2)//如果计数值到达次大值
    key_flag <= 1'b1;//按键标志位置高电平
  else//其他——复位信号无效、计数值不是次大值
    key_flag <= 1'b0;

always @(posedge key_flag or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    led_out <= 1'b0;
  else
    led_out <= ~led_out;
	 
endmodule