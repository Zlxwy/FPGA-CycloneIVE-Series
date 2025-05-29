module water_led
#(
  parameter cntMAX_1 = 25'd24_999_999,//计数最大值
  parameter cntMAX_2 = 25'd24_999_998//计数次大值
)
(
  input   wire      sys_clk,
  input   wire      sys_rst_n,
  
  output  reg[3:0]  led
);

reg[24:0]   cnt;//cnt需要从0~24999999计数，需要25位二进制位
reg         cnt_flag;
reg[1:0]    led_state;

/*cnt循环计数块：0~24999999*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt <= 0;
  else if(cnt == cntMAX_1)
    cnt <= 0;
  else
    cnt <= cnt + 25'd1;

/*cnt_flag脉冲信号产生块：在cnt计数到24999998时，cnt_flag会产生一个时钟周期的高电平脉冲*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt_flag <= 1'b0;
  else if(cnt == cntMAX_2)
    cnt_flag <= 1'b1;
  else
    cnt_flag <= 1'b0;

/*流水灯运行块：cnt每计满一轮，LED状态就会改变一次*/
always @(posedge cnt_flag or negedge sys_rst_n)
  if(sys_rst_n == 1'b0) begin
    led_state <= 2'b00;
    led <= 4'b0111;
    end
  else begin
    /*方法1*/
    led <= {led[0],led[3],led[2],led[1]};
  
//    /*方法2*/
//    led[3] <= led[0];
//    led[2] <= led[3];
//    led[1] <= led[2];
//    led[0] <= led[1];
  
//    /*方法3*/
//    led <= ~(4'b1000>>led_state);
//    led_state <= led_state + 2'b1;
    
//    /*方法4*/
//    case(led_state)
//    2'b00:begin
//      led <= 4'b0111;
//      end
//    2'b01:begin
//      led <= 4'b1011;
//      end
//    2'b10:begin
//      led <= 4'b1101;
//      end
//    2'b11:begin
//      led <= 4'b1110;
//      end
//    default:begin
//      end
//    endcase
//    led_state <= led_state + 2'b1;
    end

endmodule