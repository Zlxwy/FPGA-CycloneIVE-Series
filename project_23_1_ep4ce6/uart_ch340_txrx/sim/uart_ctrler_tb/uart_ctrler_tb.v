`timescale 1ns/1ns
module uart_ctrler_tb();

reg sclk,nrst;
initial begin
    sclk <= 0;
    nrst <= 0;
    #20
    nrst <= 1;
end

always #10 sclk = ~sclk;

reg[31:0] cnt_10ms;
parameter cnt_10ms_MAX = 49_999_9;//100Hz
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) cnt_10ms <= 0;
    else if(cnt_10ms == cnt_10ms_MAX) cnt_10ms <= 0;
    else                            cnt_10ms <= cnt_10ms + 1;
end

reg tx_trigger;
parameter cnt_10ms_MAX_minus_1 = 49_999_8;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                               tx_trigger <= 0;
    else if(cnt_10ms == cnt_10ms_MAX_minus_1)     tx_trigger <= 1;
    else                                        tx_trigger <= 0;
end

wire tx_done, rx_done;
wire[7:0] tx_byte;
assign tx_byte = 8'b0011_1010;
wire[7:0] rx_byte;
wire tx, rx;
uart_ctrler #(
    .sys_clk_freq (50_000_000),
    .baudrate (115200)
)
uart_ctrler_inst
(
    .sclk(sclk),
    .nrst(nrst),

    .tx_trigger(tx_trigger),      //传入一个发送触发信号，触发一次串口发送
    .tx_done(tx_done),         //发送完成后，输出一个高电平脉冲
    .rx_done(rx_done),         //接收完成后，输出一个高电平脉冲

    .tx_byte(tx_byte),    //把发送字节传入，这个模块通过tx信号线输出去
    .rx_byte(rx_byte),    //这个模块通过rx信号线接收到一个字节后，把这个接收到的字节传出

    .tx(tx),              //发送信号线
    .rx(rx)               //接收信号线
);


endmodule