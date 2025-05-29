`timescale 1ns/1ns
module i2c_write_read_tb();

reg sclk,nrst;
initial begin
    sclk <= 0;
    nrst <= 0;
    #20
    nrst <= 1;
end

always #10 sclk = ~sclk;

wire[6:0] equi_addr;
wire[7:0] reg_addr;
wire[7:0] write_byte;
assign equi_addr = 7'b1010_000;
assign reg_addr = 8'b1011_0101;
assign write_byte = 8'b0010_1101;

reg[31:0] cnt_1ms;
parameter cnt_1ms_MAX = 49_999_9;//100Hz
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) cnt_1ms <= 0;
    else if(cnt_1ms == cnt_1ms_MAX) cnt_1ms <= 0;
    else                            cnt_1ms <= cnt_1ms + 1;
end

reg write_trigger;
parameter cnt_1ms_MAX_minus_1 = 49_999_8;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                               write_trigger <= 0;
    else if(cnt_1ms == cnt_1ms_MAX_minus_1)     write_trigger <= 1;
    else                                        write_trigger <= 0;
end

reg read_trigger;
parameter cnt_1ms_MAX_divided_2 = 24_999_8;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                               read_trigger <= 0;
    else if(cnt_1ms == cnt_1ms_MAX_divided_2)   read_trigger <= 1;
    else                                        read_trigger <= 0;
end

wire write_done;
wire read_done;
tri read_byte;
wire scl;
wire sda;
i2c_write_read #(
    .sys_clk_freq (50_000_000),    //系统时钟频率，默认是50MHz
    .i2c_clk_speed (400_000)       //I2C时钟速度，默认400kHz（这个输入参数最好是系统时钟频率的被整除数）
)
i2c_write_read_inst(
    .sclk           (sclk),
    .nrst           (nrst),
    .equi_addr      (equi_addr),
    .reg_addr       (reg_addr),
    .write_byte     (write_byte),
    .write_trigger  (write_trigger),
    .read_trigger   (read_trigger),

    .write_done     (write_done),
    .read_done      (read_done),
    .read_byte      (read_byte),

    .scl            (scl),
    .sda            (sda)
);

endmodule