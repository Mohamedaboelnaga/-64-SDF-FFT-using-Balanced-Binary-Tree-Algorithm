////////////////////// Address Generation for 3rd stage - FFT ///////////////////////////
/*
This block generates the address for the 3rd stage in the 64 FFT,then this address
is passed to certain twiddle factors to be multiplied with.
*/
////////////////////////////////////////////////////////////////////////////////////////


module Address_gen_3rd_fft #( parameter  STAGE_NO = 3, NFFT = 64 )
(
    input       wire                        clk, rst,
    input       wire                        Twiddle_active,
    output      reg  [5:0]     Twiddle_address // 6 bit address for 64 FFT
);


//////////////////////////////States////////////////////////////////////////////////////

localparam  IDLE = 0,
            ADDRESS_GEN = 1;

//////////////////////////////Internal Counters and Registers////////////////////////////
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
/////////////////////////////////////////// Address generation /////////////////////////////////////////////
        ADDRESS_GEN: begin
            counter = counter_seq + 1'b1;
            
           /*Here,the address is just the value of the counter because we will ned all the 64 adresses in this stage*/           
            Twiddle_address = counter_seq;

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