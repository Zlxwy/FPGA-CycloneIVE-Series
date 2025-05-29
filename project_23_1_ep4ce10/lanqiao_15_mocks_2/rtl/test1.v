//这个模块用来验证eeprom_3bytes_rw模块的
/*按键key_wr触发往eeprom写入3个字节，key_rw触发从eeprom读取3个字节*/
module test1 (
    input wire sclk,
    input wire nrst,

    input wire key_wr,
    input wire key_rd,

    output wire ds,
    output wire shcp,
    output wire stcp,
    output wire oe,

    output wire eeprom_scl,
    inout wire eeprom_sda
);
wire key_wr_signal;
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms
) key_wr_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key_wr), // 原始按键信号
    .key_out(key_wr_signal) // 出来的按键信号
);
wire key_rd_signal;
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms
) key2_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key_rd), // 原始按键信号
    .key_out(key_rd_signal) // 出来的按键信号
);

wire[3:0] bit_7,bit_6,bit_5,bit_4,bit_3,bit_2,bit_1,bit_0;
wire[23:0] read_3bytes;
assign bit_7 = read_3bytes[23:16] / 10;
assign bit_6 = read_3bytes[23:16] % 10;
assign bit_5 = 11;
assign bit_4 = read_3bytes[15: 8] / 10;
assign bit_3 = read_3bytes[15: 8] % 10;
assign bit_2 = 11;
assign bit_1 = read_3bytes[ 7: 0] / 10;
assign bit_0 = read_3bytes[ 7: 0] % 10;

wire wr_done, rd_done;
eeprom_3bytes_rw #(
    .equi_addr (7'b1010_000) //从机未左移的原7位地址
) eeprom_3bytes_rw_inst (
    .sclk(sclk),
    .nrst(nrst),
    .start_reg_addr(8'd10), //EEPROM读写寄存器的起始地址
    .write_3bytes({8'd23, 8'd56, 8'd39}), //要写入的3个字节
    .read_3bytes(read_3bytes), //要读取的3个字节

    .write_3bytes_trig(key_wr_signal),
    .read_3bytes_trig(key_rd_signal),
    .write_3bytes_done(wr_done),
    .read_3bytes_done(rd_done),

    .eeprom_scl(eeprom_scl),
    .eeprom_sda(eeprom_sda)
);

wire[7:0] sel, seg;
bit_to_caseg bit_to_caseg_inst (
    .sclk(sclk),
    .nrst(nrst),
    .bit_7(bit_7),
    .bit_6(bit_6),
    .bit_5(bit_5),
    .bit_4(bit_4),
    .bit_3(bit_3),
    .bit_2(bit_2),
    .bit_1(bit_1),
    .bit_0(bit_0),
    
    .sel(sel),
    .seg(seg)
);
caseg_to_hc595 caseg_to_hc595_inst (
    .sclk(sclk),//系统时钟50MHz
    .nrst(nrst),//复位信号，低电平有效
    .sel(sel),//位选信号，控制哪个位显示
    .seg(seg),//段选信号，控制位上显示的字形

    .ds(ds),//数据输入端
    .shcp(shcp),//移位时钟，上升沿移位
    .stcp(stcp),//输出时钟，上升沿
    .oe(oe)//使能端，低电平有效
);

endmodule