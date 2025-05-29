`timescale 1ns/1ns

module tb_decoder();

//使用always赋值的一律是reg类型
//使用assign赋值的一律是wire类型
reg   in_1;
reg   in_2;

wire  [3:0]   out;

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
    //-9表示纳秒级
    //0表示保留0位小数位，即不保留小数位
    //ns是一个字符串，用于显示时间单位的
    //6表示打印数字的长度为6
    $monitor("@time %t:in_1=%b,in_2=%b,out=%b",$time,in_1,in_2,out);
  end

decoder decoder_inst
(
  //左边是功能模块中的信号，右边括号内的是仿真模块中的信号，将两者进行连接
  .in_1   (in_1),
  .in_2   (in_2),
  
  .out    (out)
);

endmodule