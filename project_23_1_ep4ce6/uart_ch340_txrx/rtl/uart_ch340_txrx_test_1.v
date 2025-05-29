/*测试1：按键按下，触发一次传输，发送出去一个字节'a'(0x61)*/
module uart_ch340_txrx_test_1(
    input wire sclk,
    input wire nrst,
    input wire key1,

    output wire tx,
    input wire rx
);

wire key_trigger;
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按
    .signal_interval (50)     // 识别为长按后，连续脉冲的输出间隔为50ms
) key_inst(
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key1),
    .key_out(key_trigger)
);//按键产生一个高电平脉冲信号，触发一次发送

wire tx_done, rx_done;
wire[7:0] tx_byte, rx_byte;
assign tx_byte = 8'h61;//发送的一个字节，对应的ASCII字符为'a'
uart_ctrler #(
    .sys_clk_freq (50_000_000),
    .baudrate (115200)
)
uart_ctrler_inst(
    .sclk(sclk),
    .nrst(nrst),

    .tx_trigger(key_trigger),
    .tx_done(tx_done),
    .rx_done(rx_done),

    .tx_byte(tx_byte),
    .rx_byte(rx_byte),

    .tx(tx),
    .rx(rx)
);

endmodule