module num_cnt #(
    parameter num_start = 0,
    parameter num_MAX = 999
)
(
    input wire sclk,
    input wire nrst,

    input wire state, //0: 停止状态 1: 启动状态

    input wire inc_sig, //Increment Signal
    input wire dec_sig, //Decrement Signal

    output reg[9:0] num //显示3位十进制数，最大999，用10位二进制
);

localparam STATE_STOP = 0;
localparam STATE_PLAY = 1;

// num
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) num <= num_start;
    /*在启动状态下，才可以增加数*/
    else if(state == STATE_PLAY && inc_sig && num >= num_MAX) num <= num_start;
    else if(state == STATE_PLAY && inc_sig) num <= num + 1;
    /*在停止状态下，才可以减小数*/
    else if(state == STATE_STOP && dec_sig && num <= num_start) num <= num_start;
    else if(state == STATE_STOP && dec_sig) num <= num - 1;
    else num <= num;
end

endmodule