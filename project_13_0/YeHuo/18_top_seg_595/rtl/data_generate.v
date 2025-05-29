module data_generate
#(
  parameter cnt_100ms_MAX = 23'd4_999_999,
  parameter data_MAX = 20'd999_999//数码管显示计数，默认最大计数值为999999
)
(
  input   wire        sys_clk,
  input   wire        sys_rst_n,
  
  output  reg [19:0]  data,
  output  wire[5:0]   dp,//表示6位小数点位，高电平有效
  output  wire        sign,//符号位
  output  reg         seg_en//使能位
);

reg[22:0]   cnt_100ms;//0~cnt_100ms_MAX之间循环计数
reg         cnt_flag;//在cnt_100ms计数到cnt_100ms_MAX-1时，保持一个时钟周期的高电平

/*cnt_100ms计数块*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt_100ms <= 0;
  else if(cnt_100ms == cnt_100ms_MAX)
    cnt_100ms <= 0;
  else
    cnt_100ms <= cnt_100ms + 1;


/*cnt_flag脉冲信号产生块*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt_flag <= 1'b0;
  else if(cnt_100ms == cnt_100ms_MAX-1)
    cnt_flag <= 1'b1;
  else
    cnt_flag <= 1'b0;


/*data数据改变块，0~999999计数*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    data <= 0;
  else if(cnt_flag == 1'b1 && data == data_MAX)
    data <= 0;
  else if(cnt_flag == 1'b1)
    data <= data + 1;
  else
    data <= data;


/*小数点、符号位失能*/
assign dp = 6'b000_000;
assign sign = 1'b0;


/*数码管使能*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    seg_en <= 1'b0;
  else
    seg_en <= 1'b1;


endmodule