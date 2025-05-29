module mux2_1
(
  input   wire  [0:0]   in_1,//1个位，[0:0]可以不写
  input   wire          in_2,
  input   wire          select,
  
  output  reg           out
  //output可以是reg也可以是wire型，但always赋值的变量必须是reg型，因此这里选择reg型
);

//always @(in_1,in_2,select)
////可用always @(*)代替，星号表示在always块中出现的所有输入，都会作为敏感变量
//  if(select == 1'b1)
//    begin
//      out = in_1;
//    end
//  else
//    begin
//      out = in_2;
//    end

always @(in_1,in_2)
  out = ((!in_1)&&in_2)||(in_1&&(!in_2));//一个异或门，相异输出高电平，灯灭


endmodule