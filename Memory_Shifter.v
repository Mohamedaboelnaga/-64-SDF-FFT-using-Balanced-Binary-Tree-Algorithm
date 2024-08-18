module Memory_Shifter 
#(parameter MEMORY_DEPTH=8 ,DATA_WIDTH=16)
 (input    [DATA_WIDTH-1:0]    data_in_r, data_in_i,
 input      clk,
 input      rst,
 output   [DATA_WIDTH-1:0] data_out_r, data_out_i
);
    genvar i ;
wire [DATA_WIDTH-1:0] out_data_r [0:MEMORY_DEPTH-1];
wire [DATA_WIDTH-1:0] out_data_i [0:MEMORY_DEPTH-1];
    generate 
        for(i=0;i<(MEMORY_DEPTH);i=i+1)begin :for_loop
            if(i==0) begin
               delay_unit #(.DATA_WIDTH(DATA_WIDTH)) u0_r   (.clk(clk),.reset(rst), .in_data(data_in_r), .out_data(out_data_r[i]) );
               delay_unit #(.DATA_WIDTH(DATA_WIDTH)) u0_i   (.clk(clk),.reset(rst), .in_data(data_in_i), .out_data(out_data_i[i]) );
            end
            else  begin
                delay_unit #(.DATA_WIDTH(DATA_WIDTH)) u1_r  (.clk(clk),.reset(rst), .in_data(out_data_r[i-1]), .out_data(out_data_r[i]) );
                delay_unit #(.DATA_WIDTH(DATA_WIDTH)) u1_i  (.clk(clk),.reset(rst), .in_data(out_data_i[i-1]), .out_data(out_data_i[i]) );

            end
        end
    endgenerate

//assigning 
    assign data_out_r = out_data_r[MEMORY_DEPTH-1];
    assign data_out_i = out_data_i[MEMORY_DEPTH-1];
endmodule