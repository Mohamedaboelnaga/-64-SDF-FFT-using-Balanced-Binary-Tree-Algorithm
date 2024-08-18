module Multiplier #(
    parameter DATA_WIDTH = 16
) (
    input wire signed [DATA_WIDTH-1:0] in1, in2,
    output wire signed [2*DATA_WIDTH-1:0] out
);
  assign out = in1*in2;
endmodule