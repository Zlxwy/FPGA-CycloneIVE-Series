/*按键信号处理，短按则输出一个脉冲，长按则连续脉冲，就像电脑键盘打字输入那种按键逻辑*/
module key #(
    parameter sclk_freq = 50_000_000,   // 系统时钟频率50MHz
    parameter press_vol = 0,            // 按键按下时为低电平
    parameter long_press = 500,         // 按键按住500ms后识别为长按
    parameter signal_interval = 100     // 识别为长按后，连续脉冲的输出间隔为100ms
)
(
    input wire sclk,
    input wire nrst,
    input wire key_in, // 原始按键信号
    output reg key_out // 出来的按键信号
);

reg[15:0] cnt_1ms;
parameter cnt_1ms_MAX = (sclk_freq / 1000) - 1; // 1ms为1000Hz频率的周期
// cnt_1ms
/*在按键按下时计数，计到最大值归零*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) cnt_1ms <= 0;
    else if(key_in != press_vol) cnt_1ms <= 0;
    else if(cnt_1ms == cnt_1ms_MAX) cnt_1ms <= 0;
    else cnt_1ms <= cnt_1ms + 1;
end

reg signal_1ms;
parameter cnt_1ms_MAX_minus_1 = cnt_1ms_MAX - 1; // -1，用于产生一个脉冲
// signal_1ms
/*在cnt_1ms即将更新之时，产生一个维持一个时钟周期的高电平脉冲*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) signal_1ms <= 0;
    else if(key_in != press_vol) signal_1ms <= 0;
    else if(cnt_1ms == cnt_1ms_MAX_minus_1) signal_1ms <= 1;
    else signal_1ms <= 0;
end

reg[15:0] cnt_20ms;
parameter cnt_20ms_MAX = 19;
parameter cnt_20ms_MAX_minus_1 = cnt_20ms_MAX - 1;
// cnt_20ms
/*依托于signal_1ms信号进行计数，计到最大值时会保持*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) cnt_20ms <= 0;
    else if(key_in != press_vol) cnt_20ms <= 0;
    else if(signal_1ms && cnt_20ms == cnt_20ms_MAX) cnt_20ms <= cnt_20ms;
    else if(signal_1ms) cnt_20ms <= cnt_20ms + 1;
    else cnt_20ms <= cnt_20ms;
end

reg cnt_long_press_enable;
// cnt_long_press_enable
/*如果cnt_20ms计数到最大值了，则拉高cnt_long_press_enable，表示准备识别长按*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) cnt_long_press_enable <= 0;
    else if(key_in != press_vol) cnt_long_press_enable <= 0;
    else if(signal_1ms && cnt_20ms == cnt_20ms_MAX) cnt_long_press_enable <= 1;
    else cnt_long_press_enable <= cnt_long_press_enable;
end

reg[15:0] cnt_long_press;
parameter cnt_long_press_MAX = long_press - 1;
// cnt_long_press
/*如果cnt_long_press_enable被拉高了，则开始计数来识别长按*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) cnt_long_press <= 0;
    else if(key_in != press_vol) cnt_long_press <= 0;
    else if(cnt_long_press_enable && signal_1ms && cnt_long_press == cnt_long_press_MAX)
        cnt_long_press <= cnt_long_press;
    else if(cnt_long_press_enable && signal_1ms)
        cnt_long_press <= cnt_long_press + 1;
    else cnt_long_press <= cnt_long_press;
end

reg long_press_ok;
// long_press_ok
/*cnt_long_press计数到最大值了，表示长按识别成功，拉高long_press_ok*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) long_press_ok <= 0;
    else if(key_in != press_vol) long_press_ok <= 0;
    else if(signal_1ms && cnt_long_press == cnt_long_press_MAX) long_press_ok <= 1;
    else long_press_ok <= long_press_ok;
end

reg[15:0] cnt_signal_interval;
parameter cnt_signal_interval_MAX = signal_interval - 1;
// cnt_signal_interval
/*如果long_press_ok被拉高了，开始进行循环计数，用于产生定间隔的脉冲信号*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) cnt_signal_interval <= 0;
    else if(key_in != press_vol) cnt_signal_interval <= 0;
    else if(long_press_ok && signal_1ms && cnt_signal_interval == cnt_signal_interval_MAX)
        cnt_signal_interval <= 0;
    else if(long_press_ok && signal_1ms)
        cnt_signal_interval <= cnt_signal_interval + 1;
    else cnt_signal_interval <= cnt_signal_interval;
end

// key_out
/*输出这一系列按键脉冲*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) key_out <= 0;
    else if(key_in != press_vol) key_out <= 0;
    /*这两条必须要加cnt_1ms == cnt_1ms_MAX，否则输出的key_out脉冲就会持续1ms而不是一个时钟周期了*/
    else if(signal_1ms && cnt_1ms == cnt_1ms_MAX && cnt_20ms == cnt_20ms_MAX_minus_1) key_out <= 1;
    else if(signal_1ms && cnt_1ms == cnt_1ms_MAX && cnt_signal_interval == cnt_signal_interval_MAX) key_out <= 1;
    else key_out <= 0;
end

endmodule