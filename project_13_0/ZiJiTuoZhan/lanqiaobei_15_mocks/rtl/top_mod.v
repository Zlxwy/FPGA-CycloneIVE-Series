module top_mod(
    input   wire        sclk,
    input   wire        nrst,
    input   wire        key_pp,
    input   wire        key_1,
    input   wire        key_2,

    output  wire[7:0]   sel,
    output  wire[7:0]   seg,
    output  wire        led
);





//倒计时按键
wire key_signal_pp;
key_debounce key_debounce_inst_pp(
    .sclk           (sclk),
    .nrst           (nrst),
    .key_state      (key_pp),

    .key_signal     (key_signal_pp)
);

//倒计时按键接入倒计时模块
wire[6:0]   down_cnt;
wire[2:0]   down_cnt_state;
wire        is_down_counting;
down_counter #(.down_cnt_MAX(20))
down_counter_inst(
    .sclk           (sclk),
    .nrst           (nrst),
    .key_pp         (key_signal_pp),//pause/play

    .cnt            (down_cnt),
    .cnt_state      (down_cnt_state),
    .is_counting    (is_down_counting)
);



led led_inst(
    .sclk           (sclk),
    .nrst           (nrst),
    .state          (down_cnt_state),

    .led            (led)
);




//计数1按键
wire key_signal_1;
key_debounce key_debounce_inst_1(
    .sclk           (sclk),
    .nrst           (nrst),
    .key_state      (key_1),

    .key_signal     (key_signal_1)
);

//计数2按键
wire key_signal_2;
key_debounce key_debounce_inst_2(
    .sclk           (sclk),
    .nrst           (nrst),
    .key_state      (key_2),

    .key_signal     (key_signal_2)
);

//倒计时模块引出的计数使能信号
wire up_cnt_enable;
assign up_cnt_enable = is_down_counting;

//计数1模块
wire[6:0]   up_cnt_1;
up_counter #(.up_cnt_MAX(99))
up_counter_inst_1(
    .sclk           (sclk),
    .nrst           (nrst),
    .key_add        (key_signal_1),
    .cnt_enable     (up_cnt_enable),//倒计时停止时，计数值不能自增了，设置此使能输入，高电平有效

    .cnt            (up_cnt_1)
);

//计数2模块
wire[6:0]   up_cnt_2;
up_counter #(.up_cnt_MAX(99))
up_counter_inst_2(
    .sclk           (sclk),
    .nrst           (nrst),
    .key_add        (key_signal_2),
    .cnt_enable     (up_cnt_enable),//倒计时停止时，计数值不能自增了，设置此使能输入，高电平有效

    .cnt            (up_cnt_2)
);





//计数转数码位
wire[3:0] bit_7,bit_6,bit_5,bit_4,bit_3,bit_2,bit_1,bit_0;
caseg_bit caseg_bit_inst(
    .down_cnt       (down_cnt),
    .up_cnt_1       (up_cnt_1),
    .up_cnt_2       (up_cnt_2),

    .bit_7          (bit_7),
    .bit_6          (bit_6),
    .bit_5          (bit_5),
    .bit_4          (bit_4),
    .bit_3          (bit_3),
    .bit_2          (bit_2),
    .bit_1          (bit_1),
    .bit_0          (bit_0)
);

//数码位转换成实际显示信号
caseg_disp caseg_disp_inst(
    .sclk           (sclk),
    .nrst           (nrst),
    .bit_7          (bit_7),
    .bit_6          (bit_6),
    .bit_5          (bit_5),
    .bit_4          (bit_4),
    .bit_3          (bit_3),
    .bit_2          (bit_2),
    .bit_1          (bit_1),
    .bit_0          (bit_0),

    .sel            (sel),
    .seg            (seg)
);

endmodule