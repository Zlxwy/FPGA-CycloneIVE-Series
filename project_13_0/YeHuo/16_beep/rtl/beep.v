module beep
#(
  parameter   cnt_MAX = 25'd24_999_999,
  parameter   cnt_per500ms_MAX = 3'd6,
  
  /*50MHz时钟下的计数最大值*/
  parameter   cnt_tone_1_MAX = 18'd190840,
  parameter   cnt_tone_2_MAX = 18'd170068,
  parameter   cnt_tone_3_MAX = 18'd151515,
  parameter   cnt_tone_4_MAX = 18'd143266,
  parameter   cnt_tone_5_MAX = 18'd127551,
  parameter   cnt_tone_6_MAX = 18'd113636,
  parameter   cnt_tone_7_MAX = 18'd101215
)
(
  input   wire      sys_clk,
  input   wire      sys_rst_n,
  
  output  reg       beep_out
);


reg[24:0]   cnt;//0~24999999
reg[2:0]    cnt_per500ms;//0~6，分别对应音调1234567

reg[17:0]   cnt_tone;
reg[17:0]   cnt_tone_MAX;
wire[17:0]  cnt_tone_MAX_half;


/*cnt在0~cnt_MAX之间循环计数*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt <= 25'd0;
  else if(cnt == cnt_MAX)
    cnt <= 25'd0;
  else
    cnt <= cnt + 25'd1;


/*cnt_per500ms在0~cnt_per500ms_MAX之间循环计数*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt_per500ms <= 3'd0;
  else if(cnt == cnt_MAX && cnt_per500ms == cnt_per500ms_MAX)
    cnt_per500ms <= 3'd0;
  else if(cnt == cnt_MAX)
    cnt_per500ms <= cnt_per500ms + 3'd1;
  else
    cnt_per500ms <= cnt_per500ms;


/*根据cnt_per500ms的值，把对应音调的计数最大值赋给cnt_tone_MAX，在另一个块中会以这个最大值cnt_tone_MAX进行循环计数*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n ==1'b0)
    cnt_tone_MAX <= 18'd0;
  else begin
    case(cnt_per500ms)
      3'd0: begin
        cnt_tone_MAX <= cnt_tone_1_MAX;
        end
      3'd1: begin
        cnt_tone_MAX <= cnt_tone_2_MAX;
        end
      3'd2: begin
        cnt_tone_MAX <= cnt_tone_3_MAX;
        end
      3'd3: begin
        cnt_tone_MAX <= cnt_tone_4_MAX;
        end
      3'd4: begin
        cnt_tone_MAX <= cnt_tone_5_MAX;
        end
      3'd5: begin
        cnt_tone_MAX <= cnt_tone_6_MAX;
        end
      3'd6: begin
        cnt_tone_MAX <= cnt_tone_7_MAX;
        end
      default: begin
        cnt_tone_MAX <= cnt_tone_1_MAX;
        end
      endcase
    end


/*cnt_tone在0~cnt_tone_MAX之中循环计数*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt_tone <= 18'd0;
  else if(cnt_tone == cnt_tone_MAX || cnt == cnt_MAX)//当音调计数到达最大值，或者音调跳转时
    cnt_tone <= 18'd0;//音调计数清零
  else
    cnt_tone <= cnt_tone + 18'd1;


assign cnt_tone_MAX_half = cnt_tone_MAX >> 1;//二进制数右移一位，相当于除以2

/*beep_out根据cnt_tone计数值输出高低电平*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    beep_out = 1'b0;
  else if(cnt_tone <= cnt_tone_MAX_half)
    beep_out <= 1'b1;
  else
    beep_out <= 1'b0;


endmodule
