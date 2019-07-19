module Paddles(CLOCK_50, CLOCK_25, SW, VGA_CLK, VGA_HS, VGA_VS, 
                    VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B, 
                    HEX0, HEX1, HEX4, HEX5, KEY, GPIO);

    input CLOCK_50;
    input CLOCK_25;
    input [17:0] SW;
    input [3:0] KEY;

    inout [35:0] GPIO;

    output VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N;

    output [6:0] HEX0;
    output [6:0] HEX1;
    output [6:0] HEX4;
    output [6:0] HEX5;

    output [9:0] VGA_R;
    output [9:0] VGA_G;
    output [9:0] VGA_B;

    reg [6:0] x_cor;
    reg [6:0] x_cor_2;
    reg [6:0] y_cor_1 = 7'd15;
    reg [6:0] y_cor_2 = 7'd15;

    reg [6:0] x_prev_cor;
    reg [6:0] y_prev_cor;

    reg [6:0] plot_x;
    reg [6:0] plot_y;
    reg [6:0] plot_y_2;

    reg [3:0] counter_1;
    reg [3:0] counter_2;
    reg muxCounter;

    reg [2:0] colour;

    wire [27:0] rateDividerOutput;
    wire [27:0] regOut;
    wire [12:0] sensor_1;
    wire [12:0] sensor_2;
    wire plot;
    wire move;

    UltrasonicSensor mySensor(
        .CLOCK_50(CLOCK_50),
        .GPIO(GPIO[35:0]),
        .sensor_1(sensor_1),
        .sensor_2(sensor_2),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );
// 
    RateDivider r1(
        .clock(CLOCK_50),
        .MuxSelect(2'b00),  // Speed that both paddles move at
        .RateDividerOUT(rateDividerOutput)
    );

    register myReginald(
        .in(rateDividerOutput), 
        .reset_n(SW[17]),
        .clock(CLOCK_50),
        .out(regOut)
    );

    assign plot = (counter_1 == 2'b00) ? 1 : 0;
    assign move = (regOut == 27'b0) ? 1 : 0;    // Enable movement of paddles

    /*********** Draw the paddle 1 ***********/
    always @(posedge CLOCK_50)
    begin
        // y_cor_1 <= sensor_1;
        // y_cor_2 <= sensor_2;
        if(muxCounter == 1'b0)
        begin
            if(counter_1 < 4'd4)  // Black rectangle above the paddle
            begin
                colour <= 3'b000;
                plot_y <= y_cor_1 + counter_1;
                counter_1 <= counter_1 + 1'b1;
                plot_x <= 7'd0;
            end

            else if(4'd10 < counter_1)    // Black rectangle after the paddle
            begin
                colour <= 3'b000;
                plot_y <= y_cor_1 + counter_1;
                counter_1 <= counter_1 + 1'b1;
                plot_x <= 7'd0;
            end

            else                        // Actual white rectangle we want to draw
            begin
                colour <= 3'b111;
                plot_y <= y_cor_1 + counter_1;
                counter_1 <= counter_1 + 1'b1;
                plot_x <= 7'd0;
            end
        end

        else
        begin
            /**Paddle 2*/
            if(counter_2 < 7'd60)  // Black rectangle above the paddle
            begin
                colour <= 3'b000;
                plot_y <= y_cor_2 + counter_2;
                counter_2 <= counter_2 + 1'b1;
                plot_x <= 7'd100;
            end

            else if(7'd71 < counter_2)    // Black rectangle after the paddle
            begin
                colour <= 3'b000;
                plot_y <= y_cor_2 + counter_2;
                counter_2 <= counter_2 + 1'b1;
                plot_x <= 7'd100;
            end

            else                        // Actual white rectangle we want to draw
            begin
                colour <= 3'b111;
                plot_y <= y_cor_2 + counter_2;
                counter_2 <= counter_2 + 1'b1;
                plot_x <= 7'd100;
            end
        end
        muxCounter <= muxCounter + 1'b1;
    end

    always @(posedge move)
    begin
        if(muxCounter == 1'b0)
        begin
            if((y_cor_1 + 7'd12 < 7'd100))
            begin
                //y_cor_1 <= y_cor_1 + 1'b1;
                y_cor_1 <= sensor_1;
            end
            if((y_cor_1 > 7'd0))
            begin
                //y_cor_1 <= y_cor_1 - 1'b1;
                y_cor_1 <= sensor_1;
            end
        end
        
        else
        begin
            /*Paddle 2*/
            if((y_cor_2 + 7'd12 < 7'd100))
            begin
                y_cor_2 <= sensor_2;
            end
            if((y_cor_2 > 7'd0))
            begin
                y_cor_2 <= sensor_2;
            end
        end
    end

    vga_adapter VGA(
			.resetn(SW[17]),
			.clock(CLOCK_50),
			.colour(colour),
			.x(plot_x),
			.y(plot_y),
			.plot(1'b1),
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

    // Hex_display hex0(
    //     .IN(SW[3:0]),
    //     .OUT(HEX0)
    // );  

    // Hex_display hex2(
    //     .IN(SW[7:4]),
    //     .OUT(HEX2)
    // );

    // Hex_display hex4(
    //     .IN({3'd0, plot}),
    //     .OUT(HEX4)
    // );  

endmodule

/*A module to control flashing rates (in seconds) based on pre-defined number of cycles to run*/
module RateDivider(clock, MuxSelect, RateDividerOUT);
    input clock;
    input [1:0] MuxSelect;

    output reg [27:0] RateDividerOUT;

    // Based on MuxSelect, choose what value the register should count-down from
    always @(*)
    begin
        case (MuxSelect [1:0])
            2'b00: RateDividerOUT = 28'd1000000; // Clocked at 50MHz, return 0 after one cycle
            2'b01: RateDividerOUT = 28'd1; // Clocked at 50 Mhz, return 0 after 1 second (50 million cycles)
            2'b10: RateDividerOUT = 28'd3000000; // Clocked at 0.5Hz, return 0 after 2 seconds (100 million cycles)
            2'b11: RateDividerOUT = 28'b1011111010111100001000000000; // Clocked at 0.25Hz, return 0 after 4 second (200 million cycles)
            default: RateDividerOUT = 28'b0000000000000000000000000000; //default case, return 0
        endcase
    end
endmodule

/*A module to represent flip flop*/
module register(in, reset_n, clock, out);
    input [27:0] in;
    input reset_n;
    input clock;
    output [27:0] out;

    reg [27:0] out;

    always @(posedge clock)
    begin
        if(out == 1'b0)
            out <= in; // "out" is initially 0, set it to the input number
        else
            out <= out - 1'b1; // Subtract 1 from current value
    end

endmodule