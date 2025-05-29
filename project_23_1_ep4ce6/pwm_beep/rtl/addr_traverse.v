/*这是一个遍历mif文件中所有地址的模块，0~799*/
/*输入时钟信号，输出不断自增的地址。*/
module addr_traverse #(
    parameter traverse_freq = 4,    //询历频率，即每秒询历多少个地址。
    parameter traverse_num = 700    //询历个数，即所有数据的个数。
)
(
    input   wire        sclk,
    input   wire        nrst,

    output  reg[15:0]   addr//16位地址，最多是2^16=65536个数据
);

/*cnt计数块，用以产生询历地址的频率，此频率在模块接口处。*/
reg[25:0]   cnt;
parameter   cnt_MAX = (50000000/traverse_freq)-1;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)               cnt <= 0;
    else if(cnt == cnt_MAX)     cnt <= 0;
    else                        cnt <= cnt + 1;
end

/*addr计数块，询历ROM中所有地址，依托于cnt更新事件。*/
parameter addr_MAX = traverse_num - 1;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                                   addr <= 0;
    else if(cnt == cnt_MAX && addr == addr_MAX)     addr <= 0;
    else if(cnt == cnt_MAX)                         addr <= addr + 1;
    else                                            addr <= addr;
end

endmodule
