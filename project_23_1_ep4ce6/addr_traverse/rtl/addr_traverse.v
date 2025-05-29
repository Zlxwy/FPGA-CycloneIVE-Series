/*每500ms地址自增，并输出对应地址下的数据*/
module addr_traverse(
    input   wire            sclk,
    input   wire            nrst,
    input   wire            key,
    output  wire[7:0]       led
);

key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按
    .signal_interval (63)     // 识别为长按后，连续脉冲的输出间隔为100ms
) key_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key), // 原始按键信号
    .key_out(key_signal) // 出来的按键信号
);

reg[3:0] addr;
parameter addr_MAX = 4'b1111;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) addr <= 0;
    else if(key_signal && addr == addr_MAX) addr <= 0;
    else if(key_signal) addr <= addr + 1;
    else addr <= addr;
end

rom_8x16 rom_8x16_inst (
    .address ( addr ),
    .clock ( sclk ),
    .q ( led )
);

endmodule