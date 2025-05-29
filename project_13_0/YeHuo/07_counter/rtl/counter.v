module counter
#(
  parameter   CNT_MAX = 25'd24_999_999//定义一个计数最大值：25位宽，十进制的24999999
)
(
  input   wire    sys_clk,
  input   wire    sys_rst_n,
  
  output  reg     led_out
);

reg   [24:0]    cnt;
//计数器清零条件：
//1、计数器到达重载值
//2、复位信号到来
reg             cnt_flag;
//这个cnt_flag在计数值重载的前一个时钟沿进行拉高，在计数值重载的时钟沿进行拉低，
//产生一个脉冲信号，用于产生一个计数值准备重载标志位

/*这个always程序块用于对计数值进行改变*/
always @(posedge sys_clk or negedge sys_rst_n)//在时钟上升沿或复位下降沿出现时
  if(sys_rst_n == 1'b0)//如果复位信号有效
    cnt <= 25'd0;//计数值清零
  else if(cnt == CNT_MAX)//如果计数器到达了计数最大值
    cnt <= 25'd0;//计数值清零
  else//其他情况：复位信号无效，且计数值还没到达最大值
    cnt <= cnt + 25'd1;//计数值自加1

always @(posedge sys_clk or negedge sys_rst_n)//在时钟上升沿或复位下降沿出现时
  if(sys_rst_n == 1'b0)//如果复位信号有效
    cnt_flag <= 1'b0;//标志位置零
  else if(cnt == (CNT_MAX - 25'd1))//如果计数值来到了重载值的前边一位
    cnt_flag <= 1'b1;//标志位拉高
  else
    cnt_flag <= 1'b0;//然后标志位拉低，由此产生一个高电平脉冲

/*这个always程序块用于对LED电平进行改变*/
always @(posedge sys_clk or negedge sys_rst_n)//在时钟上升沿或复位下降沿出现时
  if(sys_rst_n ==1'b0)
    led_out <= 1'b0;
  else if(cnt_flag == 1'b1)//捕获cnt_flag变成高电平，是捕获该时钟边沿前一刻cnt_flag的值
    led_out <= ~led_out;
  else
    led_out <= led_out;


endmodule