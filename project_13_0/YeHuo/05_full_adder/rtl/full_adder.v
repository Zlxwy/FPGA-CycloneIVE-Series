module full_adder
(
  input   wire      addend_1,//加数1
  input   wire      addend_2,//加数2
  input   wire      carry_in,//输入的进位信号
  
  //使用always赋值的一律是reg类型
  //使用assign赋值的一律是wire类型
  output  wire      sum,//和
  output  wire      carry_out//输出的进位信号
);

wire  h0_sum;
wire  h0_carry;
wire  h1_carry;

half_adder half_adder_inst_0//利用半加器模块实例化一个半加器
(
  //左边是被调用模块的信号，括号内的是本模块中的信号，将两者进行连接
  .in_1   (addend_1),
  .in_2   (addend_2),
  
  .sum    (h0_sum),
  .carry  (h0_carry)
);

half_adder half_adder_inst_1//利用半加器模块实例化一个半加器
(
  //左边是被调用模块的信号，括号内的是本模块中的信号，将两者进行连接
  .in_1   (carry_in),
  .in_2   (h0_sum),
  
  .sum    (sum),
  .carry  (h1_carry)
);

assign carry_out = (h0_carry | h1_carry);

endmodule