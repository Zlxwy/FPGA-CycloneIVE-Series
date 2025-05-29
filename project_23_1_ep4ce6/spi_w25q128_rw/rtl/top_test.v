/*按下key_write，向flash写入一个字节（44行），然后按下key_read，从写入的地址中读出字节，显示在led上*/
module top_test (
    input wire sclk,
    input wire nrst,
    input wire key_write,
    input wire key_read,
    output wire[7:0] led,
    output wire cs,
    output wire sck,
    output wire mosi,
    input wire miso
);

wire key_write_signal, key_read_signal;
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms
) key_write_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key_write), // 原始按键信号
    .key_out(key_write_signal) // 出来的按键信号
);
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms
) key_read_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key_read), // 原始按键信号
    .key_out(key_read_signal) // 出来的按键信号
);

wire[23:0] flash_addr;
wire[7:0] write_byte;
wire write_done, read_done;
// assign flash_addr = 24'h7FF000;
// assign write_byte = 8'b0010_0110;
assign flash_addr = 24'h000000;
assign write_byte = 8'b0011_0011;
spi_w25q128 #(
    .sclk_freq (50_000_000), //系统时钟频率
    .sck_speed (500_000) //spi_sck的频率
)    
(
    .sclk(sclk),
    .nrst(nrst),
    .flash_addr(flash_addr),
    .write_byte(write_byte),
    .read_byte(led),

    .write_trigger(key_write_signal),
    .read_trigger(key_read_signal),
    .write_done(write_done),
    .read_done(read_done),

    .cs(cs),
    .sck(sck),
    .mosi(mosi),
    .miso(miso)
);

endmodule