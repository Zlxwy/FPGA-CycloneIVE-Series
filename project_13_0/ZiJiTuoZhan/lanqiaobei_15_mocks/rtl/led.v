/*LED控制模块，根据倒计时的状态，控制LED的亮灭模式。*/
/* 启动状态(state = 3'b100)：LED点亮
 * 暂停状态(state = 3'b010)：LED闪烁，每100ms翻转电平
 * 停止状态(state = 3'b001)：LED熄灭
 */
module led(
    input   wire        sclk,
    input   wire        nrst,
    input   wire[2:0]   state,
    output  reg         led
);

reg[22:0] cnt_100ms;
parameter cnt_100ms_MAX = 4_999_999;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)   cnt_100ms <= 0;
    else if(cnt_100ms == cnt_100ms_MAX) cnt_100ms <= 0;
    else                                cnt_100ms <= cnt_100ms + 1;
end

always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                       led <= 0;
    else if(state == 3'b001)            led <= 0;       //如果是停止状态，LED熄灭
    else if(state == 3'b100)            led <= 1;       //如果是启动状态，LED点亮
    else if(cnt_100ms == cnt_100ms_MAX) led <= ~led;    //不是停止也不是启动状态，每100ms翻转电平
    else                                led <= led;
end

endmodule