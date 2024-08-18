////////////////////// Constant multiplier ///////////////////////////
/*
This block multiply the input complex number to one of the 4 constant numbers.
It acts like a 4 input mux
*/
////////////////////////////////////////////////////////////////////////////////////////


module Constant_Multiplier_fft #(
    parameter INTEGER_SIZE = 6,
                FRACT_SIZE = 12,
                NFFT=64
) (
    input   wire            [5:0]               address,
    input   wire                                             clk, rst,
    input   wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    in1_r,in1_i,
    output  wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    out_r,out_i
);

localparam DATA_WIDTH = INTEGER_SIZE+FRACT_SIZE ;


reg signed  [INTEGER_SIZE+FRACT_SIZE-1:0]    in2_r,in2_i;
wire signed [2*DATA_WIDTH-1:0]               prod1, prod2, prod3, prod4;
wire signed [2*DATA_WIDTH-1:0]               prod1_seq, prod2_seq, prod3_seq, prod4_seq;


always @(*) begin

   /*
   //18:14-4
   case (address) 
	'd0 : begin
	in2_r= 'b000100000000000000; 
	in2_i= 'b000000000000000000;
	end
	'd1 : begin
	in2_r= 'b000010110101000001;
	in2_i= 'b111101001010111111;
	end
	'd2 : begin
	in2_r= 'b000000000000000000;
	in2_i= 'b111100000000000000;
	end
	'd3 : begin
	in2_r= 'b111101001010111111;
	in2_i= 'b111101001010111111;
	end
	default:begin
	in2_r='b0;
	in2_i='b0;
	end
	endcase

*/

    //18:13-5
	case (address) 
	'd0 : begin
	in2_r= 'b000010000000000000; 
	in2_i= 'b000000000000000000;
	end
	'd1 : begin
	in2_r= 'b000001011010100000;
	in2_i= 'b111110100101100000;
	end
	'd2 : begin
	in2_r= 'b000000000000000000;
	in2_i= 'b111110000000000000;
	end
	'd3 : begin
	in2_r= 'b111110100101100000;
	in2_i= 'b111110100101100000;
	end
	default:begin
	in2_r='b0;
	in2_i='b0;
	end
	endcase

end


wire signed [DATA_WIDTH-1:0]   temp1, temp2,temp3,temp4;

assign temp1=prod1_seq>>FRACT_SIZE;
assign temp2=prod2_seq>>FRACT_SIZE;
assign temp3=prod3_seq>>FRACT_SIZE;
assign temp4=prod4_seq>>FRACT_SIZE;

assign out_r = (temp1 - temp2);
assign out_i = (temp3 + temp4);

//assign out_r =  (prod1_seq - prod2_seq)>>FRACT_SIZE;
//assign out_i =  (prod3_seq + prod4_seq)>>FRACT_SIZE;

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
