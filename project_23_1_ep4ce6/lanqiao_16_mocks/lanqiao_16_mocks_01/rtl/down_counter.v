module down_counter #(
    parameter down_cnt_MAX = 20     //传入的倒计时起始数值
)
(
    input   wire        sclk,
    input   wire        nrst,
    input   wire        key_pp,     //pause/play按键信号，控制倒计时暂停/启动

    output  reg[6:0]    cnt,        //输出的倒计时值，在启动状态下每秒减1
    output  reg[2:0]    cnt_state,  //状态：启动(3'b100)、暂停(3'b010)、停止(3'b001)
    output  wire        is_counting //是否在计数？暂停或停止时为低电平，启动时为高电平。这个用于控制计分按键是否起作用。
);

/*change state block.*/
localparam CNT_STOP  = 3'b001;  //停止状态
localparam CNT_PAUSE = 3'b010;  //暂停状态
localparam CNT_PLAY  = 3'b100;  //启动状态
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                                       cnt_state <= CNT_STOP;
    else if(key_pp == 1 && cnt_state == CNT_STOP)       cnt_state <= CNT_PLAY;  //倒计时停止时，按键按下
    else if(key_pp == 1 && cnt_state == CNT_PAUSE)      cnt_state <= CNT_PLAY;  //倒计时暂停时，按键按下
    else if(key_pp == 1 && cnt_state == CNT_PLAY)       cnt_state <= CNT_PAUSE; //倒计时进行时，按键按下
    else if(cnt_1s == cnt_1s_MAX && cnt == 1)           cnt_state <= CNT_STOP;  //倒计时计数归零时
    else                                                cnt_state <= cnt_state;
end
assign is_counting = cnt_state[2] & (~cnt_state[1]) & (~cnt_state[0]);

/*依托于时钟信号，进行周期为1s的循环计数。*/
reg[25:0]   cnt_1s;//计数周期1s
parameter   cnt_1s_MAX = 26'd49_999_999;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                       cnt_1s <= 0;
    else if(cnt_1s == cnt_1s_MAX)       cnt_1s <= 0;
    else if(cnt_state == CNT_STOP)      cnt_1s <= 0;       //倒计时停止时，终止驱动并清零
    else if(cnt_state == CNT_PAUSE)     cnt_1s <= cnt_1s;  //倒计时暂停时，暂停驱动
    else                                cnt_1s <= cnt_1s + 1;
end

always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                                   cnt <= down_cnt_MAX;
    else if(key_pp == 1 && cnt_state == CNT_STOP)   cnt <= down_cnt_MAX;//倒计时停止时，按键按下
    else if(cnt_1s == cnt_1s_MAX)                   cnt <= cnt - 1;
    else                                            cnt <= cnt;
end

endmodule