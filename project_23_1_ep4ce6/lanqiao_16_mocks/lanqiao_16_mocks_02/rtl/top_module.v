module top_module (
    input wire sclk,
    input wire nrst,

    input wire key1, //key1切换启停状态，在切换到停止状态后会写入一次EEPROM
    input wire key2, //key2清零时间值，只在停止状态时有效，清零时会写入一次EEPROM
    output wire led, //启动时点亮，停止时熄灭

    // output wire ds,
    // output wire shcp,
    // output wire stcp,
    // output wire oe,
    output wire[7:0] sel,seg,

    output wire eeprom_scl,
    inout wire eeprom_sda
);

wire key1_signal;
key #(
    .sclk_freq (50_000_000),   // 系统时钟频率50MHz
    .press_vol (0),            // 按键按下时为低电平
    .long_press (500),         // 按键按住500ms后识别为长按
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms
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
    .long_press (500),         // 按键按住500ms后识别为长按
    .signal_interval (100)     // 识别为长按后，连续脉冲的输出间隔为100ms
) key2_inst (
    .sclk(sclk),
    .nrst(nrst),
    .key_in(key2), // 原始按键信号
    .key_out(key2_signal) // 出来的按键信号
);

reg[23:0] write_3bytes;
wire[23:0] read_3bytes;
reg write_3bytes_trig, read_3bytes_trig;
wire write_3bytes_done, read_3bytes_done;
eeprom_3bytes_rw #(
    .equi_addr (7'b1010_000) //从机未左移的原7位地址
) eeprom_3bytes_rw_inst (
    .sclk(sclk),
    .nrst(nrst),
    .start_reg_addr(8'd10), //EEPROM读写寄存器的起始地址
    .write_3bytes(write_3bytes), //要写入的3个字节
    .read_3bytes(read_3bytes), //要读取的3个字节

    .write_3bytes_trig(write_3bytes_trig),
    .read_3bytes_trig(read_3bytes_trig),
    .write_3bytes_done(write_3bytes_done),
    .read_3bytes_done(read_3bytes_done),

    .eeprom_scl(eeprom_scl),
    .eeprom_sda(eeprom_sda)
);

localparam STATE_PLAY = 1;
localparam STATE_STOP = 0;

reg state;
assign led = ~state; //低电平点亮LED
// state
/*切换状态用*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) state <= STATE_STOP; //复位默认停止状态
    else if(state == STATE_STOP && key1_signal) state <= STATE_PLAY; //停止状态按下key1，转换为启动状态
    else if(state == STATE_PLAY && key1_signal) state <= STATE_STOP; //启动状态按下key1，转换为停止状态
    else state <= state;
end

reg cnt_jdj; //计到尽(jdj)
// cnt_jdj
/*为了能在上电能进行一次读取，cnt_jdj从0计到1，计到1后就一直保持不变了，一次性的reg*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) cnt_jdj <= 0;
    else if(cnt_jdj == 1) cnt_jdj <= cnt_jdj;
    else cnt_jdj <= cnt_jdj + 1;
end

// read_3bytes_trig
//基于cnt_jdj产生一次高电平脉冲，触发一次从EEPROM的时间值读取
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) read_3bytes_trig <= 0;
    else if(cnt_jdj == 0) read_3bytes_trig <= 1;
    else read_3bytes_trig <= 0;
end

reg is_getting_time;
// is_getting_time
/*在从EEPROM读取存储的时间值时，这个is_getting_time会保持高电平*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) is_getting_time <= 0;
    /*在遇到读取触发信号后，置起is_getting_time，表示当前正在获取EEPROM存储的时间值*/
    else if(!is_getting_time && read_3bytes_trig) is_getting_time <= 1;//上电获取时间值
    /*在遇到读取完毕信号后，置低is_getting_time，表示已完成一次从EEPROM的时间值读取*/
    else if(is_getting_time && read_3bytes_done) is_getting_time <= 0; //获取时间值完毕，置低
    else is_getting_time <= is_getting_time;
end

reg[23:0] update;
reg update_trigger;
// update, update_trigger
/*从EEPROM读取时间完成后，更新数码管时间计数值；或停止状态按下key2后，归零数码管的时间计数值*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) begin update <= 0; update_trigger <= 0; end
    /*当发现read_3bytes_done信号后，触发一次数码管显示更新，更新为从EEPROM读出来的值*/
    else if(is_getting_time && read_3bytes_done) begin update <= read_3bytes; update_trigger <= 1; end
    /*在停止状态下，发现key2信号后，触发一次数码管显示更新，更新为归零值*/
    else if(state == STATE_STOP && key2_signal) begin update <= 0; update_trigger <= 1; end
    else begin update <= update; update_trigger <= 0; end
end

reg is_setting_time;
// is_setting_time
/*在向写入EEPROM写入数据时，这个is_setting_time会一直保持高电平（这个is_setting是为了避免在写入数据的时候，又来一次触发写入电平，造成重复写入）*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) is_setting_time <= 0;
    /*在停止状态时遇到key2触发信号后，置起is_setting_time，表示正在将时间值写入EEPROM*/
    else if(!is_setting_time && state == STATE_STOP && key2_signal) is_setting_time <= 1;//停止状态下按下按键key2
    /*在启动状态时遇到key1触发信号后，置起is_setting_time，也要将时间值写入一次EEPROM*/
    else if(!is_setting_time && state == STATE_PLAY && key1_signal) is_setting_time <= 1;//启动状态下按下按键key1
    /*在遇到写入完毕信号后，置低is_setting_time*/
    else if(is_setting_time && write_3bytes_done) is_setting_time <= 0;
    else is_setting_time <= is_setting_time;
end

wire[7:0] min,sec,deci_sec;
// write_3bytes, write_3bytes_trig
/*在启动状态下，按下key1停止，触发一次时间写入EEPROM，或在停止状态下，按下key2归零，也会触发一次写入EEPROM*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0) begin
        write_3bytes <= 0;
        write_3bytes_trig <= 0;
    end
    /*（不在写入状态）启动状态下按下按键key1，停止计数并触发一次写入EEPROM*/
    else if(!is_setting_time && state == STATE_PLAY && key1_signal) begin
        write_3bytes <= {min, sec, deci_sec};
        write_3bytes_trig <= 1;
    end
    /*（不在写入状态）停止状态下按下按键key2，清零计数并触发一次写入EEPROM*/
    else if(!is_setting_time && state == STATE_STOP && key2_signal) begin
        write_3bytes <= 0;
        write_3bytes_trig <= 1;
    end
    else begin
        write_3bytes <= write_3bytes;
        write_3bytes_trig <= 0;
    end
end



time_cnt time_cnt_inst (
    .sclk(sclk),
    .nrst(nrst),
    .state(state),
    .update(update),
    .update_trigger(update_trigger),
    .min(min),
    .sec(sec),
    .deci_sec(deci_sec)
);

wire[3:0] bit_7,bit_6,bit_5,bit_4,bit_3,bit_2,bit_1,bit_0;
assign bit_7 = 15;
assign bit_6 = min / 10;
assign bit_5 = min % 10;
assign bit_4 = 11;
assign bit_3 = sec / 10;
assign bit_2 = sec % 10;
assign bit_1 = 11;
assign bit_0 = deci_sec[3:0];

bit_to_caseg bit_to_caseg_inst (
    .sclk(sclk),
    .nrst(nrst),
    .bit_7(bit_7),
    .bit_6(bit_6),
    .bit_5(bit_5),
    .bit_4(bit_4),
    .bit_3(bit_3),
    .bit_2(bit_2),
    .bit_1(bit_1),
    .bit_0(bit_0),
    
    .sel(sel),
    .seg(seg)
);

// wire[7:0] sel, seg;
// caseg_to_hc595 caseg_to_hc595_inst (
//   .sclk(sclk),//系统时钟50MHz
//   .nrst(nrst),//复位信号，低电平有效
//   .sel(sel),//位选信号，控制哪个位显示
//   .seg(seg),//段选信号，控制位上显示的字形

//   .ds(ds),//数据输入端
//   .shcp(shcp),//移位时钟，上升沿移位
//   .stcp(stcp),//输出时钟，上升沿
//   .oe(oe)//使能端，低电平有效
// );

endmodule