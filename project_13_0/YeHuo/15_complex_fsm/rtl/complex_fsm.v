module complex_fsm
(
  input   wire    sys_clk,
  input   wire    sys_rst_n,
  input   wire    pi_money_half,
  input   wire    pi_money_one,
  
  output  reg     po_cola,
  output  reg     po_money
);

parameter IDLE      = 5'b00001,
          HALF      = 5'b00010,
          ONE       = 5'b00100,
          ONE_HALF  = 5'b01000,
          TWO       = 5'b10000;

wire[1:0] pi_money;
reg[4:0]  state;

assign pi_money = {pi_money_one,pi_money_half};

/*投币改变状态（一瓶可乐两个半的币，投半个币或者一个币，不会同时出现投两种币）*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)//如果复位信号有效
    state <= IDLE;//状态回IDLE
  else//其他——复位信号无效
    case(state)//判断此时状态
      IDLE: begin//状态为IDLE时
        if(pi_money == 2'b01)//如果投入半个币
          state <= HALF;//状态跳转HALF
        else if(pi_money == 2'b10)//如果投入一个币
          state <= ONE;//状态跳转ONE
        else//其他——没投币
          state <= IDLE;//状态保持IDLE
        end
      HALF: begin//状态为HALF时
        if(pi_money == 2'b01)//如果投入半个币
          state <= ONE;//状态跳转ONE
        else if(pi_money == 2'b10)//如果投入一个币
          state <= ONE_HALF;//状态跳转ONE_HALF
        else//其他——没投币
          state <= HALF;//状态保持HALF
        end
      ONE: begin//状态为ONE时
        if(pi_money == 2'b01)//如果投入半个币
          state <= ONE_HALF;//状态跳转ONE_HALF
        else if(pi_money == 2'b10)//如果投入一个币
          state <= TWO;//状态跳转TWO
        else//其他——没投币
          state <= ONE;//状态保持ONE
        end
      ONE_HALF: begin//状态为ONE_HALF时
        if(pi_money == 2'b01)//如果投入半个币
          state <= TWO;//状态跳转TWO
        else if(pi_money == 2'b10)//如果投入一个币
          state <= IDLE;//状态回到IDLE
        else//其他——没投币
          state <= ONE_HALF;//状态保持ONE_HALF
        end
      TWO: begin//状态为TWO时
        if((pi_money == 2'b01)||(pi_money == 2'b10))//如果投入半个币或者一个币
          state <= IDLE;//状态回到IDLE
        else//其他——没投币
          state <= TWO;//状态保持TWO
        end
      default: begin
        state <= IDLE;
        end
    endcase

/*可乐输出信号控制*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    po_cola <= 1'b0;
  else if((state == ONE_HALF && pi_money == 2'b10)//状态为ONE_HALF且投入1个币时
        ||(state == TWO      && pi_money == 2'b01)//状态为TWO且投入半个币时
        ||(state == TWO      && pi_money == 2'b10))//状态为TWO且投入一个币时
    po_cola <= 1'b1;//输出可乐保持一个时钟周期的高电平
  else//其他
    po_cola <= 1'b0;//保持低电平

always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    po_money <= 1'b0;
  else if(state == TWO && pi_money == 2'b10)//状态为TWO且投入一个币时
    po_money <= 1'b1;//输出零钱保持一个时钟周期的高电平
  else
    po_money <= 1'b0;

endmodule