`timescale 1ns/1ns
module freq_to_period_tb();

reg[10:0] freq;
initial begin
    freq <= 2;
    #20;
    freq <= 3;
    #20;
    freq <= 4;
    #20;
    freq <= 5;
    #20;
    freq <= 6;
    #20;
end

wire[25:0] period,pulse;
freq_to_period #(
    .source_clk     (60),   //源计数时钟的频率
    .duty_cycle     (50)    //占空比，这是个百分比数值
)
freq_to_period_inst(
    .freq           (freq),     //目标PWM频率，最大是2047Hz

    .period         (period),   //目标PWM频率对应的计数周期
    .pulse          (pulse)     //目标PWM频率对应的比较值
);

endmodule