// File : complex_mul.v
// Author : Mohamed Ayman
// Date : 4/5/2024
// Version : 1
// Abstract : This file contains a complex muliplier block

module Complex_Multiplier #(
    parameter INTEGER_SIZE = 7,
              FRACT_SIZE = 11
) (
    input   wire                                                       clk, rst,
    input   wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]              in1_r,in1_i,
    input   wire    signed  [INTEGER_SIZE+FRACT_SIZE-1:0]              in2_r,in2_i,
    output  wire    signed  [ ( INTEGER_SIZE+FRACT_SIZE ) - 1 : 0 ]    out_r,out_i
);
localparam DATA_WIDTH = INTEGER_SIZE+FRACT_SIZE ;

wire [ ( 2 * DATA_WIDTH ) - 1 : 0 ] MUL_rr , MUL_ii , MUL_ri , MUL_ir;

wire [ (  DATA_WIDTH ) - 1 : 0 ] MUL_rr_reg ,
                                    MUL_ii_reg ,
                                    MUL_ir_reg ,
                                    MUL_ri_reg;

wire [ (  DATA_WIDTH ) - 1 : 0 ] Trunc_MUL_rr ,
                                 Trunc_MUL_ii ,
                                 Trunc_MUL_ri ,
                                 Trunc_MUL_ir;

wire [ (  DATA_WIDTH ) - 1 : 0 ] Trunc_MUL_rr_reg ,
                                 Trunc_MUL_ii_reg ,
                                 Trunc_MUL_ri_reg ,
                                 Trunc_MUL_ir_reg;

wire [ (   DATA_WIDTH ) - 1 : 0 ] out_r_comb ,
                                     out_i_comb;


assign MUL_rr = ( in1_r * in2_r ) ;
assign MUL_ii = ( in1_i * in2_i ) ;

assign MUL_ri = ( in1_r * in2_i ) ;
assign MUL_ir = ( in1_i * in2_r ) ;


assign Trunc_MUL_rr = MUL_rr >> (FRACT_SIZE);
assign Trunc_MUL_ii = MUL_ii >> (FRACT_SIZE);

assign Trunc_MUL_ir = MUL_ri >> (FRACT_SIZE);
assign Trunc_MUL_ri = MUL_ir >> (FRACT_SIZE);

register#( .DATA_WIDTH(DATA_WIDTH) ) reg0( .clk(clk) , .rst(rst) , .in(Trunc_MUL_rr) , .out(MUL_rr_reg) );
register#( .DATA_WIDTH(DATA_WIDTH) ) reg1( .clk(clk) , .rst(rst) , .in(Trunc_MUL_ii) , .out(MUL_ii_reg) );
register#( .DATA_WIDTH(DATA_WIDTH) ) reg2( .clk(clk) , .rst(rst) , .in(Trunc_MUL_ir) , .out(MUL_ir_reg) );
register#( .DATA_WIDTH(DATA_WIDTH) ) reg3( .clk(clk) , .rst(rst) , .in(Trunc_MUL_ri) , .out(MUL_ri_reg) );


assign out_r_comb = MUL_rr_reg - MUL_ii_reg;
assign out_i_comb = MUL_ir_reg + MUL_ri_reg;


register#( .DATA_WIDTH(DATA_WIDTH) )  reg8( .clk(clk) , .rst(rst) , .in(out_r_comb) , .out(out_r) );
register#( .DATA_WIDTH(DATA_WIDTH) )  reg9( .clk(clk) , .rst(rst) , .in(out_i_comb) , .out(out_i) );

endmodule