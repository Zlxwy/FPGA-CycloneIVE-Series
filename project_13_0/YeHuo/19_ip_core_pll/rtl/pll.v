module pll(
    input   wire        sys_clk,
    output  wire        my_clk_0,
    output  wire        my_clk_1,
    output  wire        my_clk_2,
    output  wire        my_clk_3,
    output  wire        locked
);

ip_core_pll	ip_core_pll_inst (
    .inclk0     (sys_clk),
    .c0         (my_clk_0),
    .c1         (my_clk_1),
    .c2         (my_clk_2),
    .c3         (my_clk_3),
    .locked     (locked)
);



endmodule