`timescale 1ns/1ns
module tb_pll();

reg sys_clk;
wire my_clk_0;
wire my_clk_1;
wire my_clk_2;
wire my_clk_3;
wire locked;

initial begin
    sys_clk = 1'b0;
end

always #10 sys_clk = ~sys_clk;

pll pll_inst(
    .sys_clk        (sys_clk),
    .my_clk_0       (my_clk_0),
    .my_clk_1       (my_clk_1),
    .my_clk_2       (my_clk_2),
    .my_clk_3       (my_clk_3),
    .locked         (locked)
);

endmodule