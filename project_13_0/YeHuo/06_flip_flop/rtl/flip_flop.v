module flip_flop
(
  input   wire      sys_clk,//由板载晶振传入，50MHz
  input   wire      sys_rst_n,//RESET按键输入
  input   wire      key_in,//按键输入
  
  output  reg       led_out
);
//使用always语句赋值的用reg类型
//使用assign语句赋值的用wire类型

///*同步复位：一切输出电平改变按照时钟的步调*/
//always @(posedge sys_clk)//在时钟上升沿时
//  if(sys_rst_n == 1'b0)//如果采集到复位信号为低电平（有效信号）
//    led_out <= 1'b1;//LED输出1（熄灭）
//    //时序逻辑中，赋值一定要用<=赋值（非阻塞赋值）
//  else//如果采集到复位信号为高电平（无效信号）
//    led_out <= key_in;//LED输出电平同步按键输入电平（按键按下则LED点亮）

/*异步复位：LED输出电平改变不仅按照时钟的上升沿，还要按照复位信号的下降沿*/
always @(posedge sys_clk or negedge sys_rst_n)//在时钟上升沿时
  if(sys_rst_n == 1'b0)//如果采集到复位信号为低电平（有效信号）
    led_out <= 1'b1;//LED输出1（熄灭）
    //时序逻辑中，赋值一定要用<=赋值（非阻塞赋值）
  else//如果采集到复位信号为高电平（无效信号）
    led_out <= key_in;//LED输出电平同步按键输入电平（按键按下则LED点亮）

//Altera推荐使用异步复位，异步复位更加节省资源

endmodule