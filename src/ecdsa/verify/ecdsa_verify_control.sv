//import elliptic_curve_structs::*;

module ecdsa_verify_control (
    input logic             clk,
    input logic             reset,

    /* inputs for control */
    input logic             done_verify,
    input logic             init_verify,


    /* outputs to datapath */
    output logic            start_hash,
    output logic            load_hash,
    input logic             done_hash

);


enum logic [2:0] {
    idle,
    wait_hash,
    wait_verify
} state, next_state;
// idle is for normal execution

always_ff @(posedge clk)
begin : next_state_assignment
    if(reset)
        state <= idle;
    else
        state <= next_state;
end


always_comb begin : state_actions

    start_hash = 0;
    load_hash = 0;

    case(state)
        idle: if(init_verify) start_hash = 1;

        wait_hash : if(done_hash) load_hash = 1;

        wait_verify : ;

    endcase

end

always_comb begin : next_state_logic
    next_state = state;

	 case(state)
		 idle : begin
			  if(init_verify) next_state = wait_hash;
		 end
         wait_hash : if(done_hash) next_state = wait_verify;
         wait_verify : if(done_verify) next_state = idle;
	 endcase
end

endmodule : ecdsa_verify_control
