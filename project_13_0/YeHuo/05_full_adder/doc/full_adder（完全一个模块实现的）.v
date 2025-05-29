module full_adder(
    input   wire        addend_1,
    input   wire        addend_2,
    input   wire        carry_in,

    output  wire        sum_out,
    output  wire        carry_out
);

wire    carry_temp_0;
wire    carry_temp_1;
wire    sum_temp;

/*中间信号*/
assign sum_temp     = addend_1 ^ addend_2;
assign carry_temp_0 = addend_1 & addend_2;
assign carry_temp_1 = sum_temp & carry_in;

/*输出信号*/
assign sum_out      = sum_temp ^ carry_in;
assign carry_out    = carry_temp_0 | carry_temp_1;

endmodule