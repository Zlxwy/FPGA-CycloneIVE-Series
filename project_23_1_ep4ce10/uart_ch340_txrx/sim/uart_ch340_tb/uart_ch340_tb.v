`timescale 1ms/1ms
module uart_ch340_tb();

reg sclk,nrst;
initial begin
    sclk <= 0;
    nrst <= 0;
    #20
    nrst <= 1;
end

always #10 sclk = ~sclk;

reg[31:0] cnt_500ms;
parameter cnt_500ms_MAX = 24_999_999;//2Hz
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) cnt_500ms <= 0;
    else if(cnt_500ms == cnt_500ms_MAX) cnt_500ms <= 0;
    else                            cnt_500ms <= cnt_500ms + 1;
end

wire key;
assign key = (cnt_500ms > 12500000) ? 1 : 0;

wire tx,rx;
uart_ch340_txrx_test_1 uart_ch340_txrx_test_1_inst(
    .sclk(sclk),
    .nrst(nrst),
    .key1(key),

    .tx(tx),
    .rx(rx)
);

endmodule