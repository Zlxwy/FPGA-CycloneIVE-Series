module running_led(
    input   wire        clk,
    input   wire        rst,
    output  reg[3:0]    led
);

reg[24:0] cnt_500ms;
parameter cnt_500ms_MAX = 25'd24_999_999;

/*cnt_500ms计数块，在0~24999999之间循环计数，计数周期500ms*/
always @(posedge clk or negedge rst)
    if(rst == 0)                            cnt_500ms <= 0;
    else if(cnt_500ms == cnt_500ms_MAX)     cnt_500ms <= 0;
    else                                    cnt_500ms <= cnt_500ms + 1;

/*每当cnt_500ms计数到最大值，流水灯状态改变*/
always @(posedge clk or negedge rst)
    if(rst == 0)                            led <= 4'b0001;
    else if(cnt_500ms == cnt_500ms_MAX)     led <= {led[2],led[1],led[0],led[3]};

endmodule
