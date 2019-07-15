module Datapath(clock, resetn,
                
                data,
                
                ld_x,
                ld_y,
                sel_col, 
                
                enable_posCounter_W,
                enable_posCounter_B,
                enable_delayCounter,
                
                x_out,
                y_out,
                colour_out,

                waited,
                doneW,
                doneB);

/* ------------- INPUT SIGNALS ------------- */

    /* FROM DE2 BOARD */
    input clock, resetn;
    input [9:0] data;

    /* FROM CONTROL MODULE */
    input ld_x, ld_y, sel_col;
    input ld_p1x, ld_p1y;
    input enable_posCounter_W, enable_posCounter_B;
    input enable_delayCounter;

/* ----------- END INPUT SIGNALS ----------- */

/* ------------- OUTPUT SIGNALS ------------- */

    /* TO VGA_Adapter */
    output reg [2:0] colour_out;
    output [9:0] x_out;
	output [9:0] y_out;

    /* TO Control Module */
    output waited, doneW, doneB;

/* ----------- END OUTPUT SIGNALS ----------- */

    // registers for counters
    reg [27:0] delayCounter;
    reg [3:0] posCounter_W;
    reg [3:0] posCounter_B;
    reg [9:0] x_pos;
    reg [9:0] y_pos;
    reg x_dir;
    reg y_dir;

    // registes for paddle counter

    // normal register
    reg [9:0] x_reg;    // Store the original x position of the ball
	reg [9:0] y_reg;    // Store the original y position of the ball

    // All Wires
    // Datapath to Control wires
    wire doneW;         // Determines whether the postion counter for white is finished
    wire doneB;         // Determines whether the postion counter for black is finished
    wire waited;        // Determines whether the delay counter is finshed

    // Internal Wires
    wire up_x, up_y;

    // helper assignments
    assign doneW = (posCounter_W == 4'd15) ? 1 : 0;
    assign doneB = (posCounter_B == 4'd15) ? 1 : 0;
    assign waited = (delayCounter == 28'd0) ? 1 : 0;
    assign up_x = doneB;
    assign up_y = doneB;
 
// ------------- COUNTERS ------------- //
    // 1. POSITION Counter
    /* 
        The counter helps to draw a shape by adding
        to the existing x and y value.
    */
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            posCounter_W <= 4'b0000;
        else if(enable_posCounter_W == 1'b1)
            posCounter_W <= posCounter_W + 1'b1;
        else if(enable_posCounter_B == 1'b1)
            posCounter_B <= posCounter_B + 1'b1;
    end

    // 2. DELAY Counter
    /* 
        The Counter counts down from a value which
        is exactly 1/60th of a second.

        Value = 20'd833333 - 1'b1
    */
    always @(posedge clock)
    begin
        if(delayCounter == 28'd0)
            delayCounter <= 28'd833333 - 1'b1;
        else if(enable_delayCounter == 1'b1)
            delayCounter <= delayCounter - 1'b1;
    end

    // X position
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            x_pos <= 6'd0;
        else if((up_x == 1'b1) & (x_dir == 1'b1))
            x_pos <= x_pos + 1'b1;
        else if((up_x == 1'b1) & (x_dir == 1'b0))
            x_pos <= x_pos - 1'b1;
    end

    // Y position
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            y_pos <= 6'd0;
        else if((up_y == 1'b1) & (y_dir == 1'b1))
            y_pos <= y_pos + 1'b1;
        else if((up_y == 1'b1) & (y_dir == 1'b0))
            y_pos <= y_pos - 1'b1;
    end
    
// ----------- END COUNTERS ----------- //

// ------------- REGISTERS ------------- //

	// register for x
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            x_reg <= 8'd0;
        else if(ld_x == 1'b1)
            x_reg <= 8'd0;
    end

    // register for y
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            y_reg <= 7'd0;
        else if(ld_y == 1'b1)
            y_reg <= 7'd0;
    end

    always @(posedge clock)
    begin
        if(x_out == 10'd0)
            x_dir <= 1'b1;
        else if(x_out == 10'd636)
            x_dir <= 1'b0;
    end

    always @(posedge clock)
    begin
        if(y_out == 10'd0)
            y_dir <= 1'b1;
        else if(y_out == 10'd476)
            y_dir <= 1'b0;
    end

// ----------- END REGISTERS ----------- //

    // assign the actual output
    // assing the colour based on the select key
    always @(*)
		begin
			case (sel_col)
				1'b0: colour_out = data[9:7];
				1'b1: colour_out = 3'b000;
			endcase
		end

    assign x_out = x_reg + posCounter_W[1:0] + posCounter_B[1:0] + x_pos;
	assign y_out = y_reg + posCounter_W[3:2] + posCounter_B[3:2] + y_pos;
endmodule // datapath