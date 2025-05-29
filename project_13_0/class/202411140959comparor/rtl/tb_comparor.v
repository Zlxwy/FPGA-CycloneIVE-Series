`timescale 1ns/1ns
module tb_comparor();

wire[1:0] num1,num2;
wire less,equal,greater;

initial begin
    num1 <= 2'b00; num2 <= 2'b00; #20
    num1 <= 2'b00; num2 <= 2'b01; #20
    num1 <= 2'b00; num2 <= 2'b10; #20
    num1 <= 2'b00; num2 <= 2'b11; #20
    num1 <= 2'b01; num2 <= 2'b00; #20
    num1 <= 2'b01; num2 <= 2'b01; #20
    num1 <= 2'b01; num2 <= 2'b10; #20
    num1 <= 2'b01; num2 <= 2'b11; #20
    num1 <= 2'b10; num2 <= 2'b00; #20
    num1 <= 2'b10; num2 <= 2'b01; #20
    num1 <= 2'b10; num2 <= 2'b10; #20
    num1 <= 2'b10; num2 <= 2'b11; #20
    num1 <= 2'b11; num2 <= 2'b00; #20
    num1 <= 2'b11; num2 <= 2'b01; #20
    num1 <= 2'b11; num2 <= 2'b10; #20
    num1 <= 2'b11; num2 <= 2'b11; #20
end

comparor comparor_inst(
    .num1(num1),
    .num2(num2),
    .less(less),
    .equal(equal),
    .greater(greater)
);

endmodule