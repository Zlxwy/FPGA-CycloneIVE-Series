module half_adder
(
  input   wire    addend_0,
  input   wire    addend_1,
  
  output  wire    sum,
  output  wire    carry
);

//assign sum = ((!addend_0)&(addend_1)) | ((addend_0)&(!addend_1));//异或操作
assign sum    =   addend_0 ^ addend_1;//^是异或符号
assign carry  =   addend_0 & addend_1;

endmodule
