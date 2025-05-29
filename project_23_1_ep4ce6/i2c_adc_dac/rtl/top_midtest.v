/*中途测试*/
module top_test (
    input wire sclk,
    input wire nrst,
    input wire key,
    output wire scl,
    inout wire sda,
//逻辑分析仪调试---------------------------------------------------------------------|
    output wire DEBUG_scl,
    output wire DEBUG_sda
//逻辑分析仪调试---------------------------------------------------------------------|
);

wire key_signal;
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按，参数范围[2~4294967295]ms
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms，参数范围[2~4294967295]ms
) key_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key), // 原始按键信号
    .key_out(key_signal) // 出来的按键信号
);

wire[7:0] vol;
adc081c021_dac5571 # (
    .sys_clk_freq (50_000_000),
    .i2c_clk_speed (400_000)
) adc081c021_dac5571_inst (
    .sclk(sclk),
    .nrst(nrst),
    .gs_trig(key_signal), //输入一个触发信号，触发一次获取电压并设置电压
    .gs_done(), //获取电压并设置电压完成后，输出一个高电平脉冲
    .vol(vol), //获取的电压值
    .scl(scl),
    .sda(sda),
    .DEBUG_scl(DEBUG_scl),
    .DEBUG_sda(DEBUG_sda)
);

endmodule