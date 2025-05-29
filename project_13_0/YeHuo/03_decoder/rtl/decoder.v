module decoder
(
  input   wire          in_1,
  input   wire          in_2,
  
  output  reg   [3:0]   out
  //使用always必须用reg类型
);

//always @(*)
//  if({in_1,in_2} == 2'b11)//都没按下
//    out = 4'b1110;
//  else if({in_1,in_2} == 2'b10)//按下右键
//    out = 4'b1101;
//  else if({in_1,in_2} == 2'b01)//按下左键
//    out = 4'b1011;
//  else if({in_1,in_2} == 2'b00)//按下两键
//    out = 4'b0111;
//  else
//    out = 4'b1110;

always @(*)   begin
  case({in_1,in_2})
    2'b11:    begin//都没按下
      out = 4'b1110;
    end
    2'b10:    begin//按下右键
      out = 4'b1101;
    end
    2'b01:    begin//按下左键
      out = 4'b1011;
    end
    2'b00:    begin//按下两键
      out = 4'b0111;
    end
    default:  begin
   //避免产生latch
    end
  endcase
end

endmodule
