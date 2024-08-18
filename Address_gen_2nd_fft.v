////////////////////// Index Generation for 2nd stage - FFT ///////////////////////////
/*
This block generates the index for twiddle factor depending on the row number in the 64 FFT,then this index
is passed to the multiplier to multiply the twiddle factor by the value exist at this row.
*/
////////////////////////////////////////////////////////////////////////////////////////



module Address_gen_2nd_fft #( parameter   STAGE_NO = 2,NFFT = 64 )
(
    input       wire                        clk, rst,
    input       wire                        Twiddle_active,
    output      reg  [5:0]     Twiddle_address // 6 bit address for 64 FFT
);


//////////////////////////////States////////////////////////////////////////////////////
localparam  IDLE = 0,
            ADDRESS_GEN = 1;



//////////////////////////////Internal Counters and Registers///////////////////////////
reg [5:0] counter, counter_seq     ;
reg                  current_state, next_state;



////////////////////////// State Transition/////////////////////////////////////////////
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        counter_seq <= 'b0;
        current_state <= IDLE;
    end
    else begin
        counter_seq <= counter;
        current_state <= next_state;
    end
end


/////////////////////// Next State and Output Logic///////////////////////////////////
always @(*) begin
       next_state = IDLE;
       Twiddle_address = 'b0;
       counter = 'b0;

       case (current_state)
          IDLE:begin
                   Twiddle_address = 'b0;
                    counter = 'b0;

                    if(Twiddle_active == 1'b1) begin
                        next_state = ADDRESS_GEN;
                    end
                    else begin
                        next_state = IDLE;
                    end
                end


////////////////////////////////////index generation///////////////////////////////////////
            ADDRESS_GEN:begin
                counter = counter_seq + 1'b1;

               
                    	/*if(counter_seq<24 || (counter_seq<40 && counter_seq>31) || (counter_seq<56 && counter_seq>47)) begin
                                    Twiddle_address = 0;
                    	end
                    	else if(counter_seq<32 && counter_seq>23) begin
                                    Twiddle_address = 2;
                    	end
                    	else if(counter_seq<48 && counter_seq>39) begin
                                    Twiddle_address = 1;
                    	end
                    	else if(counter_seq<64 && counter_seq>55) begin
                                    Twiddle_address = 3;
                    	end
        		        */
        
                       /*Depending on the counter value,the suitable address is generated*/

        		       Twiddle_address=counter_seq[3]*{counter_seq[4],counter_seq[5]}; //bit reversed P multiplied by Q


                        if(counter_seq == NFFT-1)begin //Reset Counter
                            next_state = IDLE;
                            end
                        else begin
                            next_state = ADDRESS_GEN;
                            end

                        end
        endcase

end
         
endmodule
