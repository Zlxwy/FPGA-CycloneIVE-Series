///*分频方法1*/
////这个分频方法，如果需要使用新的低频时钟，使用的是clk_out，实现的是分频
//module divider_five
//(
//  input   wire    sys_clk,
//  input   wire    sys_rst_n,
//  
//  output  wire    clk_out
//);
//
//reg[2:0]    cnt;//cnt从0~4计数，需要3位
//parameter   cntMAX = 3'd4;
//reg         clk_1;
//reg         clk_2;
//
//always @(posedge sys_clk or negedge sys_rst_n)//在时钟上升沿，或者复位信号下降沿时
//  if(sys_rst_n == 1'b0)//如果复位信号有效
//    cnt <= 3'd0;//计数值清零
//  else if(cnt == cntMAX)//如果计数值到达最大值
//    cnt <= 3'd0;//计数值清零
//  else//其他——如果复位信号无效，且计数值还没到最大值
//    cnt <= cnt + 3'd1;//计数值加1
//
//always @(posedge sys_clk or negedge sys_rst_n)//在时钟上升沿，或者复位信号下降沿时
//  if(sys_rst_n == 1'b0)//如果复位信号有效
//    clk_1 <= 1'b0;//时钟1为低电平
//  else if(cnt == 3'd2)//如果计数器计数到2
//    clk_1 <= 1'b1;//时钟1为高电平
//  else if(cnt == 3'd4)//如果计数器计数到4
//    clk_1 <= 1'b0;//时钟1为低电平
//  else//其他——复位信号无效，且计数值不是2也不是4
//    clk_1 <= clk_1;//时钟1保持原电平
//
//always @(negedge sys_clk or negedge sys_rst_n)//在时钟下降沿，或者复位信号下降沿时
//  if(sys_rst_n == 1'b0)//如果复位信号有效
//    clk_2 <= 1'b0;//时钟2为低电平
//  else if(cnt == 3'd2)//如果计数器计数到2
//    clk_2 <= 1'b1;//时钟2为高电平
//  else if(cnt == 3'd4)//如果计数器计数到4
//    clk_2 <= 1'b0;//时钟2为低电平
//  else//其他——复位信号无效，且计数值不是2也不是4
//    clk_2 <= clk_2;//时钟2保持原电平
//
//assign clk_out = (clk_1 | clk_2);
//
//endmodule

/*分频方法2*/
//这个分频方法，如果需要使用新的低频时钟，使用的还是原sys_clk，只不过加了一个对clk_flag的判断，实现的是降频
module divider_five
(
  input   wire    sys_clk,
  input   wire    sys_rst_n,
  
  output  reg     clk_flag
);

reg[2:0]    cnt;//由0~4计数，需要3位
parameter   cntMAX_1 = 3'd4;//计数最大值
parameter   cntMAX_2 = 3'd3;//计数次大值

always @(posedge sys_clk or negedge sys_rst_n)//在时钟上升沿、或者复位信号下降沿出现时
  if(sys_rst_n ==1'b0)//如果复位信号有效
    cnt <= 3'd0;//计数值清零
  else if(cnt == cntMAX_1)//如果计数值计数到最大值
    cnt <= 3'd0;//计数值清零
  else//其他——如果复位信号无效，并且计数值未达到最大值
    cnt <= cnt + 3'd1;//计数值加1

always @(posedge sys_clk or negedge sys_rst_n)//在时钟上升沿、或者复位信号下降沿出现时
  if(sys_rst_n ==1'b0)//如果复位信号有效
    clk_flag <= 1'b0;//输出时钟为低电平
  else if(cnt == cntMAX_2)//如果计数值计数到次大值
    clk_flag <= 1'b1;//输出时钟为高电平
  else//其他——如果复位信号无效，并且计数值不是次大值
    clk_flag <= 1'b0;//输出时钟为低电平

endmodule