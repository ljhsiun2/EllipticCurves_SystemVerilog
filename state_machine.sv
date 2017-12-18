module state_machine(input logic Clk,
                                 Reset,
                                 Run,
                                 Continue,

                     input logic Enter,
                                 SD_Card,
                                 Card_error,
                                 [1:0] Option,
                                 [127:0] keyboard,
                     output logic [127:0] key,
                                 Done
);



enum logic [3:0] {Start, Encrypt, Encrypt_card, Decrypt, Decrypt_card,
     Decrypt_2, Encrypt_done, Decrypt_done} State, Next_state;

always_ff @ (posedge clk)
begin
    if(Reset)
        State <= Start;
    else if(Enter)
        State <= Next_state;
    else if(Option == 2'b10)
        State <= Start;
    else
        State <= State;
end

always_comb begin
    Next_state = State;

    unique case(State)
        Start:
        begin
            if(Option == 2'b00)
                Next_state = Encrypt;
            else if(Option == 2'b01)
                Next_state = Decrypt;
            else
                Next_state = Start;
        end
        Encrypt:
        begin
            if(SD_Card)
                Next_state = Encrypt_done;
            else
                Next_state = Encrypt_card;
        end
        Encrypt_card:
        begin
            if(SD_Card)
                Next_state = Encrypt;
            else
                Next_state = Encrypt_card;
        end
        Encrypt_done:
            Next_state = Start;
        Decrypt:
        begin
            if(SD_Card)
                Next_state = Decrypt_2;
            else
                Next_state = Decrypt_card;
        end
        Decrypt_card:
        begin
            if(SD_Card)
                Next_state = Decrypt;
            else
                Next_state = Decrypt_card;
        end
        Decrypt_2:
            Next_state = Decrypt_done;
        Decrypt_done:
            Next_state = Start;
        default: Next_state = Start;

    case(State)
        default: ;
        Start: ;
        Encrypt:
            
end
