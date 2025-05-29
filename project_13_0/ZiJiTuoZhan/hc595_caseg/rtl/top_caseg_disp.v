/**数码管配合hc595显示，顶层文件**/
module top_caseg_disp(
  input   wire      clk,
  input   wire      rst,

  output  wire      ds,
  output  wire      shcp,
  output  wire      stcp,
  output  wire      oe
);

/*调用模块digit8_generator生成显示数字*/
wire[26:0]    num;
digit8_num_generator digit8_num_generator_inst(
  .clk    (clk),
  .rst    (rst),

  .num    (num)
);

/*调用模块num_to_caseg，将上面模块生成的数字转换成数码管可直接执行的信号*/
wire[7:0]   sel;
wire[7:0]   seg;
num_to_caseg num_to_caseg_inst(
  .clk    (clk),
  .rst    (rst),
  .num    (num),//27位的数字，在0~99999999之间

  .sel    (sel),//位选信号，控制哪个位显示
  .seg    (seg)//段选信号，控制位上显示的字形
);

/*调用模块caseg_to_hc595，将位选信号和段选信号转换成hc595可直接执行的串行信号*/
caseg_to_hc595(
  .clk    (clk),//系统时钟50MHz
  .rst    (rst),//复位信号，低电平有效
  .sel    (sel),//位选信号，控制哪个位显示
  .seg    (seg),//段选信号，控制位上显示的字形

  .ds     (ds),//数据输入端
  .shcp   (shcp),//移位时钟，上升沿移位
  .stcp   (stcp),//输出时钟，上升沿
  .oe     (oe)//使能端，低电平有效
);

endmodule