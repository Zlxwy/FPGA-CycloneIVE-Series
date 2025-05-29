/*顶层模块，综合各个模块构成数码管显示*/
module top_caseg_time_disp_serial(
    input   wire        clk,
    input   wire        rst,

    output  wire        ds,
    output  wire        shcp,
    output  wire        stcp,
    output  wire        oe
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



wire[7:0] sel,seg;
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

caseg_to_hc595 caseg_to_hc595_inst(
    .clk        (clk),//系统时钟50MHz
    .rst        (rst),//复位信号，低电平有效
    .sel        (sel),//位选信号，控制哪个位显示
    .seg        (seg),//段选信号，控制位上显示的字形

    .ds         (ds),//数据输入端
    .shcp       (shcp),//移位时钟，上升沿移位
    .stcp       (stcp),//输出时钟，上升沿
    .oe         (oe)//使能端，低电平有效
);

endmodule
