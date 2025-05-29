module SawTooth_Wave
(
  input   wire    clk
);

reg[7:0]  wave;
parameter waveMAX = 8'd255;
parameter waveMIN = 8'd0;
reg UpDown_flag;//0：向上计数，1：向下计数

initial begin
  wave = 8'd0;
  UpDown_flag = 1'b0;
  end

always @(posedge clk)
  case(UpDown_flag)
  1'b0: begin
    if(wave == waveMAX) begin
      wave <= wave - 8'd1;
      UpDown_flag <= 1'b1;
      end
    else begin
      wave <= wave + 8'd1;
      end
    end
  1'b1: begin
    if(wave == waveMIN) begin
      wave <= wave + 8'd1;
      UpDown_flag <= 1'b0;
      end
    else begin
      wave <= wave - 8'd1;
      end
    end
  default: begin
    end
  endcase

endmodule