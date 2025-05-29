`timescale  1ns/1ns

module tb_key_led();

wire  led_out;
reg   key_in;

initial key_in <= 1'b0;

always #10 key_in <= {$random} % 2;

key_led led_inst
(
  .key_in   (key_in),
  .led_out  (led_out)
);

endmodule