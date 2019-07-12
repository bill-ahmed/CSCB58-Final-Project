module Datapath(clock, resetn,
                
                data,
                
                ld_x, ld_y, sel_col, 
                
                enable_posCounter, enable_waitCounter,
                
                x_out, y_out, colour_out,

                waited, done);

    // absolute input signals
    input clock, resetn;

    // dynamic input signals
    input [9:0] data;
    input ld_x, ld_y, sel_col;
    input enable_posCounter, enable_waitCounter;

    // output signals
    output reg [2:0] colour_out;
    output [7:0] x_out;
	output [6:0] y_out;
    output waited, done;

    // registers for counters
    reg [27:0] waitCounter;
    reg [3:0] posCounter;
    reg x_pos;

    // normal register
    reg [7:0] x_reg;
	reg [6:0] y_reg;

    // wires
    wire waited, done;
    // internal
    wire up_x;

    // helper assignments
    assign done = (posCounter == 4'd15) ? 1 : 0;
    assign up_x = (waitCounter == 28'd0) ? 1 : 0;
    assign waited = (waitCounter == 28'd0) ? 1 : 0;

// ------------- COUNTERS ------------- //
    // position Counter
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            posCounter <= 4'b0000;
        else if(enable_posCounter == 1'b1)
            posCounter <= posCounter + 1'b1;
    end

    // wait Counter
    always @(posedge clock)
    begin
        if(waitCounter == 28'd0)
            waitCounter <= 28'd50000000 - 1'b1;
        else if(enable_waitCounter == 1'b1)
            waitCounter <= waitCounter - 1'b1;
    end

    // X position
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            x_pos <= 1'd0;
        else if(up_x == 1'b1)
            x_pos <= x_pos + 1'b1;
    end
    
// ----------- END COUNTERS ----------- //

// ------------- REGISTERS ------------- //

	// register for x
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            x_reg <= 8'd0;
        else if(ld_x == 1'b1)
            //x_reg <= {1'b0,data[6:0]};
            x_reg <= 8'd15;
    end

    // register for y
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            y_reg <= 7'd0;
        else if(ld_y == 1'b1)
            //y_reg <= data[6:0];
            y_reg <= 7'd15;
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

    assign x_out = x_reg + posCounter[1:0] + x_pos;
	assign y_out = y_reg + posCounter[3:2];
endmodule // datapath