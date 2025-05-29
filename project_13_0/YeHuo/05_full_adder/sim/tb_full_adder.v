`timescale 1ns/1ns

module tb_full_adder();

reg   addend_1;
reg   addend_2;
reg   carry_in;
wire  sum;
wire  carry_out;

initial
  begin
    addend_1 <= 1'b0;
    addend_2 <= 1'b0;
    carry_in <= 1'b0;
  end

initial
  begin
    $timeformat(-9,0,"ns",6);
    $monitor("@time %t:addend_1 %b,addend_@=%b,carry_in=%b,sum=%b,carry_out=%b",$time,addend_1,addend_2,carry_in,sum,carry_out);
  end

always #10 addend_1 <= {$random}%2;
always #10 addend_2 <= {$random}%2;
always #10 carry_in <= {$random}%2;

full_adder full_adder_inst
(
  .addend_1   (addend_1),
  .addend_2   (addend_2),
  .carry_in   (carry_in),
  
  .sum        (sum),
  .carry_out  (carry_out)
);

endmodule