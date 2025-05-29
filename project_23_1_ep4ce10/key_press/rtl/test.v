module test (
    input wire a,
    output wire b,
    output reg c
);

assign b = !a;
always @(*) begin
    if(a == 1'b0)       c <= 1'b1;
    else if(a == 1'b1)  c <= 1'b0;
    else                c <= c;
end

endmodule