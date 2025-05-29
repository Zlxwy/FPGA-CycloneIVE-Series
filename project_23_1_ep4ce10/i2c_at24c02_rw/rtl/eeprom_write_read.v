//按下按键1，把一个固定的数写入AT24C02的指定地址，
//按下按键2，把这个数读取出来，显示在4个LED上
module eeprom_write_read(
    input   wire        sclk,
    input   wire        nrst,
    input   wire        key_orig_1,//按键1原始信号(original signal of key)
    input   wire        key_orig_2,//按键2原始信号(original signal of key)

    output  wire        scl,
    inout   wire        sda,
    output  wire[3:0]   led
);

wire key_flited_1;
key_debounce key_debounce_inst_1(
    .sclk           (sclk),
    .nrst           (nrst),
    .key_orig       (key_orig_1),

    .key_signal     (key_flited_1)
);//输入按键1原始信号，按下后输出一个高电平脉冲，连上write_trigger用来触发一次写入操作

wire key_flited_2;
key_debounce key_debounce_inst_2(
    .sclk           (sclk),
    .nrst           (nrst),
    .key_orig       (key_orig_2),

    .key_signal     (key_flited_2)
);//输入按键2原始信号，按下后输出一个高电平脉冲，连上read_trigger用来触发一次读取操作

wire[6:0] equi_addr;
wire[7:0] reg_addr;
wire[7:0] write_byte;
wire[7:0] read_byte;
wire write_done, read_done;//这两个信号不管
assign equi_addr = 7'b1010000;
//AT24C02的7位地址是 (1 0 1 0 A2 A1 A0)，不过实际测试时发现，无论低3位是什么数字，都可以正确读写，不知道为什么
assign reg_addr = 8'd32;            //在地址为32的寄存器进行读写操作
assign write_byte = 8'b0000_1010;   //写入数据0000_0101
assign led = read_byte[3:0];        //读取到的字节低4位映射到LED上

i2c_ctrler #(
    .sys_clk_freq (50000000),    //系统时钟频率，默认是50MHz
    .i2c_clk_speed (400000)      //I2C时钟速度，默认400kHz
)
i2c_ctrler_inst(
    .sclk           (sclk),
    .nrst           (nrst),
    .equi_addr      (equi_addr),
    .reg_addr       (reg_addr),
    .write_byte     (write_byte),
    .write_trigger  (key_flited_1),
    .read_trigger   (key_flited_2),

    .write_done     (write_done),
    .read_done      (read_done),
    .read_byte      (read_byte),

    .scl            (scl),
    .sda            (sda)
);

endmodule