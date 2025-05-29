`timescale 1ns/1ns
module f_adder_tb();

reg ain,bin,cin;
wire sout,cout;

initial begin
    ain <= 0; bin <= 0; cin <= 0; #20;
    ain <= 0; bin <= 0; cin <= 1; #20;
    ain <= 0; bin <= 1; cin <= 0; #20;
    ain <= 0; bin <= 1; cin <= 1; #20;
    ain <= 1; bin <= 0; cin <= 0; #20;
    ain <= 1; bin <= 0; cin <= 1; #20;
    ain <= 1; bin <= 1; cin <= 0; #20;
    ain <= 1; bin <= 1; cin <= 1; #20;
end

f_adder f_adder_inst(
    .ain(ain),
    .bin(bin),
    .cin(cin),
    .sout(sout),
    .cout(cout)
);

endmodule
