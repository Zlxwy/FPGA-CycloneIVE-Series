/*这是一个综合PWM波参数设置模块、PWM波生成模块的顶层模块*/
module top_pwm_breath_led(
    input   wire        sclk,
    input   wire        nrst,

    output  wire        beep,
    output  wire        beep_n
);



wire[25:0] period;
assign period = 1000;



reg[25:0] cnt_1ms;
parameter cnt_1ms_MAX = 49_999;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                       cnt_1ms <= 0;
    else if(cnt_1ms == cnt_1ms_MAX)     cnt_1ms <= 0;
    else                                cnt_1ms <= cnt_1ms + 1;
end



reg pwm_mode;
reg[25:0]  pulse;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) begin
        pulse <= 1;
        pwm_mode <= 0;
    end
    else if(cnt_1ms == cnt_1ms_MAX && pulse == 1000) begin
        pulse <= 1;
        pwm_mode <= ~pwm_mode;
    end
    else if(cnt_1ms == cnt_1ms_MAX)     pulse <= pulse + 1;
    else                                pulse <= pulse;
end



pwm_generator #(.prescaler(2)) pwm_generator_inst(
    .sclk       (sclk),
    .nrst       (nrst),
    .pwm_mode   (pwm_mode),
    .period     (period),
    .pulse      (pulse),

    .pwmout     (beep),
    .pwmout_n   (beep_n)
);

endmodule
