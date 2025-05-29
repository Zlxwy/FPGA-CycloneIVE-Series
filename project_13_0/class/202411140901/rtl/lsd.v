module lsd(
    input wire    clk,
    input wire    rst,

    output reg[3:0]     led
);

reg[29:0] cnt_per500ms;
parameter cnt_per500ms_MAX = 30'd9;
reg[1:0]  cnt_led;
parameter cnt_led_MAX = 2'd3;

always @(posedge clk or negedge rst)
    if(rst == 0)
        cnt_per500ms <= 0;
    else if(cnt_per500ms == cnt_per500ms_MAX)
        cnt_per500ms <= 0;
    else
        cnt_per500ms <= cnt_per500ms + 1;



always @(posedge clk or negedge rst)
    if(rst == 0)
        cnt_led <= 0;
    else if(cnt_per500ms == cnt_per500ms_MAX && cnt_led == cnt_led_MAX)
        cnt_led <= 0;
    else if(cnt_per500ms == cnt_per500ms_MAX)
        cnt_led <= cnt_led + 1;
    else
        cnt_led <= cnt_led;


always @(posedge clk or negedge rst)
    if(rst == 0)
        led <= 0;
    else
        led <= ~(1<<cnt_led);

endmodule
        