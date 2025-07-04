/*顶层模块，综合各个模块构成数码管显示*/
/*顶层共阳数码管时钟显示模块——并行信号*/
module top_caseg_time_disp_parallel(
    input   wire        clk,
    input   wire        rst,

    output  wire[7:0]   sel,
    output  wire[7:0]   seg
);



wire[5:0] hour,minute,second;
time_cnt time_cnt_inst(
    .clk        (clk),
    .rst        (rst),

    .hour       (hour),
    .minute     (minute),
    .second     (second)
);



wire[3:0] bit_7,bit_6,bit_5,bit_4,bit_3,bit_2,bit_1,bit_0;
time_to_bit time_to_bit_inst(
    .clk        (clk),
    .rst        (rst),
    .hour       (hour),
    .minute     (minute),
    .second     (second),

    .bit_7      (bit_7),
    .bit_6      (bit_6),
    .bit_5      (bit_5),
    .bit_4      (bit_4),
    .bit_3      (bit_3),
    .bit_2      (bit_2),
    .bit_1      (bit_1),
    .bit_0      (bit_0)
);



bit_to_caseg bit_to_caseg_inst(
    .clk        (clk),
    .rst        (rst),
    .bit_7      (bit_7),
    .bit_6      (bit_6),
    .bit_5      (bit_5),
    .bit_4      (bit_4),
    .bit_3      (bit_3),
    .bit_2      (bit_2),
    .bit_1      (bit_1),
    .bit_0      (bit_0),

    .sel        (sel),
    .seg        (seg)
);

endmodule
