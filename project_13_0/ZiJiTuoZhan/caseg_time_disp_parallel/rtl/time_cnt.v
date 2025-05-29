//这是一个计时模块，产生时分秒的数值
module time_cnt(
    input   wire        clk,
    input   wire        rst,

    output  reg[5:0]    hour,
    output  reg[5:0]    minute,
    output  reg[5:0]    second
);

reg[25:0] cnt_1s;
parameter cnt_1s_MAX = 26'd49_999_999;
parameter hour_MAX   = 6'd23;
parameter minute_MAX = 6'd59;
parameter second_MAX = 6'd59;

/*cnt_1s计数块，0~49999999之间循环计数，计数周期1秒钟*/
always @(posedge clk or negedge rst) begin
    if(rst == 0)                    cnt_1s <= 0;
    else if(cnt_1s == cnt_1s_MAX)   cnt_1s <= 0;
    else                            cnt_1s <= cnt_1s + 1;
end

/*second计数块，依托于cnt_1s的更新事件，在0~59之间计数*/
always @(posedge clk or negedge rst) begin
    if(rst == 0)                                                second <= 0;
    else if((cnt_1s == cnt_1s_MAX) && (second == second_MAX))   second <= 0;
    else if(cnt_1s == cnt_1s_MAX)                               second <= second + 1;
    else                                                        second <= second;
end

/*minute计数块*/
always @(posedge clk or negedge rst) begin
    if(rst == 0)
        minute <= 0;
    else if((cnt_1s == cnt_1s_MAX) && (second == second_MAX) && (minute == minute_MAX))
        minute <= 0;
    else if((cnt_1s == cnt_1s_MAX) && (second == second_MAX))
        minute <= minute + 1;
    else
        minute <= minute;
end

/*hour计数块*/
always @(posedge clk or negedge rst) begin
    if(rst == 0)
        hour <= 0;
    else if((cnt_1s == cnt_1s_MAX) && (second == second_MAX) && (minute == minute_MAX) && (hour == hour_MAX))
        hour <= 0;
    else if((cnt_1s == cnt_1s_MAX) && (second == second_MAX) && (minute == minute_MAX))
        hour <= hour + 1;
    else
        hour <= hour;
end

endmodule