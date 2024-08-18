////////////////////// Complex multiplier ///////////////////////////
/*
This block multiply 2 complex numbers
*/
////////////////////////////////////////////////////////////////////////////////////////

module Complex_Multiplier_fft #(
    parameter INTEGER_SIZE = 8,
                FRACT_SIZE = 8
) (
    input   wire                                             clk, rst,
    input   wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    in1_r,in1_i,
    input   wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    in2_r,in2_i,
    output  wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    out_r,out_i
);


localparam DATA_WIDTH = INTEGER_SIZE+FRACT_SIZE ;

//-----out_r = in1_r*in2_r - in1_i*in2_i---------//
//-----out_i = in1_r*in2_i + in2_r*in1_i---------//
//---------prod1 = in1_r*in2_r-----------//
//---------prod2 = in1_i*in2_i-----------//
//---------prod3 = in1_r*in2_i-----------//
//---------prod4 = in2_r*in1_i-----------//



wire signed [2*DATA_WIDTH-1:0] prod1, prod2, prod3, prod4;
wire signed [2*DATA_WIDTH-1:0] prod1_seq, prod2_seq, prod3_seq, prod4_seq;



wire signed [DATA_WIDTH-1:0]   temp1, temp2,temp3,temp4;

// neglect some of the fractional bits to make  the result in the required size

assign temp1=prod1_seq>>FRACT_SIZE;
assign temp2=prod2_seq>>FRACT_SIZE;
assign temp3=prod3_seq>>FRACT_SIZE;
assign temp4=prod4_seq>>FRACT_SIZE;

assign out_r = (temp1 - temp2);
assign out_i = (temp3 + temp4);


//assign out_r = (prod1_seq - prod2_seq)>>FRACT_SIZE;
//assign out_i = (prod3_seq + prod4_seq)>>FRACT_SIZE;




Multiplier #(.DATA_WIDTH(DATA_WIDTH)) M0 (.in1(in1_r), .in2(in2_r), .out(prod1));
Multiplier #(.DATA_WIDTH(DATA_WIDTH)) M1 (.in1(in1_i), .in2(in2_i), .out(prod2));
Multiplier #(.DATA_WIDTH(DATA_WIDTH)) M2 (.in1(in1_r), .in2(in2_i), .out(prod3));
Multiplier #(.DATA_WIDTH(DATA_WIDTH)) M3 (.in1(in2_r), .in2(in1_i), .out(prod4));

delay_unit #(.DATA_WIDTH(2*DATA_WIDTH)) D1 (.clk(clk), .reset(rst), .in_data(prod1), .out_data(prod1_seq));
delay_unit #(.DATA_WIDTH(2*DATA_WIDTH)) D2 (.clk(clk), .reset(rst), .in_data(prod2), .out_data(prod2_seq));
delay_unit #(.DATA_WIDTH(2*DATA_WIDTH)) D3 (.clk(clk), .reset(rst), .in_data(prod3), .out_data(prod3_seq));
delay_unit #(.DATA_WIDTH(2*DATA_WIDTH)) D4 (.clk(clk), .reset(rst), .in_data(prod4), .out_data(prod4_seq));


//delay_unit #(.DATA_WIDTH(DATA_WIDTH)) D5_r (.clk(clk), .reset(rst), .in_data(out_r_comb), .out_data(out_r));
//delay_unit #(.DATA_WIDTH(DATA_WIDTH)) D5_i (.clk(clk), .reset(rst), .in_data(out_i_comb), .out_data(out_i));

endmodule