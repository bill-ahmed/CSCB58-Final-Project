// Part 2 skeleton

module Motion_Pong
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        SW,
        HEX0,
        HEX2,
		HEX4,
		HEX5,
		GPIO,
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

	inout [35:0] GPIO;


    output [6:0] HEX0, HEX2, HEX4, HEX5;
	wire [9:0] sensor_1, sensor_2;


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
    wire ld_bx, ld_by;
	wire ld_p1x, ld_p1y;
	wire ld_p2x, ld_p2y;

    // counter wires
    wire en_B_shapeCounter_D, en_B_shapeCounter_E;
	wire en_P1_shapeCounter_D, en_P1_shapeCounter_E;
	wire en_P2_shapeCounter_D, en_P2_shapeCounter_E;
	wire en_delayCounter;

    // helper wires
    wire fin_B_D, fin_B_E;
	wire fin_P1_D, fin_P1_E;
	wire fin_P2_D, fin_P2_E;
	wire fin_Wait;
	wire [1:0] sel_out, sel_col;

    // instantiate a control module
    Control control0(
        .clock(CLOCK_50),
        .resetn(resetn),
        .go(SW[17]),

        .fin_B_D(fin_B_D),
		.fin_B_E(fin_B_E),

        .ld_bx_out(ld_bx),
        .ld_by_out(ld_by),

		.fin_P1_D(fin_P1_D),
		.fin_P1_E(fin_P1_E),

        .ld_p1x_out(ld_p1x),
        .ld_p1y_out(ld_p1y),

		.fin_P2_D(fin_P2_D),
		.fin_P2_E(fin_P2_E),

        .ld_p2x_out(ld_p2x),
        .ld_p2y_out(ld_p2y),

        .en_B_shapeCounter_D(en_B_shapeCounter_D),
		.en_B_shapeCounter_E(en_B_shapeCounter_E),

		.en_P1_shapeCounter_D(en_P1_shapeCounter_D),
		.en_P1_shapeCounter_E(en_P1_shapeCounter_E),

		.en_P2_shapeCounter_D(en_P2_shapeCounter_D),
		.en_P2_shapeCounter_E(en_P2_shapeCounter_E),

		.fin_Wait(fin_Wait),
        .en_delayCounter(en_delayCounter),

		.plot(writeEn),
		.sel_out(sel_out),
		.sel_col(sel_col),

        .HEX0(HEX0),
        .HEX2(HEX2)
    );

    // instantiate a datapath module
    Datapath datapath0(
        .clock(CLOCK_50),
        .resetn(resetn),

        .data(SW[17:0]),
		.sensor_1(sensor_1),
		.sensor_2(sensor_2),

		.sel_out(sel_out),
		.sel_col(sel_col),

        .ld_bx(ld_bx),
        .ld_by(ld_by),

		.ld_p1x(ld_p1x),
		.ld_p1y(ld_p1y),

		.ld_p2x(ld_p2x),
		.ld_p2y(ld_p2y),

        .en_B_shapeCounter_D(en_B_shapeCounter_D),
		.en_B_shapeCounter_E(en_B_shapeCounter_E),

		.en_P1_shapeCounter_D(en_P1_shapeCounter_D),
		.en_P1_shapeCounter_E(en_P1_shapeCounter_E),

		.en_P2_shapeCounter_D(en_P2_shapeCounter_D),
		.en_P2_shapeCounter_E(en_P2_shapeCounter_E),

        .en_delayCounter(en_delayCounter),

        .x_out(x),
        .y_out(y),
		.colour_out(colour),

        .fin_Wait(fin_Wait),

        .fin_B_D(fin_B_D),
		.fin_B_E(fin_B_E),

		.fin_P1_D(fin_P1_D),
		.fin_P1_E(fin_P1_E),

		.fin_P2_D(fin_P2_D),
		.fin_P2_E(fin_P2_E)
    );

	 UltrasonicSensor mySensor(
        .CLOCK_50(CLOCK_50),
        .GPIO(GPIO[35:0]),
        .sensor_1(sensor_1),
        .sensor_2(sensor_2),
    );

	Hex_display hd4(
        .IN(sensor_1),
        .OUT(HEX4)
    );

	Hex_display hd5(
        .IN(sensor_2),
        .OUT(HEX5)
    );

endmodule