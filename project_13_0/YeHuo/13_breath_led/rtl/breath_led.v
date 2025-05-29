module breath_led
#(
  parameter       CNT_PERCLK_MAX = 6'd49,
  parameter       CNT_PER1US_MAX = 10'd999,
  parameter       CNT_PER1MS_MAX = 10'd999
)
(
  input   wire      sys_clk,
  input   wire      sys_rst_n,
  
  output  reg[1:0]  led_out
);

reg[5:0]  cnt_perclk;
reg[9:0]  cnt_per1us;
reg[9:0]  cnt_per1ms;
reg       cnt_flag;

/*时钟计数*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt_perclk <= 6'd0;
  else if(cnt_perclk == CNT_PERCLK_MAX)//如果时钟计数到达最大值
    cnt_perclk <= 6'd0;//时钟计数清零
  else//如果时钟计数没到最大值
    cnt_perclk <= cnt_perclk + 6'd1;//时钟计数加1

/*1us计数*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt_per1us <= 10'd0;
  else if((cnt_per1us == CNT_PER1US_MAX)&&(cnt_perclk == CNT_PERCLK_MAX))//如果1us计数和时钟计数都到达最大值
    cnt_per1us <= 10'd0;//1us计数清零
  else if(cnt_perclk == CNT_PERCLK_MAX)//如果只有时钟计数到达最大值
    cnt_per1us <= cnt_per1us + 10'd1;//1us计数加1
  else//其他——只有1us计数到达最大值、1us计数和时钟计数都没有到达最大值
    cnt_per1us <= cnt_per1us;//1us计数不变

/*1ms计数*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt_per1ms <= 10'd0;
  else if((cnt_per1ms == CNT_PER1MS_MAX)
         &&(cnt_per1us == CNT_PER1US_MAX)
         &&(cnt_perclk == CNT_PERCLK_MAX))//如果1ms计数、1us计数、时钟计数都到达最大值
    cnt_per1ms <= 10'd0;//1ms计数清零
  else if((cnt_per1us == CNT_PER1US_MAX)
         &&(cnt_perclk == CNT_PERCLK_MAX))//如果只有1us计数、时钟计数同时到达最大值
    cnt_per1ms <= cnt_per1ms + 10'd1;//1ms计数加1
  else//其他
    cnt_per1ms <= cnt_per1ms;

/*cnt_flag每秒改变一次*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt_flag <= 1'b0;
  else if((cnt_per1ms == CNT_PER1MS_MAX)
         &&(cnt_per1us == CNT_PER1US_MAX)
         &&(cnt_perclk == CNT_PERCLK_MAX))
    cnt_flag <= ~cnt_flag;
  else
    cnt_flag <= cnt_flag;

/*当cnt_flag为0时，1us计数小于1ms计数||cnt_flag为1时，1us计数大于1ms计数，则LED输出低电平
 *其他时刻，LED输出高电平
 */
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    led_out <= 2'b01;
  else if(((cnt_flag == 1'b0)&&(cnt_per1us <= cnt_per1ms))
          ||((cnt_flag == 1'b1)&&(cnt_per1us >= cnt_per1ms))) begin
    led_out[0] <= 1'b0;
    led_out[1] <= 1'b1;
    end
  else begin
    led_out[0] <= 1'b1;
    led_out[1] <= 1'b0;
    end

endmodule