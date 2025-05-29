/*这是一个把频率的数值，转换为25MHz时钟下计数周期的数值。*/
/*输入频率值，输出25MHz频率下的计数周期值。*/
module freq_to_period #(
    parameter source_clk = 25_000_000,  //源计数时钟的频率
    parameter duty_cycle = 20           //占空比，这是个百分比数值
)
(
    input   wire[10:0]  freq,   //目标PWM频率，最大是2047Hz

    output  reg[25:0]   period, //目标PWM频率对应的计数周期
    output  reg[25:0]   pulse   //目标PWM频率对应的比较值
);

always @(freq) begin
    case(freq)
        0: pulse <= 1;         //比较值降为1，音量调到最低值
        default: begin
            period <= source_clk / freq;    //对应的计数值
            pulse <= source_clk / freq / (100/duty_cycle);  //对应的比较值
        end
    endcase
end

endmodule