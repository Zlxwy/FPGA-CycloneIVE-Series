/* 输入倒计时数值、计数器1数值、计数器2数值，输出每个位上的数字。
 * 比如此时倒计时为18、计数器1为23、计数器2为56，则：
 * bit_7 = 1
 * bit_6 = 8
 * bit_5 =（空格，用10表示）
 * bit_4 = 2
 * bit_3 = 3
 * bit_2 =（横杆，用11表示）
 * bit_1 = 5
 * bit_0 = 6
 */
module caseg_bit(
    input   wire[6:0]   down_cnt,
    input   wire[6:0]   up_cnt_1,
    input   wire[6:0]   up_cnt_2,

    output  wire[3:0]   bit_7,
    output  wire[3:0]   bit_6,
    output  wire[3:0]   bit_5,
    output  wire[3:0]   bit_4,
    output  wire[3:0]   bit_3,
    output  wire[3:0]   bit_2,
    output  wire[3:0]   bit_1,
    output  wire[3:0]   bit_0
);

assign bit_7 = down_cnt / 10;
assign bit_6 = down_cnt % 10;
assign bit_5 = 4'd10;//10表示空格
assign bit_4 = up_cnt_1 / 10;
assign bit_3 = up_cnt_1 % 10;
assign bit_2 = 4'd11;//11表示横杆
assign bit_1 = up_cnt_2 / 10;
assign bit_0 = up_cnt_2 % 10;

endmodule