module f_adder(
    input   wire        ain,
    input   wire        bin,
    input   wire        cin,
    output  wire        sout,
    output  wire        cout
);

wire co_tmp_1;
wire co_tmp_2;
wire so_tmp_1;

assign so_tmp_1 = ain ^ bin;
assign co_tmp_1 = ain & bin;
assign co_tmp_2 = so_tmp_1 & cin;

assign sout = so_tmp_1 ^ cin;
assign cout = co_tmp_1 | co_tmp_2;

endmodule
