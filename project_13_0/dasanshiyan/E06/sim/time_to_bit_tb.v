`timescale 1ns/1ns
module time_to_bit_tb();

reg clk,rst;
reg[5:0] hour,minute,second;
wire[3:0] bit_7,bit_6,bit_5,bit_4,bit_3,bit_2,bit_1,bit_0;

initial begin
    clk <= 0;
    rst <= 0;
    #20
    rst <= 1;
end

always #10 clk = ~clk;

reg[10:0] cnt;
parameter cnt_MAX = 11'd25;

always @(posedge clk or negedge rst)
    if(rst == 0)                cnt <= 0;
    else if(cnt == cnt_MAX)     cnt <= 0;
    else                        cnt <= cnt + 1;

always @(posedge clk or negedge rst)
    if(rst == 0)        hour <= 0;
    else if(cnt == cnt_MAX && hour >= 23)   hour <= 0;
    else if(cnt == cnt_MAX)                 hour <= hour + 1;
    else                                    hour <= hour;

always @(posedge clk or negedge rst)
    if(rst == 0)        minute <= 0;
    else if(cnt == cnt_MAX && minute >= 59)   minute <= 0;
    else if(cnt == cnt_MAX)                 minute <= minute + 2;
    else                                    minute <= minute;

always @(posedge clk or negedge rst)
    if(rst == 0)        second <= 0;
    else if(cnt == cnt_MAX && second >= 59)   second <= 0;
    else if(cnt == cnt_MAX)                 second <= second + 2;
    else                                    second <= second;


time_to_bit time_to_bit_inst(
    .clk(clk),
    .rst(rst),
    .hour(hour),
    .minute(minute),
    .second(second),
    
    /*从右到左依次为bit_0~7*/
    .bit_7(bit_7),
    .bit_6(bit_6),
    .bit_5(bit_5),
    .bit_4(bit_4),
    .bit_3(bit_3),
    .bit_2(bit_2),
    .bit_1(bit_1),
    .bit_0(bit_0)
);

endmodule