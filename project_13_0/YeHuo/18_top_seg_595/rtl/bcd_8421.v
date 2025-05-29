/*输入一个20位的数据，数值在000000~999999(10)之间，输出十进制每个位上数字的二进制数*/
module bcd_8421
(
  input   wire        sys_clk,
  input   wire        sys_rst_n,
  input   wire[19:0]  data,
  
  output  reg[3:0]    bit_0,//unit
  output  reg[3:0]    bit_1,//ten
  output  reg[3:0]    bit_2,//hun
  output  reg[3:0]    bit_3,//tho
  output  reg[3:0]    bit_4,//t_tho
  output  reg[3:0]    bit_5//h_hun
);

reg[4:0]    cnt_shift;
parameter   cnt_shift_MAX = 5'd21;
reg[43:0]   data_shift;
reg         shift_flag;

/*对时钟进行二分频*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    shift_flag <= 1'b0;
  else
    shift_flag <= ~shift_flag;

/*cnt_shift在shift_flag的脉冲信号下，在0~cnt_shift_MAX之间进行循环计数*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt_shift <= 0;
  else if((cnt_shift == cnt_shift_MAX)&&(shift_flag == 1'b1))
    cnt_shift <= 0;
  else if(shift_flag == 1'b1)
    cnt_shift <= cnt_shift + 1;
  else
    cnt_shift <= cnt_shift;


/*data_shift数据更新块，对data_shift进行运算，高24位[43:20]是出结果的位，低20位[19:0]是原始数据位，不断将数据往高位推*/
/* cnt_shift有22个计数周期，每个计数周期占用两个时钟，以下程序是：
 * 在cnt_shift计数在0时，压入原始数据，
 * 在cnt_shift计数在1~20时，一个时钟周期用来计算，一个时钟周期用来移位，
 * 在cnt_shift计数在21时，数据保持。 */
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    data_shift <=44'b0;
  else if(cnt_shift == 0)//在cnt_shift为0时
    data_shift <= {24'b0,data};//将待计算数据放入data_shift中
  else if((cnt_shift <= cnt_shift_MAX-1)&&(shift_flag == 1'b0)) begin//cnt_shift计数在1~cnt_shift_MAX-1，且shift_flag低电平时
    data_shift[23:20] <= (data_shift[23:20] > 4)?(data_shift[23:20] + 3):(data_shift[23:20]);
    data_shift[27:24] <= (data_shift[27:24] > 4)?(data_shift[27:24] + 3):(data_shift[27:24]);
    data_shift[31:28] <= (data_shift[31:28] > 4)?(data_shift[31:28] + 3):(data_shift[31:28]);
    data_shift[35:32] <= (data_shift[35:32] > 4)?(data_shift[35:32] + 3):(data_shift[35:32]);
    data_shift[39:36] <= (data_shift[39:36] > 4)?(data_shift[39:36] + 3):(data_shift[39:36]);
    data_shift[43:40] <= (data_shift[43:40] > 4)?(data_shift[43:40] + 3):(data_shift[43:40]);
    end//进行判断运算
  else if((cnt_shift <= cnt_shift_MAX-1)&&(shift_flag == 1'b1))//cnt_shift计数在1~cnt_shift_MAX-1，且shift_flag高电平时
    data_shift <= data_shift << 1;//进行移位
  else//其他——复位信号无效、cnt_shift计数到cnt_shift_MAX时
    data_shift <= data_shift;//数值保持


/*在cnt_shift计数到最大值时，更新bit0~5的数据*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0) begin
    bit_0 <= 4'b0;
    bit_1 <= 4'b0;
    bit_2 <= 4'b0;
    bit_3 <= 4'b0;
    bit_4 <= 4'b0;
    bit_5 <= 4'b0;
    end
  else if(cnt_shift == cnt_shift_MAX) begin
    bit_0 <= data_shift[23:20];
    bit_1 <= data_shift[27:24];
    bit_2 <= data_shift[31:28];
    bit_3 <= data_shift[35:32];
    bit_4 <= data_shift[39:36];
    bit_5 <= data_shift[43:40];
    end
  else begin
    bit_0 <= bit_0;
    bit_1 <= bit_1;
    bit_2 <= bit_2;
    bit_3 <= bit_3;
    bit_4 <= bit_4;
    bit_5 <= bit_5;
    end

endmodule
  