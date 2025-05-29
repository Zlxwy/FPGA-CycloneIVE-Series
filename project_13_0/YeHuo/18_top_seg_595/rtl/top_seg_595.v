module top_seg_595
(
  input   wire      sys_clk,
  input   wire      sys_rst_n,
  
  output  wire      ds,
  output  wire      shcp,
  output  wire      stcp,
  output  wire      oe
);

wire[19:0]  data;
wire[5:0]   dp;
wire        sign;
wire        seg_en;

data_generate
#(
  .cnt_100ms_MAX  (23'd4_999_999),
  .data_MAX       (20'd10)//数码管显示计数，最大到10
)
data_generate_inst
(
  .sys_clk        (sys_clk),
  .sys_rst_n      (sys_rst_n),
  
  .data           (data),
  .dp             (dp),
  .sign           (sign),
  .seg_en         (seg_en)
);


seg_595_dynamic seg_595_dynamic_inst
(
  .sys_clk        (sys_clk),
  .sys_rst_n      (sys_rst_n),
  .data           (data),
  .dp             (dp),
  .sign           (sign),
  .seg_en         (seg_en),
  
  .ds             (ds),
  .oe             (oe),
  .shcp           (shcp),
  .stcp           (stcp)
);

endmodule