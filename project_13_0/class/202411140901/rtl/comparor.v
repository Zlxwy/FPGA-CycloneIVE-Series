module comparor(
    input wire clk,
    input wire rst,
    input wire num1,
    input wire num2

    output reg  equal,
    output reg  less,
    output reg  greater
);

always @(posedge clk or negedge rst)
    if(rst == 0) begin
        equal <= 0;
        less <= 0;
        greater <= 0;
    end
    else if(num1 > num2) begin
        greater <= 1;
        equal <= 0;
        less <= 0;
    end
    else if(num1 < num2) begin
        less <= 1;
        greater <= 0;
        equal <= 0;
    end
    else if(num1 == num2) begin
        greater <= 0;
        equal <= 1;
        less <= 0;
    end

endmodule