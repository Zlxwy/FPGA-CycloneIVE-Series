//这是一个仿真文件，对原文件加入模拟的激励，获取到响应后进行验证
`timescale 1ns/1ns

module tb_mux2_1();

reg     in_1;
reg     in_2;
reg     select;

wire    out;

initial
  begin
    in_1 <= 1'b0;
    in_2 <= 1'b0;
    select <= 1'b0;
  end

always #10 in_1 <= {$random}%2;
always #10 in_2 <= {$random}%2;
always #10 select <= {$random}%2;

initial
  begin
    $timeformat(-9,0,"ns",6);
    //-9表示显示时间格式为纳秒，0代表保留小数点后0位，ns是一个字符，6表示显示字符数为6个
    $monitor("@time %t:in_1=%b in_2=%b sel=%b out=%b",$time,in_1,in_2,select,out);
    //显示变量的数值，观察其变化
  end

mux2_1 mux2_1_inst
(
  .in_1   (in_1),
  .in_2   (in_2),
  .select (select),
  .out    (out)
);

endmodule
