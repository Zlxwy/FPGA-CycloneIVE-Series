/*测试2：数据回传*/
module uart_ch340_txrx_test_2(
    input wire sclk,
    input wire nrst,

    output wire tx,
    input wire rx
);

wire tx_done;
wire trig;//这根线把rx_done连上tx_trigger，也就是接收到一个字节后，立马触发一次发送
wire[7:0] a_byte;//把rx_byte连上tx_byte，把接收的字节发送回去

uart_ctrler #(
    .sys_clk_freq (50_000_000),
    .baudrate (115200)
)
uart_ctrler_inst(
    .sclk(sclk),
    .nrst(nrst),

    .tx_trigger(trig),
    .tx_done(tx_done),
    .rx_done(trig),

    .tx_byte(a_byte),
    .rx_byte(a_byte),

    .tx(tx),
    .rx(rx)
);

endmodule