////////////////////// Index Generation for 5th stage - FFT ///////////////////////////
/*
This block generates the index for twiddle factor depending on the row number in the 64 FFT,then this index
is passed to the multiplier to multiply the twiddle factor by the value exist at this row.
*/
////////////////////////////////////////////////////////////////////////////////////////


module Address_gen_5th_fft #(parameter   STAGE_NO = 5, NFFT = 64 )
(
    input       wire                        clk, rst,
    input       wire                        Twiddle_active,
    output      reg  [5:0]                  Twiddle_address
);


//////////////////////////////States////////////////////////////////////////////////////
localparam  IDLE = 0,
            ADDRESS_GEN = 1;



//////////////////////////////Internal Counters and Registers///////////////////////////
reg [5:0] counter, counter_seq     ;
reg                    current_state, next_state;




////////////////////////// State Transition////////////////////////////////////////////
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
            ADDRESS_GEN: begin
                counter = counter_seq + 1'b1;

                /*According to the (MPQO) method to generate the address,
                m=3,p=2,q=1,o=zero,
                so the address in this stage is (p_inverted*q)
                which is multiplying the 1st bit by the
                inversion of the 2nd and the 3rd bit together in the counter
                 */              
                Twiddle_address=counter_seq[0]*{counter_seq[1],counter_seq[2]}; //bit reversed P multiplied by Q
                

                if(counter_seq == NFFT-1) //Reset Counter
                    next_state = IDLE;
                else
                    next_state = ADDRESS_GEN;
            end
    endcase
end

endmodule
