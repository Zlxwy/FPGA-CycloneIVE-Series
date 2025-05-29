`timescale 1ns/1ns
module addr_traverse_tb();

reg sclk,nrst;
initial begin
    sclk <= 0;
    nrst <= 0;
    #20
    nrst <= 1;
end

always #10 sclk = ~sclk;

wire[15:0] addr;
addr_traverse #(
    .traverse_freq  (25_000_000),//遍历频率写大一点，计数就会小
    .traverse_num   (10)  //遍历10个地址就行
)
addr_traverse_inst(
    .sclk           (sclk),
    .nrst           (nrst),

    .addr           (addr)
);

endmodule
