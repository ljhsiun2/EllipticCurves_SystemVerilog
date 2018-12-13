import elliptic_curve_structs::*;

module ecdsa_verify_control (
    input logic             clk,
    input logic             master_reset,

    /* inputs for control */
    input signature_t       created_signature,
    input logic             done_create_signature,
    input logic             done_hash,
    output logic            load_hash,
    input logic             init,

    /* outputs to datapath */
    output logic            reset,
    output logic            start_hash,
    output logic            done,
    output logic [255:0]    chacha_key,
    output logic [127:0]    chacha_nonce

);


enum logic [2:0] {
    idle,
    wait_hash,
    wait_sig,
    finish_signature,
    rst_states
} state, next_state;
// idle is for normal execution

always_ff @(posedge clk)
begin : next_state_assignment
    if(master_reset)
        state <= idle;
    else
        state <= next_state;
end


always_comb begin : state_actions

    done = 1'b0;
    reset = 1'b0;
    chacha_key = 256'd1985981961069;
    chacha_nonce = 128'd23981058942;
     start_hash = 0;
     load_hash = 0;

    case(state)
        idle: if(init) start_hash = 1;

        wait_hash : if(done_hash) load_hash = 1;

        wait_sig : ;

        finish_signature : begin
            reset = 1'b1;
            if(created_signature != 0)
                done = 1'b1;
        end

        rst_states : begin
            reset = 1'b1;
				// TODO this is so dumb that random isn't allowed...
//            chacha_key = $random(1, params.n);
//            chacha_nonce = $random(1, params.n);

        end
    endcase

end

always_comb begin : next_state_logic
    next_state = state;

	 case(state)
		 idle : begin
			  if(init) next_state = wait_hash;
		 end
         wait_hash : if(done_hash) next_state = wait_sig;
         wait_sig : if(done_create_signature) next_state = finish_signature;
		 finish_signature : begin
            if(created_signature == 0) next_state = rst_states;
            else next_state = idle;
         end
		 rst_states : next_state = idle;
	 endcase
 end

endmodule : ecdsa_verify_control
