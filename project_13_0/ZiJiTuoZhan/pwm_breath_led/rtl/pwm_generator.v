/*方波生成器，输入参数预分频值、PWM模式，输入变量计数周期、比较值，即可产生制定参数的PWM波*/
module pwm_generator
#(
    /* @brief 预分频值，用来对系统的50MHz时钟进行预分频。
     * @param 在2~49_999_999之间取值。若想进行2分频，则填入2，也就是变成一半频率（最小分频），以此类推。*/
    parameter prescaler = 2//默认2分频，预分频后为50MHz/2≈25MHz
)
(
    input   wire        sclk,
    input   wire        nrst,
    /* @brief 设置PWM模式。
     * @param PWM模式参数。
        @arg 0: 发现cnt=0后拉高电平，发现cnt=pulse后拉低电平
        @arg 1: 与0相反*/
    input   wire        pwm_mode,
    /* @brief 在prescaler对50MHz降频后的频率下进行计数，这个period是计数最大值
     * @param 在[1,50M]之间取值。若输入2，则cnt_period在1~2之间计数，也就是计2个数。*/
    inout   wire[25:0]  period,
    /* @brief 比较值，其值和period的比值即为占空比。
     * @param 在[1,period]之间取值。*/
    input   wire[25:0]  pulse,
    
    output  reg         pwmout,
    output  wire        pwmout_n
);


/******************************************对50MHz系统时钟降频****************************************************/
/*cnt_prescaler在0~prescaler之间循环计数*/
reg[25:0] cnt_prescaler;
parameter cnt_prescaler_MAX = prescaler - 1;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                                   cnt_prescaler <= 0;
    else if(cnt_prescaler == cnt_prescaler_MAX)     cnt_prescaler <= 0;
    else                                            cnt_prescaler <= cnt_prescaler + 1;
end

/*在cnt_prescaler计数到prescaler时，将signal_prescaler拉高一个时钟周期的电平*/
reg signal_prescaler;
parameter cnt_prescaler_MAX_minus_1 = cnt_prescaler_MAX - 1;
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                                           signal_prescaler <= 0;
    else if(cnt_prescaler == cnt_prescaler_MAX_minus_1)     signal_prescaler <= 1;
    else                                                    signal_prescaler <= 0;
end
/****************************************************************************************************************/





/*******************period缓冲器，在period发生改变后，系统在下一个计数周期开始时刻才会更新reg_period************************/
reg[25:0] reg_period;
reg change_signal_period;
/*如果period发生改变，就把change_signal_period置高电平*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                   //复位时
        change_signal_period <= 0;      //change_signal_period置低电平
    else if(period != reg_period)   //如果period更新了
        change_signal_period <= 1;      //change_signal_period置高电平
    else                            //其他
        change_signal_period <= 0;      //change_signal_period置低电平
end

/*reg_period更新块，如果change_signal_period高电平了，就在cnt_period计数更新时，同时更新reg_period的值。*/
/*如果change_signal_period高电平，就在signal_prescaler脉冲时、cnt_period计到reg_period时，改变reg_period的值*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                   //复位时
        reg_period <= period;           //更新reg_period为period
    else if(signal_prescaler == 1 && change_signal_period == 1 && cnt_period == reg_period)
        reg_period <= period;
    else
        reg_period <= reg_period;
end
/*******************************************************************************************************************/





/*******************pulse缓冲器，在pulse发生改变后，系统在下一个计数周期开始时刻才会更新reg_pulse************************/
reg[25:0] reg_pulse;
reg change_signal_pulse;
/*如果pulse发生改变，就把change_signal_pulse置高电平*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                   //复位时
        change_signal_pulse <= 0;       //change_signal_pulse置低电平
    else if(pulse != reg_pulse)     //如果pulse更新了
        change_signal_pulse <= 1;       //change_signal_pulse置高电平
    else                            //其他
        change_signal_pulse <= 0;       //change_signal_pulse置低电平
end

/*reg_pulse更新块，如果change_signal_pulse高电平了，就在cnt_pulse计数更新时，同时更新reg_pulse的值。*/
/*如果change_signal_pulse高电平，就在signal_prescaler脉冲时、cnt_period计到reg_period时，改变reg_pulse的值*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                   //复位时
        reg_pulse <= pulse;             //更新reg_pulse为pulse
    else if(change_signal_pulse == 1 && signal_prescaler == 1 && cnt_period == reg_period)
        reg_pulse <= pulse;
    else
        reg_pulse <= reg_pulse;
end
/***************************************************************************************************************/





/***************************************根据计数周期计数，根据比较值产生PWM波*************************************/
reg[25:0] cnt_period;
/*cnt_period计数块，在signal_prescaler的脉冲信号下在1~reg_period之间进行循环计数*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)                                               cnt_period <= 1;
    else if(signal_prescaler == 1 && cnt_period == reg_period)  cnt_period <= 1;
    else if(signal_prescaler == 1)                              cnt_period <= cnt_period + 1;
    else                                                        cnt_period <= cnt_period;
end

/*根据pwm_mode和reg_pulse的值，产生PWM波。*/
always @(posedge sclk or negedge nrst) begin
    if(nrst == 0)   pwmout <= pwm_mode;
    else if(signal_prescaler == 1 && cnt_period == reg_period) begin     //cnt_period计数到reg_period时
        case(pwm_mode)
            0: pwmout <= 1;
            1: pwmout <= 0;
            default: pwmout <= pwmout;
        endcase
    end
    else if(signal_prescaler == 1 && cnt_period == reg_pulse) begin     //cnt_period计数到reg_pulse时
        case(pwm_mode)
            0: pwmout <= 0;
            1: pwmout <= 1;
            default: pwmout <= pwmout;
        endcase
    end
end
assign pwmout_n = ~pwmout;
/**************************************************************************************************************/





endmodule