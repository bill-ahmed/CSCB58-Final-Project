// Part 2 skeleton

module lab_6c
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	
	// Declare your inputs and outputs here
	input   [17:0]  SW;
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = SW[15];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;
	wire startCount;
	wire waitCount;
    wire waitWire, safeWire, ld_x, ld_y, clr_c;

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.
    /*reg [6:0] x_reg;
	wire ld_x;

	assign ld_x = SW[17];
	assign colour = SW[9:7];
	//assign writeEn = SW[16];
	assign y = SW[6:0];
	assign x = {1'b0, x_reg};

	always @(posedge ld_x)
	begin
		if(resetn == 1'b0)
			x_reg <= 0;
		else
			x_reg <= SW[6:0];
	end*/

    // Instansiate datapath
	 datapath d0(
		 .draw(startCount),
		 .waitCounter(waitCount),
		 .clock(CLOCK_50),
		 .ld_x(ld_x),
         .ld_y(ld_y),
		 .sel_col(clr_c),
		 .data_in(SW[9:0]),
		 .x_out(x),
		 .y_out(y),
		 .resetn(resetn),
		 .colour_out(colour),
         .safe_wire(safeWire),
		 .wait_wire(waitWire)
	 );

    // Instansiate FSM control
     control c0(
		 .clk(CLOCK_50),
		 .resetn(resetn),
		 .ld_x(SW[17]),
         .safe(safeWire),
		 .plot(writeEn),
		 .enable_counter(startCount),
		 .wait_counter(waitCount),
		 .sWait(waitWire),
         .ld_x_out(ld_x),
         .ld_y_out(ld_y),
		 .colour(clr_c)
		 );

endmodule


module control(
    input clk,
    input resetn,
    input ld_x,
    input safe,
	input sWait,

    output reg plot, ld_x_out, ld_y_out,
	output reg enable_counter, wait_counter, colour
    );

	reg [5:0] current_state, next_state; 

	localparam  S_LOAD_X = 5'd0,
				S_LOAD_X_WAIT = 5'd1,
                S_LOAD_Y = 5'd2,
				S_LOAD_Y_WAIT = 5'd3,
                S_PLOT_WAIT = 5'd4,
				S_PLOT = 5'd5,
				S_WAIT = 5'd5,
				S_DELETE = 5'd6;

	// Next state logic aka our state table
    always@(*)
    begin: state_table 
            case (current_state)
                S_LOAD_X: next_state = ld_x ? S_LOAD_X_WAIT: S_LOAD_X;// Loop in current state until value is input
				S_LOAD_X_WAIT: next_state = ld_x ? S_LOAD_X_WAIT : S_LOAD_Y;
                S_LOAD_Y: next_state = ld_x ? S_LOAD_Y_WAIT: S_LOAD_Y;
				S_LOAD_Y_WAIT: next_state = ld_x ? S_LOAD_Y_WAIT : S_PLOT_WAIT;
                S_PLOT: next_state = safe ? S_WAIT : S_PLOT;
				S_WAIT: next_state = sWait ? S_DELETE : S_WAIT;
				S_DELETE: next_state = safe ? S_LOAD_X : S_DELETE;

            default: next_state = S_LOAD_X;
        endcase
    end // state_table

	 // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
		plot = 1'b0;
		enable_counter = 1'b0;
		
		case(current_state)
			S_LOAD_X: begin
				plot = 1'b0;
				colour = 1'b0;
                ld_x_out = 1'b1;
                ld_y_out = 1'b0;
				wait_counter = 1'b1;
				enable_counter = 1'b0;
			end
			S_LOAD_Y: begin
				plot = 1'b0;
				colour = 1'b0;
                ld_x_out = 1'b0;
                ld_y_out = 1'b1;
				wait_counter = 1'b0;
				enable_counter = 1'b0;
            end
            S_PLOT_WAIT: begin
                plot = 1'b1;
				colour = 1'b0;
                ld_x_out = 1'b0;
                ld_y_out = 1'b0;
				wait_counter = 1'b0;
				enable_counter = 1'b1;
            end
			S_WAIT: begin
				plot = 1'b0;
				colour = 1'b0;
				ld_x_out = 1'b0;
                ld_y_out = 1'b0;
				wait_counter = 1'b1;
				enable_counter = 1'b0;
			end
			S_DELETE: begin
				plot = 1'b1;
				colour = 1'b1;
				ld_x_out = 1'b0;
                ld_y_out = 1'b0;
				enable_counter = 1'b1;
				wait_counter = 1'b0;
			end

			
			
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

	// current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_LOAD_X;
        else
            current_state <= next_state;
    end // state_FFS

endmodule

module datapath(draw, clock, ld_x, ld_y, sel_col, data_in, waitCounter, resetn, x_out, y_out, colour_out, safe_wire, wait_wire);
    input clock, draw, resetn, ld_x, ld_y, waitCounter, sel_col;
	input [9:0] data_in;

    output [7:0] x_out;
	output [6:0] y_out;
	output reg [2:0] colour_out;
    output safe_wire, wait_wire;
	
	reg [3:0] posCounter;
	reg [27:0] wCounter;
	reg [24:0] dCounter;
	reg [3:0] fCounter;
	reg [7:0] x_reg;
	reg [6:0] y_reg;
 
    wire safe_wire, wait_wire;
    assign safe_wire = (posCounter == 4'd15) ? 1 : 0;
	assign wait_wire = (wCounter == 28'd0) ? 1 : 0;


// ------------- COUNTERS ------------- //

	// position Counter
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            posCounter <= 4'b0000;
        else if(draw == 1'b1)
            posCounter <= posCounter + 1'b1;
    end

	// wait counter
	always @(posedge clock)
    begin
        if(wCounter == 28'd0)
            wCounter <= 28'd100000000 - 1'b1;           
        else if(waitCounter == 1'b1)
            wCounter <= wCounter - 1'b1;
    end

	// delay counter
	always @(posedge clock)
    begin
        if(dCounter == 25'd0)
            dCounter <= 25'd833333;           
        else
            dCounter <= dCounter - 1'b1;
    end

	wire fCount;
	assign fCount = dCounter == 25'b0 ? 1 : 0;

	// frame counter
	 always @(posedge clock)
    begin
        if(resetn == 1'b0)
            fCounter <= 4'b0000;
        else if(fCount == 1'b1)
            fCounter <= fCounter + 1'b1;
    end


// ------------- REGISTERS ------------- //

	// register for x
    always @(posedge ld_x)
    begin
        if(resetn == 1'b0)
            x_reg <= 8'd0;
        else if(ld_x == 1'b1)
            x_reg <= {1'b0,data_in[6:0]};
    end

    // register for y
    always @(posedge ld_y)
    begin
        if(resetn == 1'b0)
            y_reg <= 7'd0;
        else if(ld_y == 1'b1)
            y_reg <= data_in[6:0];
    end

// ------------- END REGISTERS ------------- //

// ------------- MUX ------------- //
	always @(*)
		begin
			case (sel_col)
				1'b0: colour_out = data_in[9:7];
				1'b1: colour_out = 3'b000;
			endcase
		end

	assign x_out = x_reg + posCounter[1:0];
	assign y_out = y_reg + posCounter[3:2];
endmodule // datapath


module hex_decoder(hex_digit, segments);
    input [3:0] hex_digit;
    output reg [6:0] segments;
   
    always @(*)
        case (hex_digit)
            4'h0: segments = 7'b100_0000;
            4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
        endcase
endmodule
