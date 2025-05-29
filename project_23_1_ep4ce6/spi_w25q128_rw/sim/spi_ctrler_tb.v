`timescale 1ns/1ns
module spi_ctrler_tb();

reg sclk,nrst;
initial begin
    sclk <= 0;
    nrst <= 0;
    #25
    nrst <= 1;
end

always #10 sclk = ~sclk;

reg[31:0] cnt_1ms;
parameter cnt_1ms_MAX = 49_999_9;//100Hz
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) cnt_1ms <= 0;
    else if(cnt_1ms == cnt_1ms_MAX) cnt_1ms <= 0;
    else                            cnt_1ms <= cnt_1ms + 1;
end

reg swap_trigger;
parameter cnt_1ms_MAX_minus_1 = 49_999_8;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                               swap_trigger <= 0;
    else if(cnt_1ms == cnt_1ms_MAX_minus_1)     swap_trigger <= 1;
    else                                        swap_trigger <= 0;
end

wire[7:0] write_byte, read_byte;
assign write_byte = 8'b1101_0110;
wire swap_done, sck, mosi, miso;
assign miso = 1;
spi_ctrl #(
    .sclk_freq (50_000_000), //系统时钟频率
    .spi_clk_speed (500_000) //spi_sck的频率
) spi_ctrl_inst (
    .sclk(sclk),
    .nrst(nrst),

    .write_byte(write_byte),
    .read_byte(read_byte),

    .swap_trigger(swap_trigger),
    .swap_done(swap_done),

    // output reg cs,
    .sck(sck),
    .mosi(mosi),
    .miso(miso)
);

endmodule