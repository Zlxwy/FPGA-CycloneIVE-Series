module mif_test(
    input   wire            sclk,
    input   wire            nrst,
    output  wire[3:0]       data
);

reg[25:0] cnt_500ms;
parameter cnt_500ms_MAX = 24_999_999;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                               cnt_500ms <= 0;
    else if(cnt_500ms == cnt_500ms_MAX)         cnt_500ms <= 0;
    else                                        cnt_500ms <= cnt_500ms + 1;
end

reg[4:0] addr;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)   addr <= 0;
    else if(cnt_500ms == cnt_500ms_MAX) addr <= addr + 1;
    else                                addr <= addr;
end

rom_4x32 rom_4x32_inst (
    .clock      (sclk),
    .address    (addr),
    .q          (data)
);

endmodule