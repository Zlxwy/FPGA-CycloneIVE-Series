`timescale 1ns/1ns
module comparator_2bits_tb();

reg[1:0] a,b;
wire less,equal, greater;

initial begin
    a<=00; b<=00; #20;
    a<=00; b<=01; #20;
    a<=00; b<=10; #20;
    a<=00; b<=11; #20;
    a<=01; b<=00; #20;
    a<=01; b<=01; #20;
    a<=01; b<=10; #20;
    a<=01; b<=11; #20;
    a<=10; b<=00; #20;
    a<=10; b<=01; #20;
    a<=10; b<=10; #20;
    a<=10; b<=11; #20;
    a<=11; b<=00; #20;
    a<=11; b<=01; #20;
    a<=11; b<=10; #20;
    a<=11; b<=11; #20;
end

comparator_2bits comparator_2bits_inst(
    .a          (a),
    .b          (b),
    .less       (less),
    .equal      (equal),
    .greater    (greater)
);

endmodule