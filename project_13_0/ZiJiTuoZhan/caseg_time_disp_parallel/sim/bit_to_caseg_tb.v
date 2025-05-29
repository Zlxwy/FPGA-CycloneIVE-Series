`timescale 1ns/1ns
module bit_to_caseg_tb();

reg clk,rst;
reg[3:0] bit_7,bit_6,bit_4,bit_3,bit_1,bit_0;
wire[3:0] bit_5,bit_2;
wire[7:0] sel,seg;

initial begin
    clk <= 0;
    rst <= 0;
    #20
    rst <= 1;
end

always #10 clk = ~clk;

always #500 bit_7 = {$random}%10;
always #500 bit_6 = {$random}%10;
assign bit_5 = 4'd11;
always #500 bit_4 = {$random}%10;
always #500 bit_3 = {$random}%10;
assign bit_2 = 4'd11;
always #500 bit_1 = {$random}%10;
always #500 bit_0 = {$random}%10;

bit_to_caseg bit_to_caseg_inst(
    .clk(clk),
    .rst(rst),
    .bit_7(bit_7),
    .bit_6(bit_6),
    .bit_5(bit_5),
    .bit_4(bit_4),
    .bit_3(bit_3),
    .bit_2(bit_2),
    .bit_1(bit_1),
    .bit_0(bit_0),
    
    .sel(sel),
    .seg(seg)
);

endmodule