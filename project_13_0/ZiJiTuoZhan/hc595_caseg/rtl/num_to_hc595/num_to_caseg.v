/**输入一个十进制数，转换成8位8段共阳极数码管可直接执行的信号输出**/
//位选信号sel，从高位到低位依次为DIG_7~DIG_0
//段选信号seg，从高位到低位依次是DP,G,F,E,D,C,B,A
module num_to_caseg(
  input   wire        clk,
  input   wire        rst,
  input   wire[26:0]  num,//27位的数字，在0~99999999之间

  output  reg[7:0]    sel,//位选信号，控制哪个位显示
  output  reg[7:0]    seg//段选信号，控制位上显示的字形
);

wire[3:0]   bit_0;
wire[3:0]   bit_1;
wire[3:0]   bit_2;
wire[3:0]   bit_3;
wire[3:0]   bit_4;
wire[3:0]   bit_5;
wire[3:0]   bit_6;
wire[3:0]   bit_7;

bcd_8421 bcd_8421_inst
(
  .clk      (clk),
  .rst      (rst),
  .num      (num),

  .bit_0    (bit_0),
  .bit_1    (bit_1),
  .bit_2    (bit_2),
  .bit_3    (bit_3),
  .bit_4    (bit_4),
  .bit_5    (bit_5),
  .bit_6    (bit_6),
  .bit_7    (bit_7)
);

/*综合所有显示位上的数字，bit_7~0，构成一个32位的数*/
/*如果高位为0，则用4'd10将其替代，表示该位熄灭所有段*/
reg[31:0] disp_reg;
always @(posedge clk or negedge rst)
  if(rst == 0)      disp_reg <= {4'd10, 4'd10, 4'd10, 4'd10, 4'd10, 4'd10, 4'd10, 4'd10};
  else if(bit_7)    disp_reg <= {bit_7, bit_6, bit_5, bit_4, bit_3, bit_2, bit_1, bit_0};
  else if(bit_6)    disp_reg <= {4'd10, bit_6, bit_5, bit_4, bit_3, bit_2, bit_1, bit_0};
  else if(bit_5)    disp_reg <= {4'd10, 4'd10, bit_5, bit_4, bit_3, bit_2, bit_1, bit_0};
  else if(bit_4)    disp_reg <= {4'd10, 4'd10, 4'd10, bit_4, bit_3, bit_2, bit_1, bit_0};
  else if(bit_3)    disp_reg <= {4'd10, 4'd10, 4'd10, 4'd10, bit_3, bit_2, bit_1, bit_0};
  else if(bit_2)    disp_reg <= {4'd10, 4'd10, 4'd10, 4'd10, 4'd10, bit_2, bit_1, bit_0};
  else if(bit_1)    disp_reg <= {4'd10, 4'd10, 4'd10, 4'd10, 4'd10, 4'd10, bit_1, bit_0};
  else if(bit_0)    disp_reg <= {4'd10, 4'd10, 4'd10, 4'd10, 4'd10, 4'd10, 4'd10, bit_0};
  else              disp_reg <= {4'd10, 4'd10, 4'd10, 4'd10, 4'd10, 4'd10, 4'd10, 4'd10};


/*cnt_1ms计数块，依托于clk，在0~49999之间循环计数*/
reg[15:0]   cnt_1ms;
parameter   cnt_1ms_MAX = 16'd49_999;//50MHz时钟下计50000个数为1ms
always @(posedge clk or negedge rst)
  if(rst == 0)                      cnt_1ms <= 0;
  else if(cnt_1ms == cnt_1ms_MAX)   cnt_1ms <= 0;
  else                              cnt_1ms <= cnt_1ms + 1;


/*signal_1ms高电平脉冲信号产生*/
reg signal_1ms;//在cnt_1ms即将更新之时，产生一个维持一个时钟周期的高电平脉冲
always @(posedge clk or negedge rst)
  if(rst == 0)                        signal_1ms <= 0;
  else if(cnt_1ms == cnt_1ms_MAX-1)   signal_1ms <= 1;
  else                                signal_1ms <= 0;


/*cnt_bit计数块，依托于signal_1ms高电平脉冲信号，在0~7循环计数*/
reg[2:0]    cnt_bit;//显示到哪一位数据了，依托于signal_1ms在0~7循环计数
parameter   cnt_bit_MAX = 3'd7;//最大计数到7
always @(posedge clk or negedge rst)
  if(rst == 0)                                        cnt_bit <= 0;
  else if(signal_1ms == 1 && cnt_bit == cnt_bit_MAX)  cnt_bit <= 0;
  else if(signal_1ms == 1)                            cnt_bit <= cnt_bit + 1;
  else                                                cnt_bit <= cnt_bit;


/*位选信号缓冲器sel_disp更新块，依托于cnt_bit的数值、signal_1ms脉冲*/
/*之后真正输出的sel会比sel_disp延迟一个时钟*/
reg[7:0]  sel_disp;
always @(posedge clk or negedge rst)
  if(rst == 0)
    sel_disp <= 0;
  else if(signal_1ms == 1) begin
    case(cnt_bit)
      0:  sel_disp <= 8'b0000_0001;
      1:  sel_disp <= 8'b0000_0010;
      2:  sel_disp <= 8'b0000_0100;
      3:  sel_disp <= 8'b0000_1000;
      4:  sel_disp <= 8'b0001_0000;
      5:  sel_disp <= 8'b0010_0000;
      6:  sel_disp <= 8'b0100_0000;
      7:  sel_disp <= 8'b1000_0000;
    endcase
  end
  else
    sel_disp <= sel_disp;


/*段选信号缓冲器seg_disp更新块，依托于cnt_bit的数值、signal_1ms脉冲*/
/*之后真正输出的seg会比seg_disp延迟一个时钟*/
reg[3:0]  seg_disp;
always @(posedge clk or negedge rst)
  if(rst == 0)
    seg_disp <= 0;
  else if(signal_1ms == 1) begin
    case(cnt_bit)
      0:  seg_disp <= disp_reg[3:0];
      1:  seg_disp <= disp_reg[7:4];
      2:  seg_disp <= disp_reg[11:8];
      3:  seg_disp <= disp_reg[15:12];
      4:  seg_disp <= disp_reg[19:16];
      5:  seg_disp <= disp_reg[23:20];
      6:  seg_disp <= disp_reg[27:24];
      7:  seg_disp <= disp_reg[31:28];
      default: seg_disp <= seg_disp;
    endcase
  end
  else
    seg_disp <= seg_disp;


/*输出真正的位选信号sel*/
always @(posedge clk or negedge rst)
  if(rst == 0)
    sel <= 0;
  else
    sel <= sel_disp;

/*输出真正的段选信号seg*/
always @(posedge clk or negedge rst)
  if(rst == 0)
    seg <= 0;
  else begin
    case(seg_disp)//共阳极数码管，是阴码字形
      0:  seg <= 8'hc0;//数字0
      1:  seg <= 8'hf9;//数字1
      2:  seg <= 8'ha4;//数字2
      3:  seg <= 8'hb0;//数字3
      4:  seg <= 8'h99;//数字4
      5:  seg <= 8'h92;//数字5
      6:  seg <= 8'h82;//数字6
      7:  seg <= 8'hf8;//数字7
      8:  seg <= 8'h80;//数字8
      9:  seg <= 8'h90;//数字9
      10: seg <= 8'hff;//空格
      default: seg <= seg;
    endcase
  end

endmodule