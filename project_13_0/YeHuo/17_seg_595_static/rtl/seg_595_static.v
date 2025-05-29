module seg_595_static
(
  input   wire      sys_clk,
  input   wire      sys_rst_n,
  
  output  wire      ds,
  output  wire      shcp,
  output  wire      stcp,
  output  wire      oe
);

wire[5:0]   sel;
wire[7:0]   seg;

seg_static
#(
  .cnt_MAX      (25'd24_999_999),//计这么多个数为500ms，每500ms切换一次数字（这个参数实际烧录时填24999999，仿真时填24，小一点）
  .data_MAX     (4'hf)//要显示0~F这一共16个16进制字符
)
seg_static_inst
(
  .sys_clk      (sys_clk),
  .sys_rst_n    (sys_rst_n),
  
  .sel          (sel),
  .seg          (seg)
);

hc595_ctrl
#(
  .cnt_MAX      (2'd3),//计这么多个数，作为cnt_bit的计数时钟
  .cnt_bit_MAX  (4'd13)//根据cnt的计数更新时钟循环计数，每切换一次代表一个数据位移入到SR
)
hc595_ctrl_inst
(
  .sys_clk      (sys_clk),
  .sys_rst_n    (sys_rst_n),
  .sel          (sel),
  .seg          (seg),
  
  .ds           (ds),
  .shcp         (shcp),
  .stcp         (stcp),
  .oe           (oe)
);

endmodule