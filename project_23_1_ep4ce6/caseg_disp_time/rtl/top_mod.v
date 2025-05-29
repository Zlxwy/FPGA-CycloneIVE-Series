/*顶层模块，综合各个模块构成数码管显示*/
module top_mod(
    input   wire        sclk,
    input   wire        nrst,

    output  wire[7:0] sel,
	 output wire[7:0] seg
);



wire[5:0] hour,minute,second;
time_cnt time_cnt_inst(
    .sclk       (sclk),
    .nrst       (nrst),

    .hour       (hour),
    .minute     (minute),
    .second     (second)
);



wire[3:0] bit_7,bit_6,bit_5,bit_4,bit_3,bit_2,bit_1,bit_0;
num_to_bit num_to_bit_inst(
    .sclk       (sclk),
    .nrst       (nrst),
    .num_02     (hour),
    .num_01     (minute),
    .num_00     (second),

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
    .sclk       (sclk),
    .nrst       (nrst),
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
