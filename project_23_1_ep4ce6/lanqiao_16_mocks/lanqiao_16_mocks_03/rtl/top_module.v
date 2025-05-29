module top_module (
    input wire sclk,
    input wire nrst,
    input wire key1,key2,key3,key4, //启停、增加、减小、发送
    output wire led,
    output wire[7:0] sel,seg,
    output wire ch340_tx
);

wire key1_signal;
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按，参数范围(0, 85.9]s
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms，参数范围(0, 85.9]s
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
    .long_press (500),         // 按键按住500ms后识别为长按，参数范围(0, 85.9]s
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms，参数范围(0, 85.9]s
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
    .long_press (500),         // 按键按住500ms后识别为长按，参数范围(0, 85.9]s
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms，参数范围(0, 85.9]s
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
    .long_press (500),         // 按键按住500ms后识别为长按，参数范围(0, 85.9]s
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms，参数范围(0, 85.9]s
) key4_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key4), // 原始按键信号
    .key_out(key4_signal) // 出来的按键信号
);

localparam STATE_STOP = 0;
localparam STATE_PLAY = 1;

reg state;
assign led = ~state;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) state <= STATE_PLAY;
    else if(state == STATE_PLAY && key1_signal) state <= STATE_STOP;
    else if(state == STATE_STOP && key1_signal) state <= STATE_PLAY;
    else state <= state;
end

wire[9:0] num;
wire[3:0] num_hdrs, num_tens, num_ones;
/*取出计数值的十进制每个位上的数字*/
assign num_hdrs = num / 100;
assign num_tens = num / 10 % 10;
assign num_ones = num % 10;

num_cnt #(
    .num_start (0),
    .num_MAX (999)
) num_cnt_inst (
    .sclk(sclk),
    .nrst(nrst),

    .state(state), //0: 停止状态 1: 启动状态

    .inc_sig(key2_signal), //Increment Signal
    .dec_sig(key3_signal), //Decrement Signal

    .num(num) //显示3位十进制数，最大999，用10位二进制
);

/*数码管显示*/
wire[3:0] bit_2_disp, bit_1_disp, bit_0_disp;
/*如果高位上的数字为0，则显示空格(10)*/
assign bit_2_disp = (num_hdrs==0) ? 10 : num_hdrs;
assign bit_1_disp = (num_hdrs==0&&num_tens==0) ? 10 : num_tens;
assign bit_0_disp = num_ones;
bit_to_caseg bit_to_caseg_inst (
    .sclk(sclk),
    .nrst(nrst),
    .bit_7(4'd12),
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

/*串口发送*/
wire send_11bytes_done;
reg send_11bytes_trig,is_sending;
// send_11bytes_trig
/*没有在发送时，检测到按键触发发送，则生成一次发送脉冲*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) send_11bytes_trig <= 0;
    else if(!is_sending && key4_signal) send_11bytes_trig <= 1;
    else send_11bytes_trig <= 0;
end
// is_sending
/*is_sending为高，表示正在串口发送*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) is_sending <= 0;
    else if(!is_sending && key4_signal) is_sending <= 1;
    else if(is_sending && send_11bytes_done) is_sending <= 0;
    else is_sending <= is_sending;
end

wire[87:0] send_string;
wire[7:0] bit_2_send,bit_1_send,bit_0_send;
// assign bit_2_send = (num_hdrs==0) ? 32 : (num_hdrs+48);
// assign bit_1_send = (num_hdrs==0&&num_tens==0) ? 32 : (num_tens+48);
// assign bit_0_send = num_ones + 48;

//　　　　　　　　　　　（百十位都为０）　　　　　　　　　　　　　　　（只有百位为０）　（三个位都不为０）
//　百十位是否为０　　？　左１位发送的是个位数　：　（是否只有百位为０？左１位发送十位数：左１位发送百位数）
//　百十位是否为０　　？　左２位发送的是空格　　：　（是否只有百位为０？左２位发送个位数：左２位发送十位数）
//　百十位是否为０　　？　左３位发送的是空格　　：　（是否只有百位为０？左３位发送空格　：左３位发送个位数）
assign bit_2_send = (num_hdrs==0&&num_tens==0) ? (num_ones + 48) : ( (num_hdrs==0)?(num_tens + 48):(num_hdrs + 48) );
assign bit_1_send = (num_hdrs==0&&num_tens==0) ? (32)            : ( (num_hdrs==0)?(num_ones + 48):(num_tens + 48) );
assign bit_0_send = (num_hdrs==0&&num_tens==0) ? (32)            : ( (num_hdrs==0)?(32)           :(num_ones + 48) );

// send ----------->  C      O      U      N      T      :      x           x           x           \r     \n
assign send_string = {8'h43, 8'h4F, 8'h55, 8'h4E, 8'h54, 8'h3A, bit_2_send, bit_1_send, bit_0_send, 8'h0D, 8'h0A};

wire UNUSED_ch340_rx;
uart_send_11bytes #(
    .sys_clk_freq (50_000_000),
    .baudrate (9600)
) uart_send_11bytes_inst (
    .sclk(sclk),
    .nrst(nrst),

    .send_11bytes(send_string),
    .send_11bytes_trig(send_11bytes_trig),
    .send_11bytes_done(send_11bytes_done),

    .ch340_tx(ch340_tx),
    .ch340_rx(UNUSED_ch340_rx)
);

endmodule