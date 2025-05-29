//向上计数的计数器，依托于按键信号
module up_counter #(
    parameter up_cnt_MAX = 99       //计分最大值
)
(
    input   wire        sclk,
    input   wire        nrst,
    input   wire        key_add,    //按键信号，用于控制计分数值的增加
    input   wire        cnt_enable, //因为在倒计时停止时，计分值不能自增，因此设置此使能输入，高电平有效

    output  reg[6:0]    cnt         //计分值，从0开始加，加到up_cnt_MAX就清零
);

always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                       cnt <= 0;
    else if(cnt_enable == 0)            cnt <= cnt;
    else if(key_add == 1 && cnt == up_cnt_MAX) cnt <= 0;
    else if(key_add == 1)               cnt <= cnt + 1;
    else                                cnt <= cnt;
end

endmodule