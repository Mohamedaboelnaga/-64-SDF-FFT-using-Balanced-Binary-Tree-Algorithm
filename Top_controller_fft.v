// this module can delay its output for 1 clock cycle if needed
module Top_controller_fft #( parameter   NFFT = 64 )
(
    input   wire                    clk, rst,
    input   wire                    start_FFT,
    output  reg  [$clog2(NFFT)-1:0] start_stage,
    output  reg                     end_FFT, data_valid
);


///////////////////////////////////////States////////////////////////////////////////
    localparam  IDLE = 0,
                STAGE_OPERATION = 1,
                DATA_VALID = 3;



//////////////////////////////Internal Counters and Registers/////////////////////////
reg [$clog2(NFFT)-1:0] counter1, counter1_seq;  //to count the number of cycles needed for each stage
reg [$clog2(NFFT)-1:0] counter_limit, counter_limit_seq; //to put limit for number of cycles needed for each stage
reg [$clog2(NFFT)-1:0] start_stage_seq;
reg [1:0]              current_state, next_state;




////////////////////////// State Transition////////////////////////////////////////////
always @(posedge clk or negedge rst) begin
    if(!rst) begin
        counter1_seq <= 'b0;
        counter_limit_seq <= 'b0;
        current_state <= 2'b0;
        start_stage_seq <= 'b0;
        
    end
    else begin
        counter1_seq <= counter1;
        counter_limit_seq <= counter_limit;
        current_state <= next_state;
        start_stage_seq <= start_stage;
    end
end



/////////////////////// Next State and Output Logic///////////////////////////////////
always @(*) begin
    counter1 = 'b0;
    counter_limit = 'b0;
    next_state = IDLE;
    start_stage = 'b0;
    end_FFT = 1'b0;
    data_valid = 1'b0;

    case (current_state)
    //---------------IDLE state---------------//
        IDLE: begin
            if(start_FFT) begin
                next_state = STAGE_OPERATION;
                start_stage = 'b1;
                counter1 = 'b0;
                counter_limit = NFFT>>1;
            end
            else begin
                next_state = IDLE;
                start_stage = 'b0;
                counter1 = 'b0;
                counter_limit = 'b0;
            end
        end 
        
    //-----------start operation state---------//
        STAGE_OPERATION: begin
            counter_limit = counter_limit_seq;
            start_stage = start_stage_seq;
            if(counter1_seq == counter_limit_seq+2) begin
                if(start_stage[$clog2(NFFT)-1] == 1) begin //indicates finishing the last stage
                    //next_state = IDLE;
                    next_state = DATA_VALID;
                    start_stage = 'b0;
                    counter1 = 'b0;
                    counter_limit = NFFT-1;
                    end_FFT = 1'b1;
                    data_valid = 1'b1;
                end
                else begin //indicates starting intermidia
                    next_state = STAGE_OPERATION;
                    start_stage = start_stage_seq<<1;
                    counter1 = 'b0;
                    counter_limit = counter_limit_seq>>1;
                    end_FFT = 1'b0;
                end
            end
            else begin
                next_state = STAGE_OPERATION;
                counter1 = counter1_seq + 1'b1;
            end
        end


    //-------------data valid enable-----------//
        DATA_VALID: begin
            counter_limit = counter_limit_seq;
            data_valid = 1'b1;
            if(counter1_seq == counter_limit_seq) begin //the output finished streaming the reuslts
                next_state = IDLE;
                counter1 = 'b0;
                data_valid = 1'b0;
            end
            else begin // the output is still processing
                next_state = DATA_VALID;
                counter1 = counter1_seq +1'b1;
            end
        end
    endcase
end

endmodule