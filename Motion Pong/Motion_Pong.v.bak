// Part 2 skeleton

module Motion_Pong
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        SW,
        HEX0,
        HEX2,
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

    output [6:0] HEX0, HEX2;


	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0];
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = SW[15];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

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
    
    // Instantiate the wires between the control and datapath
    // register wires
    wire ld_x, ld_y;

    // counter wires
    wire enable_posCounter, enable_waitCounter;

    // helper wires
    wire waited, done, sel_col;

    // instantiate a control module
    control control0(
        .clock(CLOCK_50),
        .resetn(resetn),
        .go(SW[17]),

        .done(done),
        .waited(waited),

        .plot(writeEn),
        .ld_x_out(ld_x),
        .ld_y_out(ld_y),
        .sel_col(sel_col),
        .enable_posCounter(enable_posCounter),
        .enable_waitCounter(enable_waitCounter),

        .HEX0(HEX0),
        .HEX2(HEX2)
    );

    // instantiate a datapath module
    datapath datapath0(
        .clock(CLOCK_50),
        .resetn(resetn),

        .data(SW[9:0]),
        .ld_x(ld_x),
        .ld_y(ld_y),
        .sel_col(sel_col),
        .enable_posCounter(enable_posCounter),
        .enable_waitCounter(enable_waitCounter),

        .x_out(x),
        .y_out(y),
        .done(done),
        .waited(waited),
        .colour_out(colour)
    );
endmodule