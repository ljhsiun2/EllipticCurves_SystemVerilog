import elliptic_curve_structs::*;

module ecdsa_sign_control (
    input logic             clk,

    /* inputs for control */
    input curve_point_t     pub_point,
    input signature_t       created_signature,
    input logic             done_create_signature,

    /* outputs to datapath */
    output logic            reset,
    output logic            done,
    output logic [255:0]    chacha_key,
    output logic [127:0]    chacha_nonce

);


enum logic [2:0] {
    idle,
    finish_signature,
    rst_states
} state, next_state;
// idle is for normal execution

always_comb begin : state_actions

    done = 1'b0;
    reset = 1'b0;
	 chacha_key = 0;
	 chacha_nonce = 0;
	 
    case(state)
        idle: ;

        finish_signature : begin
            done = 1'b1;
            reset = 1'b1;
        end

        rst_states : begin
            reset = 1'b1;
				// TODO this is so dumb that random isn't allowed...
//            chacha_key = $random(1, params.n);
//            chacha_nonce = $random(1, params.n);
				chacha_key = 256'd1985981961069;
				chacha_nonce = 128'd23981058942;
        end
    endcase

end

always_comb begin : next_state_logic
    next_state = state;

	 case(state)
		 idle : begin
			  if(done_create_signature) next_state = finish_signature;
		 end
		 finish_signature : if(created_signature == 0) next_state = rst_states;
		 rst_states : next_state = idle;
	 endcase
 end

always_ff @(posedge clk)
begin : next_state_assignment
    state <= next_state;
end

endmodule : ecdsa_sign_control