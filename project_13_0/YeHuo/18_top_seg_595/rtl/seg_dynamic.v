/*输入显示的数据、小数点使能位、符号位使能位、数码管使能位，输出6个位选和8个段选的数据*/
module seg_dynamic
(
  input   wire        sys_clk,
  input   wire        sys_rst_n,
  input   wire[19:0]  data,
  input   wire[5:0]   dp,
  input   wire        sign,
  input   wire        seg_en,
  
  output  reg[5:0]    sel,
  output  reg[7:0]    seg
);


wire[3:0]   bit_0;//unit
wire[3:0]   bit_1;//ten
wire[3:0]   bit_2;//hun
wire[3:0]   bit_3;//tho
wire[3:0]   bit_4;//t_tho
wire[3:0]   bit_5;//h_hun

reg[23:0]   data_reg;//用于存入要显示的数据，每一位数码管占该变量的4位

reg[15:0]   cnt_1ms;
parameter   cnt_1ms_MAX = 16'd49_999;
reg         flag_1ms;

reg[2:0]    cnt_sel;
parameter   cnt_sel_MAX = 3'd5;
reg[5:0]    sel_reg;
reg[3:0]    data_disp;
reg         dp_disp;

/*data_reg赋值块*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    data_reg <= 24'b0;
  
  else if((bit_5)||(dp[5]))//如果数码管第5位有显示数据，或者第5位有小数点
    data_reg <= {bit_5,bit_4,bit_3,bit_2,bit_1,bit_0};
  
  else if(((bit_4)||(dp[4]))&&(sign == 1'b1))//如果 （数码管第4位有显示数据||第4位有小数点）&&（符号位有效）
    data_reg <= {4'd10,bit_4,bit_3,bit_2,bit_1,bit_0};//负号用数字10表示
  else if(((bit_4)||(dp[4]))&&(sign == 1'b0))//如果 （数码管第4位有显示数据||第4位有小数点）&&（符号位无效）
    data_reg <= {4'd11,bit_4,bit_3,bit_2,bit_1,bit_0};//符号不显示，用数字11表示
  
  else if(((bit_3)||(dp[3]))&&(sign == 1'b1))//如果 （数码管第3位有显示数据||第3位有小数点）&&（符号位有效）
    data_reg <= {4'd11,4'd10,bit_3,bit_2,bit_1,bit_0};//负号用数字10表示
  else if(((bit_3)||(dp[3]))&&(sign == 1'b0))//如果 （数码管第3位有显示数据||第3位有小数点）&&（符号位无效）
    data_reg <= {4'd11,4'd11,bit_3,bit_2,bit_1,bit_0};//符号不显示，用数字11表示
  
  else if(((bit_2)||(dp[2]))&&(sign == 1'b1))//如果 （数码管第2位有显示数据||第2位有小数点）&&（符号位有效）
    data_reg <= {4'd11,4'd11,4'd10,bit_2,bit_1,bit_0};//负号用数字10表示
  else if(((bit_2)||(dp[2]))&&(sign == 1'b0))//如果 （数码管第2位有显示数据||第2位有小数点）&&（符号位无效）
    data_reg <= {4'd11,4'd11,4'd11,bit_2,bit_1,bit_0};//符号不显示，用数字11表示
  
  else if(((bit_1)||(dp[1]))&&(sign == 1'b1))//如果 （数码管第1位有显示数据||第1位有小数点）&&（符号位有效）
    data_reg <= {4'd11,4'd11,4'd11,4'd10,bit_1,bit_0};//负号用数字10表示
  else if(((bit_1)||(dp[1]))&&(sign == 1'b0))//如果 （数码管第1位有显示数据||第1位有小数点）&&（符号位无效）
    data_reg <= {4'd11,4'd11,4'd11,4'd11,bit_1,bit_0};//符号不显示，用数字11表示
  
  else if(((bit_0)||(dp[0]))&&(sign == 1'b1))//如果 （数码管第0位有显示数据||第0位有小数点）&&（符号位有效）
    data_reg <= {4'd11,4'd11,4'd11,4'd11,4'd10,bit_0};//负号用数字10表示
  else// if(((bit_0)||(dp[0]))&&(sign == 1'b0))//如果 （数码管第0位有显示数据||第0位有小数点）&&（符号位无效）
    data_reg <= {4'd11,4'd11,4'd11,4'd11,4'd11,bit_0};//符号不显示，用数字11表示


/*cnt_1ms循环计数块，每1ms一次更新*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt_1ms <= 0;
  else if(cnt_1ms == cnt_1ms_MAX)
    cnt_1ms <= 0;
  else
    cnt_1ms <= cnt_1ms + 1;

/*cnt_1ms的更新脉冲产生块*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    flag_1ms <= 1'b0;
  else if(cnt_1ms == cnt_1ms_MAX-1)
    flag_1ms <= 1'b1;
  else
    flag_1ms <= 1'b0;


/*cnt_sel循环计数块，由0~5循环计数，依托于flag_1ms脉冲信号每1ms改变一次，对应数码管在该时刻的显示位，用于扫描显示*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    cnt_sel <= 0;
  else if((cnt_sel == cnt_sel_MAX)&&(flag_1ms == 1'b1))
    cnt_sel <= 0;
  else if(flag_1ms == 1'b1)
    cnt_sel <= cnt_sel + 1;
  else
    cnt_sel <= cnt_sel;

/*sel_reg更新块，这个是指示数码管在哪个位上显示的，在cnt_sel等于0并且flag_1ms高电平时赋一次值，之后只依托于flag_1ms信号进行更新，*/
//cnt_sel=0   sel_reg=100000
//cnt_sel=1   sel_reg=000001
//......
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    sel_reg <= 6'b000_000;
  else if((cnt_sel == 0)&&(flag_1ms == 1'b1))
    sel_reg <= 6'b000_001;
  else if(flag_1ms == 1'b1)
    sel_reg <= sel_reg << 1;
  else
    sel_reg <= sel_reg;


/*data_disp更新块，这个是指示数码管某个位上显示什么数字的，0~9代表相应数字，10代表负号，11代表无显示，依托于cnt_sel并在flag_1ms信号下进行更新*/
/*和sel_reg同步变换*/
/*下面还有一个块，根据data_disp的数据，给seg赋不同的字形值*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    data_disp <= 0;//复位显示字形0
  else if((seg_en == 1'b1)&&(flag_1ms == 1'b1))
    case(cnt_sel)//（不知道以后还理解的了这句话不）如果此时cnt_sel=0，在时钟上升沿时检测到flag_1ms高电平，此时sel_reg已经是准备变成000 001了，data_disp也已经是准备转变成第0位的数字，刚好对应，没有问题
      0: data_disp <= data_reg[3:0];
      1: data_disp <= data_reg[7:4];
      2: data_disp <= data_reg[11:8];
      3: data_disp <= data_reg[15:12];
      4: data_disp <= data_reg[19:16];
      5: data_disp <= data_reg[23:20];
      default: data_disp <= 0;//默认显示0
      endcase
  else
    data_disp <= data_disp;


/*dp_disp小数点显示使能位更新块，根据扫描到对应位有没有使能，然后取反*/
/*和data_disp同步变换*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    dp_disp <= 1'b1;//共阳数码管，点亮对应段要低电平，高电平熄灭
  else if(flag_1ms == 1'b1)
    dp_disp <= ~dp[cnt_sel];//因为点亮对应位的小数点要低电平，而dp的6位数据是高电平有效，因此要取一下反再赋给dp_disp
  else
    dp_disp <= dp_disp;


/*seg更新块，根据不同的显示数字，控制数码管对应段的电平。由data_disp的值决定显示什么字形，比data_disp的更新慢一拍*/
/*和sel同步变换*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    seg <= 8'b111_111;
  else begin
    case(data_disp)
      0: seg <= {dp_disp,7'b100_0000};
      1: seg <= {dp_disp,7'b111_1001};
      2: seg <= {dp_disp,7'b010_0100};
      3: seg <= {dp_disp,7'b011_0000};
      4: seg <= {dp_disp,7'b001_1001};
      5: seg <= {dp_disp,7'b001_0010};
      6: seg <= {dp_disp,7'b000_0010};
      7: seg <= {dp_disp,7'b111_1000};
      8: seg <= {dp_disp,7'b000_0000};
      9: seg <= {dp_disp,7'b001_0000};
      10: seg <= 8'b1011_1111;
      11: seg <= 8'b1111_1111;
      default: seg <= 8'b1100_0000;
      endcase
    end


/*sel更新块，由sel_reg得来，比sel_reg的更新慢一拍*/
/*和seg同步变换*/
always @(posedge sys_clk or negedge sys_rst_n)
  if(sys_rst_n == 1'b0)
    sel <= 6'b000_000;
  else
    sel <= sel_reg;

      

bcd_8421 bcd_8421_inst
(
  .sys_clk      (sys_clk),
  .sys_rst_n    (sys_rst_n),
  .data         (data),
  
  .bit_0        (bit_0),//unit
  .bit_1        (bit_1),//ten
  .bit_2        (bit_2),//hun
  .bit_3        (bit_3),//tho
  .bit_4        (bit_4),//t_tho
  .bit_5        (bit_5) //h_hun
);

endmodule