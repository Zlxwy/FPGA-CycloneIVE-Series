`timescale 1ns/1ns

module tb_SawTooth_Wave();

reg   clk;

initial
    clk = 1'b0;

always #10 clk = ~clk;

SawTooth_Wave inst
(
  .clk    (clk)
);

endmodule