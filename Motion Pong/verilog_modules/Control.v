module Control( clock,
                resetn,
                go,

                rainbow,

                fin_Text1,
                fin_Text2,

                fin_B_D,
                fin_B_E,

                fin_P1_D,
                fin_P1_E,

                fin_P2_D,
                fin_P2_E,

                fin_S1_D,
                fin_S2_D,
                fin_clr_scr,

                fin_game,

                ld_Val_out,

                en_B_shapeCounter_D,
                en_B_shapeCounter_E,

                en_P1_shapeCounter_D,
                en_P1_shapeCounter_E,

                en_P2_shapeCounter_D,
                en_P2_shapeCounter_E,

                en_reset_player_scores,
                en_clr_scr,

                en_Score1,
                en_Score2,

                en_Text1,
                en_Text2,

                fin_Wait,
                en_delayCounter,

                plot,

                sel_text,
                sel_out,
                sel_col
    );
    // absolute input signals
    input clock, resetn, go;

    // dynamic input singnals
    input fin_B_D;
    input fin_B_E;
    input fin_P1_D;
    input fin_P1_E;
    input fin_P2_D;
    input fin_P2_E;
    input fin_Wait;
    input fin_S1_D;
    input fin_S2_D;
    input fin_Text1;
    input fin_Text2;
    input fin_game;
    input fin_clr_scr;
    input rainbow;

    // ouput signals
    output reg plot, ld_Val_out;
    output reg en_B_shapeCounter_D, en_B_shapeCounter_E;
    output reg en_P1_shapeCounter_D, en_P1_shapeCounter_E;
    output reg en_P2_shapeCounter_D, en_P2_shapeCounter_E;
    output reg en_delayCounter;
    output reg en_Score1;
    output reg en_Score2;
    output reg en_Text1;
    output reg en_Text2;
    output reg en_reset_player_scores;
    output reg en_clr_scr;

    output reg [2:0] sel_col;
    output reg [2:0] sel_out;
    output reg [4:0] sel_text;

    //output [6:0] HEX0, HEX2;

    // declare registers for the FSM
    reg [5:0] current_state, next_state;

    // assign the states a value
    localparam  S_INIT = 5'd0,
                S_LOAD_WAIT = 5'd1,
				S_LOAD = 5'd2,

                S_CLEAR  = 5'd3,

                S_PLOT_SCORE1 = 5'd4,
                S_PLOT_PADDLE1 = 5'd5,
                S_PLOT = 5'd6,
                S_PLOT_PADDLE2 = 5'd7,
                S_PLOT_SCORE2 = 5'd8,

                S_WAIT = 5'd9,

                S_DELETE_PADDLE1 = 5'd10,
                S_DELETE = 5'd11,
                S_DELETE_PADDLE2 = 5'd12,

                S_DONE = 5'd13,

                S_FIN_P = 5'd14,
                S_FIN_L = 5'd15,
                S_FIN_A = 5'd16,
                S_FIN_Y = 5'd17,
                S_FIN_E = 5'd18,
                S_FIN_R = 5'd19,
                S_FIN_num = 5'd25,
                S_FIN_W = 5'd20,
                S_FIN_I = 5'd21,
                S_FIN_N = 5'd22,
                S_FIN_S = 5'd23,
                S_FIN_ex = 5'd24;

    // state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_INIT: next_state = S_LOAD_WAIT;
                S_LOAD_WAIT: next_state = S_LOAD;
                S_LOAD: next_state = go ? S_CLEAR : S_LOAD;

                S_CLEAR: next_state = fin_clr_scr ? S_PLOT_SCORE1 : S_CLEAR;

                S_PLOT_SCORE1: next_state = fin_S1_D ? S_PLOT_PADDLE1 : S_PLOT_SCORE1;

                S_PLOT_PADDLE1: next_state = fin_P1_D ? S_PLOT : S_PLOT_PADDLE1;

                S_PLOT: next_state = fin_B_D ? S_PLOT_PADDLE2 : S_PLOT;

                S_PLOT_PADDLE2: next_state = fin_P2_D ? S_PLOT_SCORE2 : S_PLOT_PADDLE2;

                S_PLOT_SCORE2: next_state = fin_S2_D ? S_WAIT : S_PLOT_SCORE2;                

                S_WAIT: next_state = fin_Wait ? S_DELETE_PADDLE1: S_WAIT;

                S_DELETE_PADDLE1: next_state = fin_P1_E ? S_DELETE : S_DELETE_PADDLE1;

                S_DELETE: next_state = fin_B_E ? S_DELETE_PADDLE2 : S_DELETE;

                S_DELETE_PADDLE2: next_state = fin_P2_E ? S_DONE : S_DELETE_PADDLE2;

                S_DONE: next_state = fin_game ? S_FIN_P :  S_PLOT_SCORE1;

                S_FIN_P: next_state = fin_Text1 ? S_FIN_L: S_FIN_P;

                S_FIN_L: next_state = fin_Text2 ? S_FIN_A: S_FIN_L;
                
                S_FIN_A: next_state = fin_Text1 ? S_FIN_Y: S_FIN_A;

                S_FIN_Y: next_state = fin_Text2 ? S_FIN_E: S_FIN_Y;

                S_FIN_E: next_state = fin_Text1 ? S_FIN_R: S_FIN_E;

                S_FIN_R: next_state = fin_Text2 ? S_FIN_num: S_FIN_R;

                S_FIN_num : next_state = fin_Text1 ? S_FIN_W : S_FIN_num;

                S_FIN_W: next_state = fin_Text2 ? S_FIN_I: S_FIN_W;

                S_FIN_I: next_state = fin_Text1 ? S_FIN_N: S_FIN_I;

                S_FIN_N: next_state = fin_Text2 ? S_FIN_S: S_FIN_N;

                S_FIN_S: next_state = fin_Text1 ? S_FIN_ex: S_FIN_S;

                S_FIN_ex: next_state = fin_Text2 ? S_LOAD: S_FIN_ex;

            default: next_state = S_INIT;
        endcase
    end // state_table

    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals		
        // give instructions based on the current state
		case(current_state)
			S_INIT: begin
				plot = 1'b0;

                sel_out = 3'd0;
                sel_col = 3'd0;
                sel_text = 5'd0;

                ld_Val_out = 1'b0;                
                en_Score1 = 1'b0;
                en_Score2 = 1'b0;

                en_delayCounter = 1'b0;
                en_Text1 = 1'b0;

                en_clr_scr = 1'b0;
                en_reset_player_scores = 1'b0;

				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_Text2 = 1'b0;
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;  
                
			end
			S_LOAD_WAIT: begin
				plot = 1'b0;

                sel_out = 3'd0;
                en_Score2 = 1'b0;
                sel_col = 3'd0;

                en_reset_player_scores = 1'b0;
                en_clr_scr = 1'b0;
                ld_Val_out = 1'b1;
                sel_text = 5'd0;

                en_delayCounter = 1'b0;
                en_Score1 = 1'b0;

				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_P1_shapeCounter_D = 1'b0;
                en_Text2 = 1'b0;
                en_P1_shapeCounter_E = 1'b0;
                en_Text1 = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0; 
            end
            S_LOAD: begin
                plot = 1'b0;

                sel_out = 3'd0;
                sel_col = 3'd0;

                ld_Val_out = 1'b0;
                en_Score2 = 1'b0;
                sel_text = 5'd0;
                en_reset_player_scores = 1'b0;

                en_delayCounter = 1'b0;

				en_B_shapeCounter_D = 1'b0;
                en_Score1 = 1'b0;
                en_B_shapeCounter_E = 1'b0;
                en_Text1 = 1'b0;

                en_clr_scr = 1'b0;
                en_P1_shapeCounter_D = 1'b0;
                en_Text2 = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0; 
            end
            S_PLOT: begin
                plot = 1'b1;

                sel_out = 3'd0;
                sel_col =  rainbow ? 3'd7 : 3'd0;

                ld_Val_out = 1'b0;
                sel_text = 5'd0;

                en_delayCounter = 1'b0;
                en_Score2 = 1'b0;
                en_reset_player_scores = 1'b0;

                en_Text1 = 1'b0;
				en_B_shapeCounter_D = 1'b1;
                en_B_shapeCounter_E = 1'b0;
                en_Score1 = 1'b0;
                en_Text2 = 1'b0;

                en_clr_scr = 1'b0;
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0; 
            end
            S_WAIT: begin
                plot = 1'b0;

                sel_out = 3'd0;
                sel_col = 3'd0;

                ld_Val_out = 1'b0;
                sel_text = 5'd0;

                en_Score2 = 1'b0;
                en_reset_player_scores = 1'b0;
                en_delayCounter = 1'b1;
                en_Score1 = 1'b0;
                en_Text2 = 1'b0;

				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_P1_shapeCounter_D = 1'b0;
                en_Text1 = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_clr_scr = 1'b0;
                en_P2_shapeCounter_E = 1'b0; 

            end
            S_DELETE: begin
                plot = 1'b1;

                sel_out = 3'd0;
                sel_col = 3'd3;

                ld_Val_out = 1'b0;
                sel_text = 5'd0;
                en_reset_player_scores = 1'b0;
                en_Score2 = 1'b0;

                en_delayCounter = 1'b0;

                en_Score1 = 1'b0;
				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b1;
                en_Text2 = 1'b0;
                en_clr_scr = 1'b0;

                en_Text1 = 1'b0;
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0; 

            end
            S_PLOT_PADDLE1: begin
                plot = 1'b1;

                sel_out = 3'd1;
                sel_col = rainbow ? 3'd7 : 3'd2;

                ld_Val_out = 1'b0;

                en_reset_player_scores = 1'b0;
                en_delayCounter = 1'b0;

				en_B_shapeCounter_D = 1'b0;
                en_Score1 = 1'b0;
                en_B_shapeCounter_E = 1'b0;
                sel_text = 5'd0;
                en_clr_scr = 1'b0;
                en_Text2 = 1'b0;
                en_Score2 = 1'b0;
                en_Text1 = 1'b0;

                en_P1_shapeCounter_D = 1'b1;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0; 
            end
            S_DELETE_PADDLE1: begin
                plot = 1'b1;

                sel_out = 3'd1;
                sel_col = 3'd3;

                en_Score1 = 1'b0;
                sel_text = 5'd0;
                en_reset_player_scores = 1'b0;
                ld_Val_out = 1'b0;
                en_Text1 = 1'b0;

                en_delayCounter = 1'b0;

				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;
                en_Score2 = 1'b0;

                en_Text2 = 1'b0;
                en_clr_scr = 1'b0;
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b1;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0; 
            end
            S_PLOT_PADDLE2: begin
                plot = 1'b1;

                sel_out = 3'd2;
                sel_col = rainbow ? 3'd7 : 3'd2;

                ld_Val_out = 1'b0;
                en_Score1 = 1'b0;
                en_Text1 = 1'b0;

                en_delayCounter = 1'b0;
                en_reset_player_scores = 1'b0;

				en_B_shapeCounter_D = 1'b0;
                en_clr_scr = 1'b0;
                en_Score2 = 1'b0;
                en_B_shapeCounter_E = 1'b0;
                en_Text2 = 1'b0;

                sel_text = 5'd0;
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b1;
                en_P2_shapeCounter_E = 1'b0; 
            end
            S_DELETE_PADDLE2: begin
                plot = 1'b1;

                sel_out = 3'd2;
                sel_col = 3'd3;

                ld_Val_out = 1'b0;
                sel_text = 5'd0;
                en_Score1 = 1'b0;
                en_reset_player_scores = 1'b0;

                en_delayCounter = 1'b1;

				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;
                en_Text1 = 1'b0;
                en_clr_scr = 1'b0;
                en_Text2 = 1'b0;

                en_Score2 = 1'b0;
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b1; 
            end

            S_DONE: begin
                plot = 1'b0;

                sel_out = 3'd0;
                sel_col = 3'd0;

                ld_Val_out = 1'b0;
                sel_text = 5'd0;

                en_reset_player_scores = 1'b0;
                en_delayCounter = 1'b0;

                en_Score2 = 1'b0;
                en_Score1 = 1'b0;
                en_clr_scr = 1'b0;
				en_B_shapeCounter_D = 1'b0;
                en_Text1 = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_Text2 = 1'b0;
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0; 

            end
            S_PLOT_SCORE1:
            begin
                plot = 1'b1;

                sel_out = 3'd3;
                sel_col = 3'd1;

                ld_Val_out = 1'b0;                
                sel_text = 5'd0;

                en_Text1 = 1'b0;
                en_reset_player_scores = 1'b0;
                en_delayCounter = 1'b0;

				en_B_shapeCounter_D = 1'b0;
                en_Score2 = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_clr_scr = 1'b0;
                en_Score1 = 1'b1;
                en_Text2 = 1'b0;
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;
            end
            S_PLOT_SCORE2:
            begin
                en_Text1 = 1'b0;
                plot = 1'b1;

                sel_out = 3'd4;
                sel_col = 3'd4;
                sel_text = 5'd0;

                ld_Val_out = 1'b0;                

                en_delayCounter = 1'b0;

                en_reset_player_scores = 1'b0;
				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_clr_scr = 1'b0;
                en_Score1 = 1'b0;
                en_Score2 = 1'b1;
                
                en_Text2 = 1'b0;
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;
            end
            S_FIN_P:
            begin
                plot = 1'b1;

                sel_out = 3'd5;
                sel_col = 3'd5;

                ld_Val_out = 1'b0;                
                sel_text = 5'd15;

                en_delayCounter = 1'b0;

                en_reset_player_scores = 1'b1;
				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_Score1 = 1'b0;
                en_Score2 = 1'b0;
                en_clr_scr = 1'b0;

                en_Text1 = 1'b1;
                en_Text2 = 1'b0;
                
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;
            end
            S_FIN_A:
            begin
                plot = 1'b1;

                sel_out = 3'd5;
                sel_col = 3'd5;

                ld_Val_out = 1'b0;                
                sel_text = 5'd0;

                en_delayCounter = 1'b0;

                en_reset_player_scores = 1'b1;
				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_Score1 = 1'b0;
                en_Score2 = 1'b0;
                en_clr_scr = 1'b0;

                en_Text1 = 1'b1;
                en_Text2 = 1'b0;
                
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;
            end
            S_FIN_E:
            begin
                plot = 1'b1;

                sel_out = 3'd5;
                sel_col = 3'd5;

                ld_Val_out = 1'b0;                
                sel_text = 5'd4;

                en_delayCounter = 1'b0;

                en_reset_player_scores = 1'b1;
				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_Score1 = 1'b0;
                en_Score2 = 1'b0;
                en_clr_scr = 1'b0;

                en_Text1 = 1'b1;
                en_Text2 = 1'b0;
                
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;
            end
            S_FIN_W:
            begin
                plot = 1'b1;

                sel_out = 3'd6;
                sel_col = 3'd6;

                ld_Val_out = 1'b0;                
                sel_text = 5'd22;

                en_delayCounter = 1'b0;

                en_reset_player_scores = 1'b1;
				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_Score1 = 1'b0;
                en_Score2 = 1'b0;
                en_clr_scr = 1'b0;

                en_Text1 = 1'b0;
                en_Text2 = 1'b1;
                
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;
            end
            S_FIN_N:
            begin
                plot = 1'b1;

                sel_out = 3'd6;
                sel_col = 3'd6;

                ld_Val_out = 1'b0;                
                sel_text = 5'd13;

                en_delayCounter = 1'b0;

                en_reset_player_scores = 1'b1;
				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_Score1 = 1'b0;
                en_Score2 = 1'b0;
                en_clr_scr = 1'b0;

                en_Text1 = 1'b0;
                en_Text2 = 1'b1;
                
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;
            end
            S_FIN_ex:
            begin
                plot = 1'b1;

                sel_out = 3'd6;
                sel_col = 3'd6;

                ld_Val_out = 1'b0;                
                sel_text = 5'd28;

                en_delayCounter = 1'b0;

                en_reset_player_scores = 1'b1;
				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_Score1 = 1'b0;
                en_Score2 = 1'b0;
                en_clr_scr = 1'b0;

                en_Text1 = 1'b0;
                en_Text2 = 1'b1;
                
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;
            end
            S_CLEAR:
            begin
                plot = 1'b1;

                sel_out = 3'd7;
                sel_col = 3'd3;

                ld_Val_out = 1'b0;                
                sel_text = 5'd15;

                en_delayCounter = 1'b0;

                en_reset_player_scores = 1'b0;
				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_Score1 = 1'b0;
                en_Score2 = 1'b0;

                en_Text1 = 1'b0;
                                en_Text2 = 1'b0;

                en_clr_scr = 1'b1;

                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;
            end
            S_FIN_L:
            begin
                plot = 1'b1;

                sel_out = 3'd6;
                sel_col = 3'd6;

                ld_Val_out = 1'b0;                
                sel_text = 5'd11;

                en_delayCounter = 1'b0;

                en_reset_player_scores = 1'b0;
				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_Score1 = 1'b0;
                en_Score2 = 1'b0;
                en_clr_scr = 1'b0;

                en_Text1 = 1'b0;
                en_Text2 = 1'b1;
                
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;
            end

            S_FIN_Y:
            begin
                plot = 1'b1;

                sel_out = 3'd6;
                sel_col = 3'd6;

                ld_Val_out = 1'b0;                
                sel_text = 5'd24;

                en_delayCounter = 1'b0;

                en_reset_player_scores = 1'b0;
				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_Score1 = 1'b0;
                en_Score2 = 1'b0;
                en_clr_scr = 1'b0;

                en_Text1 = 1'b0;
                en_Text2 = 1'b1;
                
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;
            end

            S_FIN_R:
            begin
                plot = 1'b1;

                sel_out = 3'd6;
                sel_col = 3'd6;

                ld_Val_out = 1'b0;                
                sel_text = 5'd17;

                en_delayCounter = 1'b0;

                en_reset_player_scores = 1'b0;
				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_Score1 = 1'b0;
                en_Score2 = 1'b0;
                en_clr_scr = 1'b0;

                en_Text1 = 1'b0;
                en_Text2 = 1'b1;
                
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;
            end

            S_FIN_I:
            begin
                plot = 1'b1;

                sel_out = 3'd5;
                sel_col = 3'd5;

                ld_Val_out = 1'b0;                
                sel_text = 5'd8;

                en_delayCounter = 1'b0;

                en_reset_player_scores = 1'b0;
				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_Score1 = 1'b0;
                en_Score2 = 1'b0;
                en_clr_scr = 1'b0;

                en_Text1 = 1'b1;
                en_Text2 = 1'b0;
                
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;
            end

            S_FIN_S:
            begin
                plot = 1'b1;

                sel_out = 3'd5;
                sel_col = 3'd5;

                ld_Val_out = 1'b0;                
                sel_text = 5'd18;

                en_delayCounter = 1'b0;

                en_reset_player_scores = 1'b0;
				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_Score1 = 1'b0;
                en_Score2 = 1'b0;
                en_clr_scr = 1'b0;

                en_Text1 = 1'b1;
                en_Text2 = 1'b0;
                
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;
            end

            S_FIN_num:
            begin
                plot = 1'b1;

                sel_out = 3'd5;
                sel_col = 3'd5;

                ld_Val_out = 1'b0;                
                sel_text = 5'd29;

                en_delayCounter = 1'b0;

                en_reset_player_scores = 1'b0;
				en_B_shapeCounter_D = 1'b0;
                en_B_shapeCounter_E = 1'b0;

                en_Score1 = 1'b0;
                en_Score2 = 1'b0;
                en_clr_scr = 1'b0;

                en_Text1 = 1'b1;
                en_Text2 = 1'b0;
                
                en_P1_shapeCounter_D = 1'b0;
                en_P1_shapeCounter_E = 1'b0;

                en_P2_shapeCounter_D = 1'b0;
                en_P2_shapeCounter_E = 1'b0;
            end
            // default: // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase //output logic
    end

    // current_state registers
    always @(posedge clock)
        begin: state_FFs
            if(!resetn)
                current_state <= S_INIT;
            else
                current_state <= next_state;
        end // state_FFS

endmodule // control