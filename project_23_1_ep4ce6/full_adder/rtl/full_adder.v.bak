module full_adder
(
  input   wire    addend_0,
  input   wire    addend_1,
  input   wire    carry_in,
  
  output  wire    sum,
  output  wire    carry_out
);

wire  h0_sum;
wire  h0_carry;
wire  h1_carry;

half_adder half_adder_inst_0//利用半加器模块实例化一个半加器对象
(
  //左边是被调用模块的信号，括号内的是本模块中的信号，将两者进行连接
  .addend_0   (addend_0),
  .addend_1   (addend_1),
  
  .sum        (h0_sum),
  .carry      (h0_carry)
);

half_adder half_adder_inst_1//利用半加器模块实例化一个半加器对象
(
  //左边是被调用模块的信号，括号内的是本模块中的信号，将两者进行连接
  .addend_0   (h0_sum),
  .addend_1   (carry_in),
  
  .sum        (sum),
  .carry      (h1_carry)
);

assign carry_out = h0_carry | h1_carry;

endmodule
