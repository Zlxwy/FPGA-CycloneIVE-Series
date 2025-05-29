// num1[1]  num1[0]  num2[1]  num2[0]        less  equal greater
//    0        0        0        0             0     1      0
//    0        0        0        1             1     0      0
//    0        0        1        0             1     0      0
//    0        0        1        1             1     0      0
//    0        1        0        0             0     0      1
//    0        1        0        1             0     1      0
//    0        1        1        0             1     0      0
//    0        1        1        1             1     0      0
//    1        0        0        0             0     0      1
//    1        0        0        1             0     0      1
//    1        0        1        0             0     1      0
//    1        0        1        1             1     0      0
//    1        1        0        0             0     0      1
//    1        1        0        1             0     0      1
//    1        1        1        0             0     0      1
//    1        1        1        1             0     1      0

module comparor(
    input wire[1:0]     num1,
    input wire[1:0]     num2,//两位二进制数
    output wire         less,//若num1<num2，输出高电平
    output wire         equal,//若num1=num2，输出高电平
    output wire         greater//若num1>num2，输出高电平
);

assign less = ((~num1[1])&num2[1]) 
            | ((~num1[0])&num2[0]&num2[1])
            | ((~num1[0])&(~num1[1])&num2[0]);

assign equal = !(num1^num2);// ^是异或符号，如果num1和num2一样，则num1^num2 = 00，逻辑取反得1

assign greater = (~less)&(~equal);//不小于也不等于，就是大于

endmodule
// 弃用代码
// assign equal = (num1[0]&num1[1]&num2[0]&num2[1])
//             | ((~num1[0])&num1[1]&(~num2[0])&num2[1])
//             | (num1[0]&(~num1[1])&num2[0]&(~num2[1]))
//             | ((~num1[0])&(~num1[1])&(~num2[0])&(~num2[1]));