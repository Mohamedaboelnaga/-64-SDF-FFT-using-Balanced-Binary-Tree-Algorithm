
module FFT_4th_stage #(
    parameter   INTEGER_SIZE = 6,
                FRACT_SIZE = 12,
                STAGE_NO = 1,
                NFFT = 64
) (
    input       wire                                             clk, rst,
    input       wire                                             start_conv,
    input       wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    serial_in_r, serial_in_i,
    output      wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    serial_out_r, serial_out_i
    //output      wire                                end_conv // can be used in future editions
);


localparam DATA_WIDTH = INTEGER_SIZE+FRACT_SIZE ;


//---------defining internal wires------//

//wire signed [DATA_WIDTH-1:0]      BUT_out2_r, BUT_out2_i;
wire signed [DATA_WIDTH-1:0]        BUF_in_r, BUF_in_i;     //buffer input
wire signed [DATA_WIDTH-1:0]        BUF_out_r, BUF_out_i;   //buffer output
wire signed [DATA_WIDTH-1:0]        BFLY_out1_r, BFLY_out1_i;   //butterfly out1
wire signed [DATA_WIDTH-1:0]        BFLY_out2_r, BFLY_out2_i;   //butterfly out2
wire signed [DATA_WIDTH-1:0]        MUL_r_buf_in, MUL_r_buf_out;
wire signed [DATA_WIDTH-1:0]        MUL_i_buf_in, MUL_i_buf_out;
wire signed [DATA_WIDTH-1:0]        TF_r_buf_out, TF_i_buf_out;
wire signed [DATA_WIDTH-1:0]        MUX2_in0_r, MUX2_in0_i;
wire signed [DATA_WIDTH-1:0]        MUX2_in1_r, MUX2_in1_i;
wire                                sel1, sel2 /*Twiddle_active*/;
wire        [5:0]      Twiddle_address;




Complex_MUX2x1 #(.DATA_WIDTH(DATA_WIDTH)) MUX1 (
    .sel(sel1),
    .in0_r(serial_in_r), 
    .in0_i(serial_in_i),
    .in1_r(BFLY_out2_r),
    .in1_i(BFLY_out2_i),
    .out_r(BUF_in_r),
    .out_i(BUF_in_i)
    );

Memory_Shifter #(   .DATA_WIDTH(DATA_WIDTH), 
                    .MEMORY_DEPTH(2**($clog2(NFFT)-STAGE_NO))) MS1 ( // 2^(log2(NFFT)-stagenumber)
    .clk(clk),
    .rst(rst),
    .data_in_r(BUF_in_r),
    .data_in_i(BUF_in_i),
    .data_out_r(BUF_out_r),
    .data_out_i(BUF_out_i)
);

Butterfly #(.DATA_WIDTH(DATA_WIDTH)) BF1 (
    //.clk(clk),
    //.rst(rst),
    .en(sel1),
    .in1_r(BUF_out_r),
    .in1_i(BUF_out_i),
    .in2_r(serial_in_r),
    .in2_i(serial_in_i),
    .sum_out_r(BFLY_out1_r),
    .sum_out_i(BFLY_out1_i),
    .diff_out_r(BFLY_out2_r),
    .diff_out_i(BFLY_out2_i)
);

delay_unit #(.DATA_WIDTH(1)) DU_SEL1_MUX2 (
    .clk(clk),
    .reset(rst),
    .in_data(sel1),
    .out_data(sel2)
);

Complex_MUX2x1 #(.DATA_WIDTH(DATA_WIDTH)) MUX2 (
    .sel(sel2),
    .in0_r(MUX2_in0_r),
    .in0_i(MUX2_in0_i),
    .in1_r(MUX2_in1_r),
    .in1_i(MUX2_in1_i),
    .out_r(MUL_r_buf_in),
    .out_i(MUL_i_buf_in)
);

delay_unit #(.DATA_WIDTH(DATA_WIDTH)) DU_MUX2_MUL_r (
    .clk(clk),
    .reset(rst),
    .in_data(MUL_r_buf_in),
    .out_data(MUL_r_buf_out)
);

delay_unit #(.DATA_WIDTH(DATA_WIDTH)) DU_MUX2_MUL_i (
    .clk(clk),
    .reset(rst),
    .in_data(MUL_i_buf_in),
    .out_data(MUL_i_buf_out)
);

MUX1_Control_unit #(.NFFT(NFFT), .STAGE_NO(STAGE_NO)) CU1 (
    .clk(clk),
    .rst(rst),
    .start_conv(start_conv),
    .sel1(sel1)
);

Address_gen_4th_fft #(.STAGE_NO(STAGE_NO), .NFFT(NFFT)) CU4 (
    .clk(clk),
    .rst(rst),
    .Twiddle_active(sel2),
    .Twiddle_address(Twiddle_address)
);


Trivial_multiplier_fft #(.INTEGER_SIZE(INTEGER_SIZE), .FRACT_SIZE(FRACT_SIZE)) MUL1 (
    .clk(clk),
    .rst(rst),
    .address(Twiddle_address),
    .in1_r(MUL_r_buf_out),
    .in1_i(MUL_i_buf_out),
    .out_r(serial_out_r),
    .out_i(serial_out_i)
);

delay_unit #(.DATA_WIDTH(DATA_WIDTH)) DU1_MS_r (
    .clk(clk),
    .reset(rst),
    .in_data(BUF_out_r),
    .out_data(MUX2_in0_r)
);

delay_unit #(.DATA_WIDTH(DATA_WIDTH)) DU1_MS_i (
    .clk(clk),
    .reset(rst),
    .in_data(BUF_out_i),
    .out_data(MUX2_in0_i)
);

delay_unit #(.DATA_WIDTH(DATA_WIDTH)) DU1_BF_r (
    .clk(clk),
    .reset(rst),
    .in_data(BFLY_out1_r),
    .out_data(MUX2_in1_r)
);

delay_unit #(.DATA_WIDTH(DATA_WIDTH)) DU1_BF_i (
    .clk(clk),
    .reset(rst),
    .in_data(BFLY_out1_i),
    .out_data(MUX2_in1_i)
);
endmodule