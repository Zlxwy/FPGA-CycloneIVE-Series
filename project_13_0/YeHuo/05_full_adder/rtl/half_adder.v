module half_adder
(
  input   wire      in_1,
  input   wire      in_2,
  
  output  wire      sum,
  output  wire      carry
);

assign {carry,sum} = in_1 + in_2;

endmodule