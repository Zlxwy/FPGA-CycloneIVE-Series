/*综合所有模块，使蜂鸣器发出声音的模块。*/
module top_pwm_beep(
    input   wire        sclk,
    input   wire        nrst,

    output  wire        beep,
    output  wire        beep_n
);





/*输入时钟，输出16位不断自增的地址*/
wire[15:0] tone_addr;
addr_traverse #(
    .traverse_freq(5),//5Hz频率遍历
    .traverse_num(700)//有700个地址
)
addr_traverse_inst(
    .sclk   (sclk),
    .nrst   (nrst),

    .addr   (tone_addr)
);





/*输入16位地址，输出ROM地址下对应的11位音阶频率数据*/
wire[10:0] tone_freq;
read_rom_11x700 read_rom_11x700_inst(
    .sclk       (sclk),
    .nrst       (nrst),
    .addr       (tone_addr),

    .data       (tone_freq)
);





/*输入11位音阶频率数据，输出25位的计数周期值和比较值。*/
wire[25:0] period,pulse;
freq_to_period #(
    .source_clk (25_000_000),   //源计数时钟频率
    .duty_cycle (50)             //占空比
)
freq_to_period_inst(
    .freq       (tone_freq),

    .period     (period),
    .pulse      (pulse)
);





/*输入PWM模式、计数周期值、比较值，最终输出PWM*/
wire pwm_mode;
assign pwm_mode = 0;
pwm_generator #(.prescaler(2))//预分频值，50MHz分频后是25MHz了
pwm_generator_inst(
    .sclk       (sclk),
    .nrst       (nrst),
    .pwm_mode   (pwm_mode),
    .period     (period),
    .pulse      (pulse),

    .pwmout     (beep),
    .pwmout_n   (beep_n)
);



endmodule