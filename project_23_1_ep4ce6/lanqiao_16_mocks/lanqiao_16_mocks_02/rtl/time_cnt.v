module time_cnt #(
    parameter min_start = 0,
    parameter min_MAX = 59,
    parameter sec_start = 0,
    parameter sec_MAX = 59,
    parameter deci_sec_start = 0,
    parameter deci_sec_MAX = 9
)
(
    input wire sclk,
    input wire nrst,

    input wire state, // 0: 停止计数 1: 计数

    input wire[23:0] update, //用于更新时间计数
    input wire update_trigger, //更新触发信号

    output reg[7:0] min,
    output reg[7:0] sec,
    output reg[7:0] deci_sec
);

localparam STATE_PLAY = 1;
localparam STATE_STOP = 0;

reg[31:0] cnt_100ms;
reg signal_100ms;
parameter cnt_100ms_MAX = 4_999_999;
parameter cnt_100ms_MAX_minus_1 = cnt_100ms_MAX - 1;
// cnt_100ms
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) cnt_100ms <= 0;
    /*停止状态下，响应更新触发信号，没有触发信号则保持不动*/
    else if(state == STATE_STOP && update_trigger) cnt_100ms <= 0;
    else if(state == STATE_STOP) cnt_100ms <= cnt_100ms;
    /*启动状态正常计数*/
    else if(cnt_100ms == cnt_100ms_MAX) cnt_100ms <= 0;
    else cnt_100ms <= cnt_100ms + 1;
end
// signal_100ms
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) signal_100ms <= 0;
    /*停止状态下，响应更新触发信号，没有触发信号则保持不动*/
    else if(state == STATE_STOP && update_trigger) signal_100ms <= 0;
    else if(state == STATE_STOP) signal_100ms <= signal_100ms;
    /*启动状态正常计数*/
    else if(cnt_100ms == cnt_100ms_MAX_minus_1) signal_100ms <= 1;
    else signal_100ms <= 0;
end


wire[7:0] update_min, update_sec, update_deci_sec;
assign update_min = update[23:16];
assign update_sec = update[15:8];
assign update_deci_sec = update[7:0];

//deci_sec
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) deci_sec <= deci_sec_start;
    /*停止状态下，响应更新触发信号，没有触发信号则保持不动*/
    else if(state == STATE_STOP && update_trigger) deci_sec <= update_deci_sec;
    else if(state == STATE_STOP) deci_sec <= deci_sec;
    /*启动状态正常计数*/
    else if(signal_100ms && deci_sec >= deci_sec_MAX) deci_sec <= deci_sec_start;
    else if(signal_100ms) deci_sec <= deci_sec + 1;
    else deci_sec <= deci_sec;
end

// sec
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) sec <= sec_start;
    /*停止状态下，响应更新触发信号，没有触发信号则保持不动*/
    else if(state == STATE_STOP && update_trigger) sec <= update_sec;
    else if(state == STATE_STOP) sec <= sec;
    /*启动状态正常计数*/
    else if(signal_100ms && deci_sec >= deci_sec_MAX && sec >= sec_MAX) sec <= sec_start;
    else if(signal_100ms && deci_sec >= deci_sec_MAX) sec <= sec + 1;
    else sec <= sec;
end

// min
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) min <= min_start;
    /*停止状态下，响应更新触发信号，没有触发信号则保持不动*/
    else if(state == STATE_STOP && update_trigger) min <= update_min;
    else if(state == STATE_STOP) min <= min;
    /*启动状态正常计数*/
    else if(signal_100ms && deci_sec >= deci_sec_MAX && sec >= sec_MAX && min >= min_MAX) min <= min_start;
    else if(signal_100ms && deci_sec >= deci_sec_MAX && sec >= sec_MAX) min <= min + 1;
    else min <= min;
end

endmodule