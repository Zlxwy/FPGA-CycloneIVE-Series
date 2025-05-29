`timescale 1ns/1ns
module tb_half_adder();

//使用always赋值的一律是reg类型
//使用assign赋值的一律是wire类型
reg   in_1;
reg   in_2;
wire  sum;
wire  carry;

initial
  begin
    in_1 <= 1'b0;
    in_2 <= 1'b0;
  end
  
always #10 in_1 <= {$random}%2;
always #10 in_2 <= {$random}%2;

initial
  begin
    $timeformat(-9,0,"ns",6);
    $monitor("@time %t:in_1=%b,in_2=%b,sum=%b,carry=%b",$time,in_1,in_2,sum,carry);
  end

half_adder half_adder_inst
(
  //左边是功能模块中的信号，右边括号内的是仿真模块中的信号，将两者进行连接
  .in_1   (in_1),
  .in_2   (in_2),
  .sum    (sum),
  .carry  (carry)
);

endmodule