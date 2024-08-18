////////////////////// Complex shift right ///////////////////////////
/*
dividing the value by factor of 2
*/
////////////////////////////////////////////////////////////////////////////////////////
module Complex_shift_right
#(parameter DATA_WIDTH = 16,
            NFFT = 128) (
    input   wire signed    [DATA_WIDTH-1:0]  data_in_r, data_in_i,
    input wire [$clog2(NFFT):0] shift_mag,
    //input wire [DATA_WIDTH-1:0]  shift_mag,
    output  wire signed   [DATA_WIDTH-1:0] data_out_r, data_out_i
);

assign data_out_r = data_in_r >>> shift_mag;
assign data_out_i = data_in_i >>> shift_mag;
endmodule