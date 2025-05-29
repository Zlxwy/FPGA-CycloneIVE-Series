module simple_fsm
(
  input   wire    sys_clk,
  input   wire    sys_rst_n,
  input   wire    pi_money,
  
  output  reg     po_cola
);

parameter IDLE = 3'b001;
parameter ONE = 3'b010;
parameter TWO = 3'b100;
//独热码，高速系统

reg[2:0] state;

always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    state = IDLE;
  else
    case(state)
      IDLE: begin
        if(pi_money == 1'b1)
          state <= ONE;
        else
          state <= IDLE;
        end
      ONE: begin
        if(pi_money == 1'b1)
          state <= TWO;
        else
          state <= ONE;
        end
      TWO: begin
        if(pi_money == 1'b1)
          state <= IDLE;
        else
          state <= TWO;
        end
      default: begin
        state <= IDLE;
        end
    endcase
    
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    po_cola <= 1'b0;
  else if((state == TWO)&&(pi_money == 1'b1))
    po_cola <= 1'b1;
  else
    po_cola <= 1'b0;

endmodule