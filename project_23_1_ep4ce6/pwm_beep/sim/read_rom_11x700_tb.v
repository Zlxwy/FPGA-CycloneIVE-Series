`timescale 1ns/1ns
module read_rom_11x700_tb();

reg sclk,nrst;
initial begin
    sclk <= 0;
    nrst <= 0;
    #20;
    nrst <= 1;
end
always #10 sclk = ~sclk;

reg[15:0] addr;
always #15 begin
    if(addr == 699)     addr <= 0;
    else                addr <= addr + 1;
end

wire[10:0] data;
read_rom_11x700 read_rom_11x700_inst(
    .sclk       (sclk),
    .nrst       (nrst),
    .addr       (addr),

    .data       (data)
);

endmodule   