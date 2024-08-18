module Complex_conjugate #(
    parameter DATA_WIDTH = 32
) (
    //input   wire                                clk, rst,
    input   wire    signed  [DATA_WIDTH-1:0]    data_in_r, data_in_i, 
    output  wire    signed  [DATA_WIDTH-1:0]    data_out_r, data_out_i
);
//wire signed [DATA_WIDTH-1:0]    data_out_i_comb; 

assign data_out_i = -data_in_i;
assign data_out_r = data_in_r;

endmodule