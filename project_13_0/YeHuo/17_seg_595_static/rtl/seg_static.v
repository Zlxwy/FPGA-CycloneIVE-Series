module seg_static
#(
  parameter cnt_MAX = 25'd24_999_999,
  parameter data_MAX = 4'hf
)
(
  input   wire      sys_clk,
  input   wire      sys_rst_n,
  
  output  reg[5:0]  sel,//位选
  output  reg[7:0]  seg//段选
);

reg[24:0]   cnt;
reg[3:0]    data;
reg         cnt_flag;


/*cnt在0~cnt_MAX之间计数，基于系统时钟信号*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt <= 25'd0;
  else if(cnt == cnt_MAX)
    cnt <= 25'd0;
  else
    cnt <= cnt + 25'd1;


/*在时钟信号下，发现cnt计数值为24999998时，将cnt_flag电平拉高，这样就能使cnt_flag在cnt计数到末尾24999999时产生一个时钟周期的高电平*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt_flag <= 1'b0;
  else if(cnt == cnt_MAX - 1)
    cnt_flag <= 1'b1;
  else
    cnt_flag <= 1'b0;


/*data在0~data_MAX之间计数，基于cnt_flag脉冲信号*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    data <= 4'h0;
  else if((data == data_MAX)&&(cnt_flag == 1'b1))//data到达最大值，且cnt_flag脉冲信号到来
    data <= 4'h0;
  else if(cnt_flag == 1'b1)//只有脉冲信号到来
    data <= data + 4'h1;
  else
    data <= data;


/*驱动位选信号*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    sel <= 6'b000_000;
  else
    sel <= 6'b111_111;


/*驱动段选信号，基于时钟信号下的data的值*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    seg <= 8'hff;
  else begin
    case(data)
      4'h0: seg <= 8'hc0;
      4'h1: seg <= 8'hf9;
      4'h2: seg <= 8'ha4;
      4'h3: seg <= 8'hb0;
      4'h4: seg <= 8'h99;
      4'h5: seg <= 8'h92;
      4'h6: seg <= 8'h82;
      4'h7: seg <= 8'hf8;
      4'h8: seg <= 8'h80;
      4'h9: seg <= 8'h90;
      4'ha: seg <= 8'h88;
      4'hb: seg <= 8'h83;
      4'hc: seg <= 8'hc6;
      4'hd: seg <= 8'ha1;
      4'he: seg <= 8'h86;
      4'hf: seg <= 8'h8e;
      default: seg <= 8'hff;
      endcase
    end

endmodule