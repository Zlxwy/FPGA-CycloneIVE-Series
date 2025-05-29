/*联合模块seg_dynamic和模块hc595_ctrl*/
/*输入显示数据、小数点使能位、符号使能位、数码管使能位，输出hc595直接能接收的信号*/
module seg_595_dynamic
(
  input   wire        sys_clk,
  input   wire        sys_rst_n,
  input   wire[19:0]  data,
  input   wire[5:0]   dp,
  input   wire        sign,
  input   wire        seg_en,
  
  output  wire        ds,
  output  wire        oe,
  output  wire        shcp,
  output  wire        stcp
);

wire[5:0]   sel;
wire[7:0]   seg;

seg_dynamic seg_dynamic_inst
(
  .sys_clk      (sys_clk),
  .sys_rst_n    (sys_rst_n),
  .data         (data),
  .dp           (dp),
  .sign         (sign),
  .seg_en       (seg_en),
  
  .sel          (sel),
  .seg          (seg)
);

hc595_ctrl
#(
  .cnt_MAX      (2'd3),//用来对系统时钟进行4分频的
  .cnt_bit_MAX  (4'd13)//有14个移位数据，因此要从0计数到13
)
hc595_ctrl_inst
(
  .sys_clk      (sys_clk),
  .sys_rst_n    (sys_rst_n),
  .sel          (sel),//位选信号，0~5代表低位到高位，即右到左（DIG6~DIG1）
  .seg          (seg),
  
  .ds           (ds),
  .shcp         (shcp),
  .stcp         (stcp),
  .oe           (oe)
);

endmodule