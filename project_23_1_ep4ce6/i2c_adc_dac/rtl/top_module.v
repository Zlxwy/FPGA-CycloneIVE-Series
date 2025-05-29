module top_module (
    input wire sclk,
    input wire nrst,
    input wire key1, key2, key3, key4, //切换界面、采样间隔加、采样间隔减、启停DAC

    output wire[7:0] sel,
    output wire[7:0] seg,

    output wire led,

    output wire scl,
    inout wire sda
);






wire key1_signal;
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按，参数范围[2~4294967295]ms
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms，参数范围[2~4294967295]ms
) key1_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key1), // 原始按键信号
    .key_out(key1_signal) // 出来的按键信号
);

wire key2_signal;
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按，参数范围[2~4294967295]ms
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms，参数范围[2~4294967295]ms
) key2_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key2), // 原始按键信号
    .key_out(key2_signal) // 出来的按键信号
);

wire key3_signal;
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按，参数范围[2~4294967295]ms
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms，参数范围[2~4294967295]ms
) key3_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key3), // 原始按键信号
    .key_out(key3_signal) // 出来的按键信号
);

wire key4_signal;
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按，参数范围[2~4294967295]ms
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms，参数范围[2~4294967295]ms
) key4_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key4), // 原始按键信号
    .key_out(key4_signal) // 出来的按键信号
);






wire[7:0] vol;
reg gs_trig;
adc081c021_dac5571 # (
    .sys_clk_freq (50_000_000),
    .i2c_clk_speed (400_000)
) adc081c021_dac5571_inst (
    .sclk(sclk),
    .nrst(nrst),
    .dac_enable(dac_enable),
    .gs_trig(gs_trig), //输入一个触发信号，触发一次获取电压并设置电压
    .gs_done(), //获取电压并设置电压完成后，输出一个高电平脉冲
    .vol(vol), //获取的电压值
    .scl(scl),
    .sda(sda),
    .DEBUG_scl(),
    .DEBUG_sda()
);


reg view;
localparam VIEW_SAMPLE = 0; //采集界面
localparam VIEW_PARAM = 1; //参数界面
// view
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) view <= VIEW_SAMPLE;
    else if(view == VIEW_SAMPLE && key1_signal) view <= VIEW_PARAM;
    else if(view == VIEW_PARAM && key1_signal) view <= VIEW_SAMPLE;
    else view <= view;
end
assign led = view;

reg[31:0] sample_interval;
parameter sample_interval_MIN = (50_000_000 / 10) - 1; //最小采样间隔0.1s.10Hz
parameter sample_interval_STEP = 50_000_000 / 10; //变化步长0.1s
parameter sample_interval_MAX = (50_000_000 / 1) - 1; //最大采样间隔1s.1Hz
// sample_interval
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) sample_interval <= sample_interval_MIN;

    else if(key2_signal && sample_interval == sample_interval_MAX) sample_interval <= sample_interval_MAX;
    else if(key2_signal) sample_interval <= sample_interval + sample_interval_STEP;

    else if(key3_signal && sample_interval == sample_interval_MIN) sample_interval <= sample_interval_MIN;
    else if(key3_signal) sample_interval <= sample_interval - sample_interval_STEP;

    else sample_interval <= sample_interval;
end

reg[31:0] cnt_sample_interval;
// cnt_sample_interval
/*cnt_sample_interval在[0, sample_interval]之间循环计数*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) cnt_sample_interval <= 0;
    else if(cnt_sample_interval >= sample_interval) cnt_sample_interval <= 0;
    else cnt_sample_interval <= cnt_sample_interval + 1;
end

// gs_trig
/*控制gs_trig产生一个维持一个时钟周期的高电平脉冲，用来触发一次ADC转换和DAC设置*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) gs_trig <= 0;
    else if(cnt_sample_interval == sample_interval_MIN - 1) gs_trig <= 1;
    else gs_trig <= 0;
end

reg dac_enable;
// dac_enable
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) dac_enable <= 1;
    else if(dac_enable && key4_signal) dac_enable <= 0;
    else if(!dac_enable && key4_signal) dac_enable <= 1;
    else dac_enable <= dac_enable;
end

wire[31:0] vol_disp;
assign vol_disp = (dac_enable)?(vol*330/255):0;
wire[3:0] bit_7, bit_2, bit_1, bit_0;
assign bit_7 = (view==VIEW_SAMPLE) ? (12)                   : (13);
assign bit_2 = (view==VIEW_SAMPLE) ? (vol_disp / 100)       : (10);
assign bit_1 = (view==VIEW_SAMPLE) ? (vol_disp / 10 % 10)   : ((sample_interval+1)/5/10000000%10);
assign bit_0 = (view==VIEW_SAMPLE) ? (vol_disp / 1 % 10)    : ((sample_interval+1)/5/1000000%10);
wire[7:0] dp_en;
assign dp_en = (view==VIEW_SAMPLE) ? (8'b0000_0100) : (8'b0000_0010);
bit_to_caseg bit_to_caseg_inst (
    .sclk(sclk),
    .nrst(nrst),
    .dp_en(dp_en),
    .bit_7(bit_7),
    .bit_6(4'd10),
    .bit_5(4'd10),
    .bit_4(4'd10),
    .bit_3(4'd10),
    .bit_2(bit_2),
    .bit_1(bit_1),
    .bit_0(bit_0),
    
    .sel(sel),
    .seg(seg)
);

endmodule