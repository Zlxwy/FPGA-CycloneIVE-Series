module top_module(
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
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按，参数范围[2~4294967295]ms
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms，参数范围[2~4294967295]ms
) key_pp_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key_pp), // 原始按键信号
    .key_out(key_signal_pp) // 出来的按键信号
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
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按，参数范围[2~4294967295]ms
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms，参数范围[2~4294967295]ms
) key_1_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key_1), // 原始按键信号
    .key_out(key_signal_1) // 出来的按键信号
);

//计数2按键
wire key_signal_2;
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按，参数范围[2~4294967295]ms
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms，参数范围[2~4294967295]ms
) key_2_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key_2), // 原始按键信号
    .key_out(key_signal_2) // 出来的按键信号
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





wire[3:0] bit_7, bit_6, bit_5, bit_4, bit_3, bit_2, bit_1, bit_0;
num_to_bit num_to_bit_inst (
    .sclk(sclk),
    .nrst(nrst),
    .num_02(down_cnt),
    .num_01(up_cnt_1),
    .num_00(up_cnt_2),
    
    /*从右到左依次为bit_0~7*/
    .bit_7(bit_7),
    .bit_6(bit_6),
    .bit_5(bit_5),
    .bit_4(bit_4),
    .bit_3(bit_3),
    .bit_2(bit_2),
    .bit_1(bit_1),
    .bit_0(bit_0)
);





//数码位转换成实际显示信号
bit_to_caseg bit_to_caseg_inst(
    .sclk           (sclk),
    .nrst           (nrst),
    .bit_7          (bit_7),
    .bit_6          (bit_6),
    .bit_5          (4'd10), //10表示空格
    .bit_4          (bit_4),
    .bit_3          (bit_3),
    .bit_2          (4'd11), //11表示横杆
    .bit_1          (bit_1),
    .bit_0          (bit_0),

    .sel            (sel),
    .seg            (seg)
);

endmodule