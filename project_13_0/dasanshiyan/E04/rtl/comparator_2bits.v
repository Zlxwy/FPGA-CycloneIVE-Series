module comparator_2bits(
    input   wire[1:0]   a,
    input   wire[1:0]   b,
    output  wire        less,//a<b，less置高电平
    output  wire        equal,//a=b，equal置高电平
    output  wire        greater//a>b，greater置高电平
);

assign less = ( (~a[1]) & b[1] )
            | ( (~a[0]) & b[1] & b[0] )
            | ( (~a[1]) & (~a[0]) & b[0] );
assign equal = !(a ^ b);//如果a和b一样，则a^b为00，逻辑取反
assign greater = (~less) & (~equal);//不小于也不等于，就是大于

endmodule
