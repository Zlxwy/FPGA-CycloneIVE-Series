`timescale 1ns/1ns
module tb_bcd_8421();

reg[26:0]   num;
reg         clk;
reg         rst;
wire        bit_0;
wire        bit_1;
wire        bit_2;
wire        bit_3;
wire        bit_4;
wire        bit_5;
wire        bit_6;
wire        bit_7;


initial begin
  clk <= 0;
  rst <= 0;
  #20
  rst <= 1;
  num <= 27'd87927899;
end

always #10 clk = ~clk;


bcd_8421 bcd_8421_inst
(
  .clk      (clk),
  .rst      (rst),
  .num      (num),
  
  .bit_0    (bit_0),//个位
  .bit_1    (bit_1),//十位
  .bit_2    (bit_2),//百位
  .bit_3    (bit_3),//千位
  .bit_4    (bit_4),//万位
  .bit_5    (bit_5),//十万位
  .bit_6    (bit_6),//百万位
  .bit_7    (bit_7)//千万位
);

endmodule