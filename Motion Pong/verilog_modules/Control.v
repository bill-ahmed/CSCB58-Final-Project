module Control( clock,
                resetn,
                go,

                doneW,
                doneB,
                waited,

                plot,
                ld_x_out,
                ld_y_out,

                enable_posCounter_W,
                enable_posCounter_B,
                enable_delayCounter,
                sel_col,

                HEX0,
                HEX2);
    // absolute input signals
    input clock, resetn, go;

    // dynamic input singnals
    input waited, doneW, doneB;

    // ouput signals
    output reg plot, ld_x_out, ld_y_out;
    output reg enable_posCounter_W, enable_posCounter_B;
    output reg enable_delayCounter, sel_col;
    output [6:0] HEX0, HEX2;

    // declare registers for the FSM
    reg [5:0] current_state, next_state;

    Hex_display hd1(
        .IN(current_state[3:0]),
        .OUT(HEX0)
    );

    Hex_display hd2(
        .IN(next_state[3:0]),
        .OUT(HEX2)
    );

    // assign the states a value
    localparam  S_INIT = 5'd0,
                S_LOAD_WAIT = 5'd1,
				S_LOAD = 5'd2,
                S_PLOT_WAIT = 5'd3,
                S_PLOT = 5'd4,
                S_WAIT_WAIT = 5'd5,
                S_WAIT = 5'd6,
                S_DELETE_WAIT = 5'd7,
                S_DELETE = 5'd8,
                S_DONE = 5'd9,

                S_PLOT_WAIT_PADDLE1 = 5'd10;
                S_PLOT_PADDLE1 = 5'd11;
                S_WAIT_WAIT_PADDLE1 = 5'd12;
                S_WAIT_PADDLE1 = 5'd13;
                S_DELETE_WAIT_PADDLE1 = 5'd14;
                S_DELETE_PADDLE1 = 5'd15;

                S_PLOT_WAIT_PADDLE2 = 5'd16;
                S_PLOT_PADDLE2 = 5'd17;
                S_WAIT_WAIT_PADDLE2 = 5'd18;
                S_WAIT_PADDLE2 = 5'd19;
                S_DELETE_WAIT_PADDLE2 = 5'd20;
                S_DELETE_PADDLE2 = 5'd21;

    // state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_INIT: next_state = go ? S_LOAD_WAIT : S_INIT;
                S_LOAD_WAIT: next_state = S_LOAD;
                S_LOAD: next_state = S_PLOT_WAIT_PADDLE1;

                
                S_PLOT_WAIT_PADDLE1: next_state = S_PLOT_PADDLE1;
                S_PLOT_PADDLE1: next_state = paddle1W ? S_WAIT_WAIT_PADDLE1 : S_PLOT_PADDLE1;
                S_WAIT_WAIT_PADDLE1: next_state = S_WAIT_PADDLE1;
                S_WAIT_PADDLE1: next_state = waitedP1 ? S_DELETE_WAIT_PADDLE1 : S_WAIT_PADDLE1;
                S_DELETE_WAIT_PADDLE1: next_state = S_DELETE_PADDLE1;
                S_DELETE_PADDLE1: next_state = paddle1B ? S_PLOT_WAIT : S_DELETE_PADDLE1;



                S_PLOT_WAIT: next_state = S_PLOT;
                S_PLOT : next_state = doneW ? S_WAIT_WAIT : S_PLOT;
                S_WAIT_WAIT: next_state = S_WAIT;
                S_WAIT: next_state = waited ? S_DELETE_WAIT : S_WAIT;
                S_DELETE_WAIT: next_state = S_DELETE;
                S_DELETE: next_state = doneB ? S_DONE : S_DELETE;
                S_DONE: next_state = go ? S_PLOT_WAIT : S_INIT;
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
                sel_col = 1'b0;
                ld_x_out = 1'b0;
                ld_y_out = 1'b0;
				enable_posCounter_W = 1'b0;
                enable_posCounter_B = 1'b0;
                enable_delayCounter = 1'b0;
			end
			S_LOAD_WAIT: begin
				plot = 1'b0;
                sel_col = 1'b0;
                ld_x_out = 1'b1;
                ld_y_out = 1'b1;
				enable_posCounter_W = 1'b0;
                enable_posCounter_B = 1'b0;
                enable_delayCounter = 1'b0;
            end
            S_LOAD: begin
                plot = 1'b0;
                sel_col = 1'b0;
                ld_x_out = 1'b0;
                ld_y_out = 1'b0;
                enable_posCounter_W = 1'b0;
                enable_posCounter_B = 1'b0;
                enable_delayCounter = 1'b0;
            end
            S_PLOT_WAIT: begin
                plot = 1'b1;
                sel_col = 1'b0;
                ld_x_out = 1'b0;
                ld_y_out = 1'b0;
                enable_posCounter_W = 1'b1;
                enable_posCounter_B = 1'b0;
                enable_delayCounter = 1'b0;
            end
            S_PLOT: begin
                plot = 1'b1;
                sel_col = 1'b0;
                ld_x_out = 1'b0;
                ld_y_out = 1'b0;
                enable_posCounter_W = 1'b1;
                enable_posCounter_B = 1'b0;
                enable_delayCounter = 1'b0;
            end
            S_WAIT_WAIT: begin
                plot = 1'b0;
                sel_col = 1'b0;
                ld_x_out = 1'b0;
                ld_y_out = 1'b0;
                enable_posCounter_W = 1'b0;
                enable_posCounter_B = 1'b0;
                enable_delayCounter = 1'b1;
            end
            S_WAIT: begin
                plot = 1'b0;
                sel_col = 1'b0;
                ld_x_out = 1'b0;
                ld_y_out = 1'b0;
                enable_posCounter_W = 1'b0;
                enable_posCounter_B = 1'b0;
                enable_delayCounter = 1'b1;
            end
            S_DELETE_WAIT: begin
                plot = 1'b1;
                sel_col = 1'b1;
                ld_x_out = 1'b0;
                ld_y_out = 1'b0;
                enable_posCounter_W = 1'b0;
                enable_posCounter_B = 1'b1;
                enable_delayCounter = 1'b0;
            end
            S_DELETE: begin
                plot = 1'b1;
                sel_col = 1'b1;
                ld_x_out = 1'b0;
                ld_y_out = 1'b0;
                enable_posCounter_W = 1'b0;
                enable_posCounter_B = 1'b1;
                enable_delayCounter = 1'b0;
            end
            S_DONE: begin
                plot = 1'b0;
                sel_col = 1'b0;
                ld_x_out = 1'b0;
                ld_y_out = 1'b0;
                enable_posCounter_W = 1'b0;
                enable_posCounter_B = 1'b0;
                enable_delayCounter = 1'b0;
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