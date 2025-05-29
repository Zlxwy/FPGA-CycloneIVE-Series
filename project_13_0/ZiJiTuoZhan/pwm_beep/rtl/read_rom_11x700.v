/*输入时钟信号和地址信号，输出ROM对应地址（10位宽）下的数据（11位宽）。*/
/*地址是0~699（10位宽），数据最大是2047（11位宽）。*/
/*700个11位宽的数据。*/
module read_rom_11x700(
    input   wire        sclk,
    input   wire        nrst,
    input   wire[15:0]  addr,

    output  wire[10:0]  data
);

/*实例化ROM的IP核模块*/
rom_11x700 rom_11x700_inst(
    .clock      (sclk),
    .address    (addr[9:0]),//截取10位宽的地址，对的
    
    .q          (data)
);

endmodule
