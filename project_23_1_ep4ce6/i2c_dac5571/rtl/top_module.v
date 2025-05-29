module top_module (
    input wire sclk,
    input wire nrst,
    input wire key,

    output wire dac_scl,
    inout wire dac_sda,

    output wire[7:0] sel,
    output wire[7:0] seg
);


wire key_signal;
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按，参数范围[2~4294967295]ms
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms，参数范围[2~4294967295]ms
) key_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key), // 原始按键信号
    .key_out(key_signal) // 出来的按键信号
);

reg state;
localparam STATE_PLAY = 1;
localparam STATE_STOP = 0;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) state <= STATE_PLAY;
    else if(state == STATE_PLAY && key_signal) state <= STATE_STOP;
    else if(state == STATE_STOP && key_signal) state <= STATE_PLAY;
    else state <= state;
end

wire dac_set_trig;
pulse_generator #(
    .sys_clk_freq (50_000_000),
    .interval (5_000_000) //单位为ns，取值范围[40,85899345920]
) pulse_generator_inst (
    .sclk(sclk),
    .nrst(nrst),
    .enable(state),
    .trigger(dac_set_trig)
);

reg[7:0] reg_vol; //电压值
reg is_up_cnt; //计数方向，是否向上计数
parameter reg_vol_MAX = 255;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) begin reg_vol <= 0; is_up_cnt <= 1; end
    else if(state == STATE_STOP) begin reg_vol <= reg_vol; is_up_cnt <= is_up_cnt; end

    else if(dac_set_trig && is_up_cnt && reg_vol == reg_vol_MAX) begin reg_vol <= reg_vol; is_up_cnt <= ~is_up_cnt; end
    else if(dac_set_trig && is_up_cnt) begin reg_vol <= reg_vol + 1; is_up_cnt <= is_up_cnt; end

    else if(dac_set_trig && !is_up_cnt && reg_vol == 0) begin reg_vol <= reg_vol; is_up_cnt <= ~is_up_cnt; end
    else if(dac_set_trig && !is_up_cnt) begin reg_vol <= reg_vol - 1; is_up_cnt <= is_up_cnt; end

    else begin reg_vol <= reg_vol; is_up_cnt <= is_up_cnt; end
end

dac5571_set_vol #(
    .sys_clk_freq (50_000_000),
    .i2c_clk_speed (400_000),
    .i2c_equi_addr (7'b1001_100) //因为dac有个更改器件地址的引脚
) dac5571_set_vol_inst (
    .sclk(sclk),
    .nrst(nrst),
    .vol(reg_vol),
    .set_trig(dac_set_trig),
    .set_done(),
    .dac_scl(dac_scl),
    .dac_sda(dac_sda)
);

wire[3:0] bit_2, bit_1, bit_0;
wire[3:0] bit_2_disp, bit_1_disp, bit_0_disp;
assign bit_2 = reg_vol / 100;
assign bit_1 = reg_vol / 10 % 10;
assign bit_0 = reg_vol % 10;
assign bit_2_disp = (bit_2==0) ? 4'd10 : bit_2;
assign bit_1_disp = (bit_2==0&&bit_1==0) ? 4'd10 : bit_1;
assign bit_0_disp = bit_0;
bit_to_caseg bit_to_caseg_inst (
    .sclk(sclk),
    .nrst(nrst),
    .bit_7(4'd10),
    .bit_6(4'd10),
    .bit_5(4'd10),
    .bit_4(4'd10),
    .bit_3(4'd10),
    .bit_2(bit_2_disp),
    .bit_1(bit_1_disp),
    .bit_0(bit_0_disp),
    
    .sel(sel),
    .seg(seg)
);

endmodule