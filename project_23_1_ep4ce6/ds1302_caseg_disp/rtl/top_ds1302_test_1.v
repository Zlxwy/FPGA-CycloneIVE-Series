/*按键触发一次设置/读取*/
module top_ds1302_test_1 (
    input wire sclk,
    input wire nrst,
    input wire key_set,
    input wire key_get,

    output wire[7:0] sel,
    output wire[7:0] seg,

    output wire ds1302_ce, //ds1302片选信号
    output wire ds1302_sclk, //ds1302时钟信号
    inout wire ds1302_io //ds1302数据信号，双向IO口
);

wire key_set_signal;
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms
) key_set_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key_set), // 原始按键信号
    .key_out(key_set_signal) // 出来的按键信号
);
wire key_get_signal;
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms
) key_get_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key_get), // 原始按键信号
    .key_out(key_get_signal) // 出来的按键信号
);

/*写入寄存器的时间数据*/
localparam BCD_WP     = 8'h00;
localparam BCD_YEAR   = 8'h78;
localparam BCD_DAY    = 8'h06;
localparam BCD_MONTH  = 8'h08;
localparam BCD_DATE   = 8'h15;
localparam BCD_HOUR   = 8'h01;
localparam BCD_MINUTE = 8'h29;
localparam BCD_SECOND = 8'h00;

wire[63:0] bcd_time_set, bcd_time_get;
assign bcd_time_set = {BCD_WP, BCD_YEAR, BCD_DAY, BCD_MONTH, BCD_DATE, BCD_HOUR, BCD_MINUTE, BCD_SECOND};
ds1302_all_time_rw #(
    .sys_clk_freq(50_000_000),
    .ds1302_clk_speed(500_000)
    //如何计算一次读取/设置操作的时间？：(130 / ds1302_clk_speed) second （默认值为650us.1538Hz）
    //= (1/sys_clk_freq) * (sys_clk_freq/ds1302_clk_speed/4) * rw_step_cnt_MAX * sg_step_cnt_MAX
) ds1302_all_time_rw_inst (
    .sclk(sclk),
    .nrst(nrst),

    .set_trig(key_set_signal),
    .get_trig(key_get_signal),

    /* {wp, year, day, month, date, hour, minute, second} */
    .bcd_time_set(bcd_time_set),
    .bcd_time_get(bcd_time_get),

    .ds1302_ce(ds1302_ce), //ds1302片选信号
    .ds1302_sclk(ds1302_sclk), //ds1302时钟信号
    .ds1302_io(ds1302_io) //ds1302数据信号，双向IO口
);

bit_to_caseg bit_to_caseg_inst (
    .sclk(sclk),
    .nrst(nrst),
    .bit_7(bcd_time_get[23:20]),
    .bit_6(bcd_time_get[19:16]),
    .bit_5(4'd11),
    .bit_4(bcd_time_get[15:12]),
    .bit_3(bcd_time_get[11: 8]),
    .bit_2(4'd11),
    .bit_1(bcd_time_get[ 7: 4]),
    .bit_0(bcd_time_get[ 3: 0]),
    
    .sel(sel),
    .seg(seg)
);

endmodule