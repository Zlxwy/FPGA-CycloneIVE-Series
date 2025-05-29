/*每接收到一个维持一个时钟周期的脉冲信号，LED翻转一次电平*/
module led (
    input wire sclk,
    input wire nrst,
    input wire toggle_flag,

    output reg led
);

always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) led <= 0;
    else if(toggle_flag) led <= !led;
    else led <= led;
end

endmodule