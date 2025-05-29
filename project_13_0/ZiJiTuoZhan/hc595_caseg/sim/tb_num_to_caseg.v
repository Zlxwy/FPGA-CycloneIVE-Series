`timescale 1ns/1ns
module tb_num_to_caseg();

reg[26:0]   num;
reg         clk;
reg         rst;
wire[7:0]   sel;
wire[7:0]   seg;
wire[2:0]   bit = num_to_caseg_inst.bit;
wire[3:0]   seg_disp = num_to_caseg_inst.seg_disp;



initial begin
  clk <= 0;
  rst <= 0;
  #20
  rst <= 1;
  num <= 27'd87927899;
end

always #10 clk = ~clk;

num_to_caseg num_to_caseg_inst(
  .clk(clk),
  .rst(rst),
  .num(num),//27位的数字，在0~99999999之间

  .sel(sel),//位选信号，控制哪个位显示
  .seg(seg)//段选信号，控制位上显示的字形
);

endmodule