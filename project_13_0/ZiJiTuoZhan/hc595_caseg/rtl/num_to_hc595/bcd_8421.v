/**输入一个在十进制0~99999999之间的数值，输出十进制每个位上数字的8421编码**/
module bcd_8421
(
  input   wire        clk,
  input   wire        rst,
  input   wire[26:0]  num,//输入的27位数字

  output  reg[3:0]    bit_0,//个位
  output  reg[3:0]    bit_1,//十位
  output  reg[3:0]    bit_2,//百位
  output  reg[3:0]    bit_3,//千位
  output  reg[3:0]    bit_4,//万位
  output  reg[3:0]    bit_5,//十万位
  output  reg[3:0]    bit_6,//百万位
  output  reg[3:0]    bit_7//千万位
);

reg         shift_signal;//移位信号，在此信号低电平时对数据进行大于4判断，高电平时对数据进行移位
reg[4:0]    cnt_shift;//依托于shift_signal进行计数，在这个计数周期内数据进行移位计算，得出最终结果
parameter   cnt_shift_MAX = 5'd28;//27位的原数据，需要29个时钟
reg[58:0]   data_shift;//需要存储：结果的32位数据、原数的27位数据，一共59位

/*对时钟进行二分频*/
always @(posedge clk or negedge rst)
  if(rst == 0)    shift_signal <= 0;
  else            shift_signal <= ~shift_signal;

/*cnt_shift在shift_signal的脉冲信号下，在0~28之间进行循环计数*/
always @(posedge clk or negedge rst)
  if(rst == 0)                                              cnt_shift <= 0;
  else if(cnt_shift == cnt_shift_MAX && shift_signal == 1)  cnt_shift <= 0;
  else if(shift_signal == 1)                                cnt_shift <= cnt_shift + 1;
  else                                                      cnt_shift <= cnt_shift;


/*data_shift数据更新块，对data_shift进行运算，高32位[58:27]是出结果的位，低27位[26:0]是原始数据位，不断将数据往高位推*/
/* cnt_shift有29个计数周期，依托于shift_signal进行计数，每个计数周期占用两个时钟，以下程序是：
 * 在cnt_shift计数在0时，压入原始数据，
 * 在cnt_shift计数在1~27时，一个时钟周期用来计算，一个时钟周期用来移位，
 * 在cnt_shift计数在28时，数据保持。*/
always @(posedge clk or negedge rst)
  if(rst == 0)
    data_shift <= 0;
  else if(cnt_shift == 0)//在cnt_shift为0时
    data_shift <= {32'b0,num};//将待计算数据放入data_shift中
  else if(cnt_shift <= cnt_shift_MAX-1 && shift_signal == 0) begin
  //cnt_shift计数在1~27，且shift_signal低电平时
    //进行判断运算，大于4就加3，没大于4就保持不变
    data_shift[30:27] <= (data_shift[30:27] > 4)?(data_shift[30:27] + 3):(data_shift[30:27]);
    data_shift[34:31] <= (data_shift[34:31] > 4)?(data_shift[34:31] + 3):(data_shift[34:31]);
    data_shift[38:35] <= (data_shift[38:35] > 4)?(data_shift[38:35] + 3):(data_shift[38:35]);
    data_shift[42:39] <= (data_shift[42:39] > 4)?(data_shift[42:39] + 3):(data_shift[42:39]);
    data_shift[46:43] <= (data_shift[46:43] > 4)?(data_shift[46:43] + 3):(data_shift[46:43]);
    data_shift[50:47] <= (data_shift[50:47] > 4)?(data_shift[50:47] + 3):(data_shift[50:47]);
    data_shift[54:51] <= (data_shift[54:51] > 4)?(data_shift[54:51] + 3):(data_shift[54:51]);
    data_shift[58:55] <= (data_shift[58:55] > 4)?(data_shift[58:55] + 3):(data_shift[58:55]);
  end
  else if(cnt_shift <= cnt_shift_MAX-1 && shift_signal == 1)
  //cnt_shift计数在1~27，且shift_signal高电平时
    data_shift <= data_shift << 1;//进行移位
  else//其他——复位信号无效、cnt_shift计数到cnt_shift_MAX时
    data_shift <= data_shift;//数值保持


/*在cnt_shift计数到最大值时，更新bit0~7的数据*/
always @(posedge clk or negedge rst)
  if(rst == 1'b0) begin
    bit_0 <= 0;
    bit_1 <= 0;
    bit_2 <= 0;
    bit_3 <= 0;
    bit_4 <= 0;
    bit_5 <= 0;
    bit_6 <= 0;
    bit_7 <= 0;
  end
  else if(cnt_shift == cnt_shift_MAX) begin
    bit_0 <= data_shift[30:27];
    bit_1 <= data_shift[34:31];
    bit_2 <= data_shift[38:35];
    bit_3 <= data_shift[42:39];
    bit_4 <= data_shift[46:43];
    bit_5 <= data_shift[50:47];
    bit_6 <= data_shift[54:51];
    bit_7 <= data_shift[58:55];
  end
  else begin
    bit_0 <= bit_0;
    bit_1 <= bit_1;
    bit_2 <= bit_2;
    bit_3 <= bit_3;
    bit_4 <= bit_4;
    bit_5 <= bit_5;
    bit_6 <= bit_6;
    bit_7 <= bit_7;
  end

endmodule