module top_module (
    input wire sclk,
    input wire nrst,

    output wire adc_scl,
    inout wire adc_sda,

    output wire[7:0] sel,
    output wire[7:0] seg,

    output wire DEBUG_scl,
    output wire DEBUG_sda
);

wire read_trigger;
pulse_generator #(
    .sys_clk_freq (50_000_000),
    .interval (1000_000) //单位为ns，取值范围[40,85899345920]
) pulse_generator (
    .sclk(sclk),
    .nrst(nrst),
    .enable(1'b1),
    .trigger(read_trigger)
);

wire UNUSED_read_done;
wire[7:0] voltage;
adc_081c021_read_vol # (
    .sys_clk_freq (50_000_000),
    .i2c_clk_speed (200_000)
    // 如何计算一次读操作的时间？：(28.5 / i2c_clk_speed) second （默认值的话为71.25us.14035Hz）
    // = (1/sys_clk_freq) * (sys_clk_freq/i2c_clk_speed)/4 * read_step_cnt_MAX
) adc_081c021_read_vol_inst (
    .sclk(sclk),
    .nrst(nrst),

    .read_trigger(read_trigger), //输入一个高电平脉冲信号，触发读取一次数据
    .read_done(UNUSED_read_done), //读取数据完成后，输出一个高电平脉冲信号
    .voltage(voltage), //读取到的原始8位数值，需要根据参考电压换算出伏特单位的电压值

    .scl(adc_scl),
    .sda(adc_sda),
//逻辑分析仪调试---------------------------------------------------------------------|
    .DEBUG_scl(DEBUG_scl),
    .DEBUG_sda(DEBUG_sda)
//逻辑分析仪调试---------------------------------------------------------------------|
);

wire[3:0] vol_hdrs, vol_tens, vol_ones;
assign vol_hdrs = voltage / 100;
assign vol_tens = voltage / 10 % 10;
assign vol_ones = voltage % 10;

bit_to_caseg bit_to_caseg_inst (
    .sclk(sclk),
    .nrst(nrst),
    .bit_7(4'd10),
    .bit_6(4'd10),
    .bit_5(4'd10),
    .bit_4(4'd10),
    .bit_3(4'd10),
    .bit_2(vol_hdrs),
    .bit_1(vol_tens),
    .bit_0(vol_ones),
    
    .sel(sel),
    .seg(seg)
);

endmodule