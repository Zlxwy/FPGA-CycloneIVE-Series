//移位顺序，左到右依次为先后
//DIG6   DIG5   DIG4   DIG3   DIG2   DIG1   DP     G      F      E      D      C      B      A
//sel[0] sel[1] sel[2] sel[3] sel[4] sel[5] seg[7] seg[6] seg[5] seg[4] seg[3] seg[2] seg[1] seg[0]
module hc595_ctrl
#(
  parameter cnt_MAX = 2'd3,
  parameter cnt_bit_MAX = 4'd13
)
(
  input   wire      sys_clk,
  input   wire      sys_rst_n,
  input   wire[5:0] sel,//位选信号，0~5代表低位到高位，即右到左（DIG6~DIG1）
  input   wire[7:0] seg,//段选信号
  
  output  reg       ds,
  output  reg       shcp,
  output  reg       stcp,
  output  wire      oe
);

wire[13:0]  data;//要移入14位的数据
reg[1:0]    cnt;//在系统时钟下，0~cnt_MAX之间循环计数
reg[3:0]    cnt_bit;//在cnt的更新信号下，0~cnt_bit_MAX之间循环计数

assign data = {seg[0],seg[1],seg[2],seg[3],seg[4],seg[5],seg[6],seg[7],sel[5],sel[4],sel[3],sel[2],sel[1],sel[0]};


/*cnt计数块*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt <= 2'd0;
  else if(cnt == cnt_MAX)
    cnt <= 2'd0;
  else
    cnt <= cnt + 2'd1;


/*cnt_bit计数块*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt_bit <= 4'd0;
  else if(cnt_bit == cnt_bit_MAX && cnt == cnt_MAX)
    cnt_bit <= 4'd0;
  else if(cnt == cnt_MAX)
    cnt_bit <= cnt_bit + 4'd1;
  else
    cnt_bit <= cnt_bit;


/*在ds引脚上输出数据位，数据位取决于cnt等于0时data[13:0]和cnt_bit的值*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    ds <= 1'b0;
  else if(cnt == 2'd0)
    ds <= data[cnt_bit];
  else
    ds <= ds;


/*把shcp引脚电平拉高，使数据位移入到SR中*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    shcp <= 1'b0;
  else if(cnt == 2'd2)
    shcp <= 1'b1;
  else if(cnt == 2'd0)
    shcp <= 1'b0;
  else
    shcp <= shcp;


/*把stcp引脚电平拉高，让移位数据从SR更新到输出锁存器上*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    stcp <= 1'b0;
  else if(cnt_bit == 4'd0 && cnt == 2'd0)
    stcp <= 1'b1;
  else if(cnt_bit == 4'd0 && cnt == 2'd2)
    stcp <= 1'b0;
  else
    stcp <= stcp;


/*低电平有效引脚，使其一直保持低电平*/
assign oe = 1'b0;


endmodule