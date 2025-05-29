module key_ctrl_led_toggle (
    input wire sclk,
    input wire nrst,
    input wire key,
    output led
);

wire key_out;
key #(
    .sclk_freq(50_000_000), // 系统时钟频率50MHz
    .press_vol(0), // 按键按下时为低电平
    .long_press(500), // 按键按住500ms后识别为长按
    .signal_interval(80) // 识别为长按后，连续脉冲的输出间隔为80ms
)
key_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key),
    .key_out(key_out)
);

led led_inst (
    .sclk(sclk),
    .nrst(nrst),
    .toggle_flag(key_out),

    .led(led)
);

endmodule