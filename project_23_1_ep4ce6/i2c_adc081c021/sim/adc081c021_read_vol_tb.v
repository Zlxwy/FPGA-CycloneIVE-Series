`timescale 1ns/1ns
module adc_081c021_read_vol_tb();

reg sclk, nrst;
initial begin
    sclk <= 0;
    nrst <= 0;
    #20
    nrst <= 1;
end

always #10 sclk <= ~sclk;

reg[31:0] cnt_100us;
parameter cnt_100us_MAX = 4999;
parameter cnt_100us_MAX_minus_1 = 4999;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) cnt_100us <= 0;
    else if(cnt_100us == cnt_100us_MAX) cnt_100us <= 0;
    else cnt_100us <= cnt_100us + 1;
end

reg read_trigger;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) read_trigger <= 0;
    else if(cnt_100us == cnt_100us_MAX_minus_1) read_trigger <= 1;
    else read_trigger <= 0;
end

wire UNUSED_read_done, UNUSED_voltage;
wire scl,sda;
adc_081c021_read_vol # (
    .sys_clk_freq (50_000_000),
    .i2c_clk_speed (400_000)
) adc_081c021_read_vol_inst (
    .sclk(sclk),
    .nrst(nrst),

    .read_trigger(read_trigger), //输入一个高电平脉冲信号，触发读取一次数据
    .read_done(UNUSED_read_done), //读取数据完成后，输出一个高电平脉冲信号
    .voltage(UNUSED_voltage), //读取到的原始8位数值，需要根据参考电压换算出伏特单位的电压值

    .scl(scl),
    .sda(sda)
);

endmodule