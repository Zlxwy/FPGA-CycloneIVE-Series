/**8位十进制数生成器，在0~99999999之间计数**/
module digit8_num_generator(
  input   wire        clk,
  input   wire        rst,

  output  reg[26:0]   num
);

/*100ms计数块，cnt_100ms在0~4999999之间循环计数，在50MHz时钟下，一个周期为100ms*/
reg[22:0]   cnt_100ms;
parameter   cnt_100ms_MAX = 23'd4_999_999;
always @(posedge clk or negedge rst)
  if(rst == 0)                          cnt_100ms <= 0;
  else if(cnt_100ms == cnt_100ms_MAX)   cnt_100ms <= 0;
  else                                  cnt_100ms <= cnt_100ms + 1;


/*num计数块，在0~99999999之间不断循环向上计数，依托于cnt_100ms更新事件，每100ms计一个数*/
parameter   num_MAX = 27'd9999_9999;
always @(posedge clk or negedge rst)
  if(rst == 0)                                            num <= 0;
  else if(cnt_100ms == cnt_100ms_MAX && num == num_MAX)   num <= 0;
  else if(cnt_100ms == cnt_100ms_MAX)                     num <= num + 1;
  else                                                    num <= num;



endmodule