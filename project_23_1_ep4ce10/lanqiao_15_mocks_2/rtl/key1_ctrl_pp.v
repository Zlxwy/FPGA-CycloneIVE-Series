/*按键1控制启停状态，按键2控制清零（只在停止状态有效）*/
module key_ctrl (
    input wire sclk,
    input wire nrst,
    input wire key1_signal,
    input wire key2_signal,
    output wire state
);



reg is_writing_eeprom, is_reading_eeprom;
always @(posedge sclk negedge nrst) begin
    if(nrst == 0) is_writing_eeprom <= 0;
    else if(state == STATE_PLAY) is_writing_eeprom <= is_writing_eeprom;
    else if(state == STATE_STOP && key2_signal) is_writing_eeprom <= 1;
    else if(state == STATE_STOP) is_writing_eeprom <= is_writing_eeprom;
    else


