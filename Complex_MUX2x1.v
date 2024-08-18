module Complex_MUX2x1 #(
    parameter DATA_WIDTH = 18
) (
    input       wire                          sel,
    input       wire      [DATA_WIDTH-1:0]    in0_r, in0_i,
    input       wire      [DATA_WIDTH-1:0]    in1_r, in1_i,
    output      wire      [DATA_WIDTH-1:0]    out_r, out_i
);

assign out_r = sel?in1_r:in0_r;
assign out_i = sel?in1_i:in0_i;
    
endmodule