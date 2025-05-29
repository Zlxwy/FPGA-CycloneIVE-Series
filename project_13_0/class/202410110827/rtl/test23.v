module test23 (
  input   wire      a,
  input   wire      b,
  input   wire      c,

  output  wire      y
);

assign y = (a&(~c)) | (b&c);

endmodule