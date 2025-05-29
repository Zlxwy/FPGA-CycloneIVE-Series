`timescale 1ns/1ns
module ds1302_ctrler_tb();

reg sclk,nrst;
initial begin
    sclk <= 0;
    nrst <= 0;
    #25
    nrst <= 1;
end

always #10 sclk = ~sclk;

wire[7:0] addr,write_byte;
assign addr = 8'b1000_0010; // h82;
assign write_byte = 8'b1011_0101; // hb5;

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

wire write_done,read_done;
wire[7:0] read_byte;
wire ds1302_ce,ds1302_sclk,ds1302_io;
ds1302_ctrler #(
    .sclk_freq (50_000_000),
    .ds1302_clk_speed (500_000) // 取500kHz
)
ds1302_ctrler_inst(
    .sclk(sclk),
    .nrst(nrst),

    .addr(addr),
    .write_byte(write_byte),
    .read_byte(read_byte),

    .write_trigger(write_trigger),
    .read_trigger(read_trigger),
    .write_done(write_done),
    .read_done(read_done),
    
    .ds1302_ce(ds1302_ce),
    .ds1302_sclk(ds1302_sclk),
    .ds1302_io(ds1302_io)
);

endmodule