/*给bit_x输入十进制的数字，就会在数码管对应位上显示该数字。*/
/*seg[7~0]对应为显示段: DP, G, F, E, D, C, B, A*/
/*sel[7~0]对应为从左到右的显示位。*/
module caseg_disp(
    input   wire        sclk,
    input   wire        nrst,
    input   wire[3:0]   bit_7,
    input   wire[3:0]   bit_6,
    input   wire[3:0]   bit_5,
    input   wire[3:0]   bit_4,
    input   wire[3:0]   bit_3,
    input   wire[3:0]   bit_2,
    input   wire[3:0]   bit_1,
    input   wire[3:0]   bit_0,

    output  reg[7:0]    sel,
    output  reg[7:0]    seg
);

/*cnt_1ms以50MHz时钟信号计数，从0计到49999，不断循环，计一轮数用时1/50M*50000 = 10^(-3)s = 1ms*/
reg[15:0]   cnt_1ms;//计数周期1ms
parameter   cnt_1ms_MAX = 16'd49_999;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                       cnt_1ms <= 0;
    else if(cnt_1ms == cnt_1ms_MAX)     cnt_1ms <= 0;
    else                                cnt_1ms <= cnt_1ms + 1;
end

/*上面的1ms计数器计满一轮数后，signal_1ms会产生一个持续一个时钟周期的高电平。*/
reg signal_1ms;
parameter cnt_1ms_MAX_minus_1 = cnt_1ms_MAX - 1;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                               signal_1ms <= 0;
    else if(cnt_1ms == cnt_1ms_MAX_minus_1)     signal_1ms <= 1;
    else                                        signal_1ms <= 0;
end

/*cnt_bit以signal_1ms脉冲信号计数，从0计到7，不断循环。*/
reg[2:0]    cnt_bit;
parameter   cnt_bit_MAX = 7;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                                       cnt_bit <= 0;
    else if(signal_1ms == 1 && cnt_bit == cnt_bit_MAX)  cnt_bit <= 0;
    else if(signal_1ms == 1)                            cnt_bit <= cnt_bit + 1;
    else                                                cnt_bit <= cnt_bit;
end

reg[7:0]    sel_disp;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) sel_disp <= 8'b0000_0000;
    else if(signal_1ms == 1) begin
        case(cnt_bit)
            0: sel_disp <= 8'b0000_0001;
            1: sel_disp <= 8'b0000_0010;
            2: sel_disp <= 8'b0000_0100;
            3: sel_disp <= 8'b0000_1000;
            4: sel_disp <= 8'b0001_0000;
            5: sel_disp <= 8'b0010_0000;
            6: sel_disp <= 8'b0100_0000;
            7: sel_disp <= 8'b1000_0000;
            default: sel_disp <= sel_disp;
        endcase
    end
    else sel_disp <= sel_disp;
end

reg[3:0]    seg_disp;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) seg_disp <= 8'b0000_0000;
    else if(signal_1ms == 1) begin
        case(cnt_bit)
            0: seg_disp <= bit_0;
            1: seg_disp <= bit_1;
            2: seg_disp <= bit_2;
            3: seg_disp <= bit_3;
            4: seg_disp <= bit_4;
            5: seg_disp <= bit_5;
            6: seg_disp <= bit_6;
            7: seg_disp <= bit_7;
            default: seg_disp <= seg_disp;
        endcase
    end
    else seg_disp <= seg_disp;
end

always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)       sel <= 0;
    else                sel <= sel_disp;
end

always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) seg <= 0;
    else begin
        case(seg_disp)//共阳极数码管，是阴码字形
            0:  seg <= 8'b1100_0000;//数字0   8'hc0
            1:  seg <= 8'b1111_1001;//数字1   8'hf9
            2:  seg <= 8'b1010_0100;//数字2   8'ha4
            3:  seg <= 8'b1011_0000;//数字3   8'hb0
            4:  seg <= 8'b1001_1001;//数字4   8'h99
            5:  seg <= 8'b1001_0010;//数字5   8'h92
            6:  seg <= 8'b1000_0010;//数字6   8'h82
            7:  seg <= 8'b1111_1000;//数字7   8'hf8
            8:  seg <= 8'b1000_0000;//数字8   8'h80
            9:  seg <= 8'b1001_0000;//数字9   8'h90
            10: seg <= 8'b1111_1111;//空格    8'hff
            11: seg <= 8'b1011_1111;//横杠    8'hbf
            default: seg <= seg;
        endcase
    end
end

endmodule