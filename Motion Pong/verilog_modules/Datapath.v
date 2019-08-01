module Datapath(clock,
                resetn,
                gameSpeed,
                
                HEX0,
                HEX2,

                ld_Val,

                data,
                sensor_1,
                sensor_2,

                sel_out,
                sel_col,
                sel_text,

                en_reset_player_scores,
                en_clr_scr,

                en_B_shapeCounter_D,
                en_B_shapeCounter_E,

                en_P1_shapeCounter_D,
                en_P1_shapeCounter_E,

                en_P2_shapeCounter_D,
                en_P2_shapeCounter_E,

                en_Score1,
                en_Score2,

                en_Text1,
                en_Text2,

                en_delayCounter,
                
                x_out,
                y_out,
                colour_out,

                fin_Wait,
                fin_clr_scr,

                fin_Text1,
                fin_Text2,
                fin_game,

                fin_S1_D,
                fin_S2_D,

                fin_P1_D,
                fin_P1_E,

                fin_P2_D,
                fin_P2_E,

                fin_B_D,
                fin_B_E);

/* ------------- INPUT SIGNALS ------------- */

    /* --  FROM THE DE2 BOARD -- */
        input clock;                // The clock signal.
        input resetn;               // The reset signal.

    /* -- FROM THE USER -- */
        input [27:0] gameSpeed;     // Determines the Speed at which the game is played.
        input [9:0] data;           // Data from the user about colours of the shape.
        input [9:0] sensor_1;       // Data from ultrasonic sensor 1.
        input [9:0] sensor_2;       // Data from ultrasonic sensor 2.

    /* -- FROM CONTROL MODULE -- */
        input [2:0] sel_out;            // Determines the shape to draw
        input [2:0] sel_col;            // Determines the colour of each shape
        input [4:0] sel_text;           // Determines the letter to draw
        input ld_Val;                   // Enable signal to load values
        input en_Score1;                // Enable signal to draw Score 1 
        input en_Score2;                // Enable signal to draw Score 2
        input en_Text1;                 // Enable signal to draw a letter
        input en_Text2;                 // Enable signal to draw a letter   
        input en_delayCounter;          // Enable signal for the delay.
        input en_B_shapeCounter_D;      // Enable signal to draw the Ball
        input en_B_shapeCounter_E;      // Enable signal to erase the Ball
        input en_P1_shapeCounter_D;     // Enable signal to draw Paddle 1
        input en_P1_shapeCounter_E;     // Enable signal to erase Paddle 1
        input en_P2_shapeCounter_D;     // Enable signal to draw Paddle 2
        input en_P2_shapeCounter_E;     // Enable signal to erase Paddle 2
        input en_reset_player_scores;   // Enable signal to reset the counters
        input en_clr_scr;               // Enable signal to clear the screen
 

/* ----------- END INPUT SIGNALS ----------- */

/* ------------- OUTPUT SIGNALS ------------- */

    /* TO VGA ADAPTER */
    output reg [2:0] colour_out;    // The Colour output to the VGA Adapter
    output reg [9:0] x_out;         // The X Coordinate of the shape to the VGA Adapter
	output reg [9:0] y_out;         // The Y Coordinate of the shape to the VGA Adapter

    /* TO THE CONTROL MODULE */
    output fin_B_D;					// Helper wire to determine whether the Ball has been drawn
    output fin_B_E;					// Helper wire to determine whether the Ball has been erased
    output fin_P1_D;				// Helper wire to determine whether the Paddle 1 has been drawn
    output fin_P1_E;				// Helper wire to determine whether the Paddle 1 has been erased
    output fin_P2_D;				// Helper wire to determine whether the Paddle 2 has been drawn
    output fin_P2_E;				// Helper wire to determine whether the Paddle 2 has been erased
    output fin_S1_D;				// Helper wire to determine whether the Score 1 has been drawn
    output fin_S2_D;				// Helper wire to determine whether the Score 2 has been drawn
    output fin_Wait;				// Helper wire to determine whether the waiting is finished
    output fin_game;				// Helper wire to determine whether the game is finished
    output fin_Text1;				// Helper wire to determine whether the a letter is drawn
    output fin_Text2;				// Helper wire to determine whether the a letter is drawn
    output fin_clr_scr;				// Helper wire to determine whether the screen is cleared

    /* TO THE HEX DISPLAY */
    output [6:0] HEX0;
    output [6:0] HEX2;

/* ----------- END OUTPUT SIGNALS ----------- */

/* --------------- VARIABLES --------------- */

    /* REGISTERS FOR GENERAL CONTROLS */
    reg player;                     // Helper wire to store the winning player
    reg [2:0] rainbow;              // Enable Rainbow mode
    reg [14:0] clr_scr;
    reg [27:0] rainCounter;         // Rate divider for raibow mode
    reg [27:0] delayCounter;
    reg [7:0] player_1_score;
    reg [7:0] player_2_score;

    /* REGISTERS FOR DRAWING AND ERASING */
    reg [5:0] Score1;
    reg [5:0] Score2;
    reg [5:0] Text1;
    reg [5:0] Text2;
    reg [1:0] B_shapeCounter_D;
    reg [1:0] B_shapeCounter_E;
    reg [3:0] P1_shapeCounter_D;
    reg [3:0] P1_shapeCounter_E;
    reg [3:0] P2_shapeCounter_D;
    reg [3:0] P2_shapeCounter_E;

    /* REGISTERS FOR DYNAMIC POSITIONS */
    reg [7:0] P1_Position;          // Store the position of the Paddle 1
    reg [7:0] P2_Position;          // Store the position of the Paddle 2
    reg [9:0] B_XposCounter;        // Store the X position of the Ball
    reg [9:0] B_YposCounter;        // Store the Y position of the Ball

    /* REGISTERS FOR DIRECTION */
    reg P1_dir;                     // Store the direction of Paddle 1
    reg P2_dir;                     // Store the direction of Paddle 2
    reg B_X_dir;                    // Store the direction of Ball's X direction
    reg B_Y_dir;                    // Store the direction of Ball's Y direction

    /* REGISTERS FOR ORIGINAL POSITIONS */
    reg [6:0] offset;
    reg [9:0] OG_B_x;               // Store the original X position of the ball
	reg [9:0] OG_B_y;               // Store the original Y position of the ball
    reg [9:0] OG_P1_x;              // Store the original X position of the ball
	reg [9:0] OG_P1_y;              // Store the original Y position of the ball
    reg [9:0] OG_P2_x;              // Store the original X position of the ball
	reg [9:0] OG_P2_y;              // Store the original Y position of the ball
    reg [9:0] OG_S1_x;              // Stores the original X position of the Score 1
    reg [9:0] OG_S1_y;              // Stores the original Y position of the Score 1
    reg [9:0] OG_S2_x;              // Stores the original X position of the Score 2
    reg [9:0] OG_S2_y;              // Stores the original Y position of the Score 2
    reg [9:0] PL_SPLASH_x;          // Stores the original X position of the Text
    reg [9:0] PL_SPLASH_y;          // Stores the original Y position of the Text

    /* ---------- WIRES ---------- */

    // DATAPATH To CONTROL WIRES
    wire fin_B_D;                   // Determines whether the Ball is drawn
    wire fin_B_E;                   // Determines whether the Ball is erased
    wire fin_P1_D;                  // Determines whether the Paddle 1 is drawn
    wire fin_P1_E;                  // Determines whether the Paddle 1 is erased
    wire fin_P2_D;                  // Determines whether the Paddle 2 is drawn
    wire fin_P2_E;                  // Determines whether the Paddle 2 is erased
    wire fin_S1_D;                  // Determines whether the Score 1 is drawn
    wire fin_S2_D;                  // Determiens whether the Score 2 is drawn
    wire fin_Wait;                  // Determines whether the waiting is done
    wire fin_game;                  // Determines whether the game is finished
    wire fin_Text1;                 // Determines whether the letter is drawn
    wire fin_Text2;                 // Determines whether the letter is drawn
    wire fin_clr_scr;               // Determines whether the screen is cleareds

    // HELPER WIRES
    wire B_move;                    // Helper wire to determines whether the Ball is ready to move in the X direction
    wire P1_move;                   // Helper wire to determines whether the Paddle 1 is ready to move
    wire P2_move;                   // Helper wire to determines whether the Paddle 2 is ready to move
    wire en_rain;                   // Helper wire to enable to raibow mode
    wire en_offset;                 // Helper wire to determine the position of the final splash screen letters
    wire [3:0] colour_S1;           // Helper wire to store the colour date for VGA from player 1 score
    wire [3:0] colour_S2;           // Helper wire to store the colour date for VGA from player 2 score
    wire [3:0] colour_T1;           // Helper wire to store the colour date for VGA from player 1 score
    wire [3:0] colour_T2;           // Helper wire to store the colour date for VGA from player 1 score
    wire [6:0] hexValue_S1;         // Helper wire to store the score of player 1
    wire [6:0] hexValue_S2;         // Helper wire to store the score of player 2
    wire [34:0] textData_T1;        // Helper wire to store the text value for printing the splash screen
    wire [34:0] textData_T2;        // Helper wire to store the text value for printing the splash screen
    wire [34:0] pixelData_S1;       // Helper wire to store the score value for player 1 score
    wire [34:0] pixelData_S2;       // Helper wire to store the score value for player 2 score    


    // WIRE ASSIGNMENTS
    assign fin_B_D     = (B_shapeCounter_D == 2'd3) ? 1 : 0;
    assign fin_B_E     = (B_shapeCounter_E == 2'd3) ? 1 : 0;
    assign fin_P1_D    = (P1_shapeCounter_D == 4'd15) ? 1 : 0;
    assign fin_P1_E    = (P1_shapeCounter_E == 4'd15) ? 1 : 0;
    assign fin_P2_D    = (P2_shapeCounter_D == 4'd15) ? 1 : 0;
    assign fin_P2_E    = (P2_shapeCounter_E == 4'd15) ? 1 : 0;
    assign fin_Text1   = (Text1 == 6'd63) ? 1 : 0;
    assign fin_Text2   = (Text2 == 6'd63) ? 1 : 0;
    assign fin_S1_D    = (Score1 == 6'd63) ? 1 : 0;
    assign fin_S2_D    = (Score2 == 6'd63) ? 1 : 0;
    assign B_move      = fin_B_E;
    assign P1_move     = fin_P1_E;    
    assign P2_move     = fin_P2_E;
    assign fin_Wait    = (delayCounter == 28'd0) ? 1 : 0;
    assign fin_game    = ((player_1_score == 4'd10) | (player_2_score == 4'd10)) ? 1 : 0;
    assign fin_clr_scr = (clr_scr == 15'd32767) ? 1 : 0;
    assign en_offset   = (fin_Text1 == 1'b1 | fin_Text2 == 1'b1);
    assign en_rain     = (rainCounter == 28'd0) ? 1 : 0;

    // GENERAL COUNTERS
    always @(posedge clock)
    begin
        // GAME SPEED
        // Check if the delay reached 0 if so then reset it to the input game speed
        if(delayCounter == 28'd0)
            delayCounter <= gameSpeed ; 

        // Decrement the delay otherwise
        else if(en_delayCounter == 1'b1)
            delayCounter <= delayCounter - 1'b1;

        // CLEAR SCREEN
        // If enabled increment the counter
        if (en_clr_scr == 1'b1)
            clr_scr <= clr_scr + 1'b1;

        
        if(rainCounter == 28'd0)
            rainCounter <= 28'd12500000 - 1'b1;
        else       
            rainCounter <= rainCounter - 1'b1;
    end

/* ------------- BALL COUNTERS ------------- */
    // 1. SHAPE Counter
    /* 
        The counter helps to draw a shape by adding
        to the existing x and y value.
    */
    always @(posedge clock)
    begin
        // Increment the counter for drawing
        if(en_B_shapeCounter_D == 1'b1)
            B_shapeCounter_D <= B_shapeCounter_D + 1'b1;

        // Increment the counter for erasing
        if(en_B_shapeCounter_E == 1'b1)
            B_shapeCounter_E <= B_shapeCounter_E + 1'b1;
    end

    // 2. BALL - X POSITION Counter
    /* 
        The counter helps to move the ball around the
        screen in the x direction
    */
    always @(posedge clock)
    begin
        // Check if the game is finished
        if(en_reset_player_scores == 1'b1)
        begin
            // If so reset the scores
            player_1_score <= 8'd0;
            player_2_score <= 8'd0;
        end

        // Check if the Ball is able to move in the X direction
        if(B_move == 1'b1)
        begin
            // Depending on the stored direction vector, move the Ball to that dierction
            if(B_X_dir == 1'b1)
                B_XposCounter <= B_XposCounter + 1'b1;

            if(B_X_dir == 1'b0)
                B_XposCounter <= B_XposCounter - 1'b1;

            if(B_Y_dir == 1'b1)
                B_YposCounter <= B_YposCounter + 1'b1;

            if(B_Y_dir == 1'b0)
                B_YposCounter <= B_YposCounter - 1'b1;
        end

        // Check if a collision has occured between the Ball and the left Wall
        if(OG_B_x + B_XposCounter == OG_P1_x - 1'b1)
            begin
                // If so, reset only the X direction
                B_XposCounter <= 10'd0;

                // Increase the score of player 2
                player_2_score <= player_2_score + 1'b1;
            end
            
        // Check if a collision has occured between the Ball and the right Wall
        if(OG_B_x + B_XposCounter + 2'd2 == OG_P2_x + 1'b1)
            begin
                // If so, reset only the X direction
                B_XposCounter <= 10'd0; 

                // Increase the score of player 1
                player_1_score <= player_1_score + 1'b1;
            end
    end

/* ----------- END BALL COUNTERS ----------- */

/* ------------ PADDLE COUNTERS ------------ */
    // SHAPE COUNTER - Draws the Paddle
    always @(posedge clock)
    begin
        if(en_P1_shapeCounter_D == 1'b1)   
            P1_shapeCounter_D <= P1_shapeCounter_D + 1'b1; 

        if(en_P1_shapeCounter_E == 1'b1)
            P1_shapeCounter_E <= P1_shapeCounter_E + 1'b1;
    end

    // 2. PADDLE1 - Y POSITION Counter
    /* 
        The counter helps to move the ball around the
        screen in the x direction
    */
    always @(posedge clock)
    begin
        // set the position to 0 if the sensor is in the blind spot
        if((P1_move == 1'b1) & (sensor_1 < 7) & (P1_Position < 10'd0))
            P1_Position <= P1_Position - 1'b1;

        // While the paddle isn't being drawn over or at 120 pixels long, continue
        else if(OG_P1_y + P1_Position + 4'd15 < 10'd120)
        begin

            // If the user is moving their hand away from the sensor, move the paddle down
            if((P1_move == 1'b1) & (P1_Position < (sensor_1 - 2'd2) * 7) & (sensor_1 < 5'd30))

                if(((sensor_1 - 2'd2) * 7) - P1_Position > 80)
                    P1_Position <= P1_Position + 6'd40;

                else if(((sensor_1 - 2'd2) * 7) - P1_Position > 50)
                    P1_Position <= P1_Position + 5'd20;

                else if(((sensor_1 - 2'd2) * 7) - P1_Position > 20)
                    P1_Position <= P1_Position + 3'd4;

                else
                    P1_Position <= P1_Position + 2'd2;

            // Else if user is moving hand TOWARD the sensor, move it up
            else if((P1_move == 1'b1) & (P1_Position > (sensor_1 - 2'd2) * 7) & (sensor_1 < 5'd30))

                if(P1_Position - ((sensor_1 - 2'd2) * 7) > 80)
                    P1_Position <= P1_Position - 6'd40;

                else if(P1_Position - ((sensor_1 - 2'd2) * 7) > 50)
                    P1_Position <= P1_Position - 5'd20;

                else if(P1_Position - ((sensor_1 - 2'd2) * 7) > 20)
                    P1_Position <= P1_Position - 3'd4;

                else
                    P1_Position <= P1_Position - 1'b1;
        end
        
        // If the paddle is going to overflow, decrement it
        else if(OG_P1_y + P1_Position + 4'd15 >= 10'd120)
            P1_Position <= P1_Position - 1'b1;
        
    end    


// ---------- END PADDLE COUNTERS ---------- //

/* ------------ PADDLE2 COUNTERS ------------ */
    // 1. SHAPE Counter
    /* 
        The counter helps to draw a shape by adding
        to the existing x and y value.
    */
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            P2_shapeCounter_D <= 4'd0;
        else if(en_P2_shapeCounter_D == 1'b1)
            P2_shapeCounter_D <= P2_shapeCounter_D + 1'b1;
        else if(en_P2_shapeCounter_E == 1'b1)
            P2_shapeCounter_E <= P2_shapeCounter_E + 1'b1;
    end

    // 2. PADDLE1 - Y POSITION Counter
    /* 
        The counter helps to move the ball around the
        screen in the x direction
    */
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            P2_Position <= 10'd0;

        // Set the position to 0 if the sensor is in the blind spot
        if((P2_move == 1'b1) & (sensor_2 < 7) & (P2_Position < 10'd0))
            P2_Position <= P2_Position - 1'b1;

        // While the paddle isn't being drawn over or at 120 pixels long, continue
        else if(OG_P2_y + P2_Position + 4'd15 < 10'd120)
        begin
            // If the user is moving their hand AWAY from the sensor, move the paddle down
            if((P2_move == 1'b1) & (P2_Position < (sensor_2 - 2) * 7) & (sensor_2 < 5'd30))
            
                if(((sensor_2 - 2'd2) * 7) - P2_Position > 80)
                    P2_Position <= P2_Position + 6'd40;

                else if(((sensor_2 - 2'd2) * 7) - P2_Position > 50)
                    P2_Position <= P2_Position + 5'd20;

                else if(((sensor_2 - 2'd2) * 7) - P2_Position > 20)
                    P2_Position <= P2_Position + 3'd4;
                    
                else
                    P2_Position <= P2_Position + 1'b1;

            // Else if user is moving hand TOWARD the sensor, move it up
            if((P2_move == 1'b1) & (P2_Position > (sensor_2 - 2) * 7) & (sensor_2 < 5'd30))
            
                if(P2_Position - ((sensor_2 - 2'd2) * 7) > 80)
                    P2_Position <= P2_Position - 6'd40;

                else if(P2_Position - ((sensor_2 - 2'd2) * 7) > 50)
                    P2_Position <= P2_Position - 5'd20;

                else if(P2_Position - ((sensor_2 - 2'd2) * 7) > 20)
                    P2_Position <= P2_Position - 3'd4;

                else
                    P2_Position <= P2_Position - 1'b1;
        end

        // If the paddle is going to overflow, decrement it
        else if(OG_P2_y + P2_Position + 4'd15 >= 10'd120)
            P2_Position <= P2_Position - 1'b1;
    end    


// ---------- END PADDLE COUNTERS ---------- //

/* ---------- TEXT COUNTERS ------------ */

    always @(posedge clock)
    begin
        // Check if the Text Counter 1 is enabled
        if (en_Text1 == 1'b1)
            // If so increment it
            Text1 <= Text1 + 1'b1;
        
        // Check if the Text Counter 2 is enabled
        else if (en_Text2 == 1'b1)
            // If so increment it
            Text2 <= Text2 + 1'b1;
    end

    textToPixel tp1(
        .textValue(sel_text),
        .player(player),
        .pixelValue(textData_T1)
    );

    pixelDecoder pd3(
        .counterValue(Text1),
        .pixelData(textData_T1),
        .colour(colour_T1)
    );

    textToPixel tp2(
        .textValue(sel_text),
        .player(player),
        .pixelValue(textData_T2)
    );

    pixelDecoder pd4(
        .counterValue(Text2),
        .pixelData(textData_T2),
        .colour(colour_T2)
    );


/* ---------- SCORE COUNTERS ---------- */
 always @(posedge clock)
    begin
        if (en_Score1 == 1'b1)
            Score1 <= Score1 + 1'b1;

        else if (en_Score2 == 1'b1)
            Score2 <= Score2 + 1'b1;
    end

    hexToPixel hp1(
        .hexValue(hexValue_S1),
        .pixelValue(pixelData_S1)
    );

    pixelDecoder pd1(
        .counterValue(Score1),
        .pixelData(pixelData_S1),
        .colour(colour_S1)
    );

    hexToPixel hp2(
        .hexValue(hexValue_S2),
        .pixelValue(pixelData_S2)
    );

    pixelDecoder pd2(
        .counterValue(Score2),
        .pixelData(pixelData_S2),
        .colour(colour_S2)
    );

    /* OFFSET */
    always @(posedge clock)
    begin
        if(en_offset == 1'b1)
        begin
            if(offset > 7'd77)
                offset <= 7'd0;
            
            else if(offset == 7'd35)
                offset <= offset + 7'd10;

            else if(offset == 7'd45)
                offset <= offset + 7'd9;

            else
                offset <= offset + 7'd7;
        end
    end

    /* HELPER */
    always @(posedge clock)
    begin

        if(fin_game == 1'b1)
            player <= (player_2_score == 4'd10) ? 1 : 0;

        if(en_rain == 1'b1)

            if(rainbow == 3'd7)
                rainbow <= 3'd1;

            else
                rainbow <= rainbow + 1'b1;
    end

// ------------- REGISTERS ------------- //

    /* 
        STORING POSITIONS

        Stores the original positions of
        -> Ball
        -> Paddles.
    */
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
        begin
            OG_B_y <= 10'd0;    // Reset the Y Coordinate of the Ball
            OG_B_x <= 10'd0;    // Reset the X Coordinate of the Ball
            OG_P1_y <= 10'd0;   // Reset the Y Coordinate of the Paddle 1
            OG_P1_x <= 10'd0;   // Reset the X Coordinate of the Paddle 1
            OG_P2_y <= 10'd0;   // Reset the Y Coordinate of the Paddle 2
            OG_P2_x <= 10'd0;   // Reset the X Coordinate of the Paddle 2
        end
        else if(ld_Val == 1'b1)
        begin
            OG_B_y <= 10'd60;       // Store the Y Coordinate of the Ball
            OG_B_x <= 10'd80;       // Store the X Coordinate of the Ball
            OG_S1_y <= 10'd56;      // Store the Y Coordinate of the Score 1
            OG_S1_x <= 10'd6;       // Store the X Coordinate of the Score 1
            OG_S2_y <= 10'd56;      // Store the Y Coordinate of the Score 2
            OG_S2_x <= 10'd151;     // Store the X Coordinate of the Score 2
            OG_P1_y <= 10'd0;       // Store the Y Coordinate of the Paddle 1
            OG_P1_x <= 10'd15;      // Store the X Coordinate of the Paddle 1
            OG_P2_y <= 10'd0;       // Store the Y Coordinate of the Paddle 2
            OG_P2_x <= 10'd143;     // Store the X Coordinate of the Paddle 2
            PL_SPLASH_y <= 10'd35;  // Store the Y Coordinate of the "PLAYER" text
            PL_SPLASH_x <= 10'd40;  // Store the X Coordinate of the "PLAYER" text
        end
    end

    /* 
        COLLISION DETECTION 

        Determines whether a collision occured between the Ball
        and one of the following.
        -> Top Wall
        -> Bottom Wall
        -> Paddle 1
        -> Paddle 2
    */
    always @(posedge clock)
    begin
        // Check the collision against Paddle 1
        if((OG_B_x + B_XposCounter == OG_P1_x + 1'b1) & (OG_B_y + B_YposCounter + 1'b1 >= OG_P1_y + P1_Position) & (OG_B_y + B_YposCounter <= OG_P1_y + P1_Position + 4'd15))
            B_X_dir <= 1'b1;    // If collision change the X direction to right

        // Check the collision against Paddle 2
        else if((OG_B_x + B_XposCounter + 1'b1 == OG_P2_x - 1'b1) & (OG_B_y + B_YposCounter + 1'b1 >= OG_P2_y + P2_Position) & (OG_B_y + B_YposCounter <= OG_P2_y + P2_Position + 4'd15))
            B_X_dir <= 1'b0;    // If collision change the X direction to left

        // Check the collision against the Top wall
        else if(OG_B_y + B_YposCounter == 8'd0)
            B_Y_dir <= 1'b1;    // If collision change the Y direction to down
            
        // Check the collision against the Bottom wall
        else if(OG_B_y + B_YposCounter + 1'b1 == 8'd119)
            B_Y_dir <= 1'b0;    // If collision change the Y direction to up

        // Check the collision against the Left wall
        else if(OG_B_x + B_XposCounter == OG_P1_x - 1'b1)
            B_X_dir <= 1'b1;

        // Check the collision against the Right wall
        else if(OG_B_x + B_XposCounter + 2'd2 == OG_P2_x + 1'b1)
            B_X_dir <= 1'b0;
    end
// ----------- END REGISTERS ----------- // 

    // Determine the Colour Output of the Ball and the Paddles
    always @(*)
		begin
			case (sel_col)
				3'd0: colour_out = data[9:7];
				3'd1: colour_out = colour_S1;
                3'd2: colour_out = data[3:0];
                3'd3: colour_out = 3'd0;
                3'd4: colour_out = colour_S2;
                3'd5: colour_out = colour_T1;
                3'd6: colour_out = colour_T2;
                3'd7: colour_out = rainbow;
			endcase
		end
    // Determine the X Coordinate of the Ball and the Paddles
    always @(*)
        begin
            case (sel_out)
                3'd0: x_out = OG_B_x + B_shapeCounter_D[0] + B_shapeCounter_E[0] + B_XposCounter;
                3'd1: x_out = OG_P1_x;
                3'd2: x_out = OG_P2_x;
                3'd3: x_out = OG_S1_x + Score1[2:0];
                3'd4: x_out = OG_S2_x + Score2[2:0];
                3'd5: x_out = PL_SPLASH_x + offset + Text1[2:0];
                3'd6: x_out = PL_SPLASH_x + offset + Text2[2:0];
                3'd7: x_out = 8'd0 + clr_scr[7:0];
            endcase
        end

    // Determine the Y Coordinate of the ball and the Paddles
    always @(*)
        begin
            case (sel_out)
                3'd0: y_out = OG_B_y + B_shapeCounter_D[1] + B_shapeCounter_E[1] + B_YposCounter;
                3'd1: y_out = OG_P1_y + P1_shapeCounter_D + P1_shapeCounter_E + P1_Position;
                3'd2: y_out = OG_P2_y + P2_shapeCounter_D + P2_shapeCounter_E + P2_Position;
                3'd3: y_out = OG_S1_y + Score1[5:3];
                3'd4: y_out = OG_S2_y + Score2[5:3];
                3'd5: y_out = PL_SPLASH_y + Text1[5:3];
                3'd6: y_out = PL_SPLASH_y + Text2[5:3];
                3'd7: y_out = 7'd0 + clr_scr[14:8];
            endcase
        end

    /* Hex displays to show Player 1 and Player 2 scores */
    Hex_display player1ScorePart1(
        .IN(player_1_score[3:0]),
        .OUT(hexValue_S1)
    );

    Hex_display player1ScorePart2(
        .IN(player_1_score[3:0]),
        .OUT(HEX0)
    );    

    Hex_display player2ScorePart1(
        .IN(player_2_score[3:0]),
        .OUT(hexValue_S2)
    );

    Hex_display player2ScorePart2(
        .IN(player_2_score[3:0]),
        .OUT(HEX2)
    );

endmodule // datapath


module pixelDecoder(counterValue, pixelData, colour);

    input [5:0] counterValue;
    input [34:0] pixelData;

    output reg [2:0] colour;

    always @(*)
    begin
        case(counterValue)
            6'd0:  colour = pixelData[0]  == 1'b1 ? 3'd7 : 3'd0;
            6'd1:  colour = pixelData[1]  == 1'b1 ? 3'd7 : 3'd0;
            6'd2:  colour = pixelData[2]  == 1'b1 ? 3'd7 : 3'd0;
            6'd3:  colour = pixelData[3]  == 1'b1 ? 3'd7 : 3'd0;
            6'd4:  colour = pixelData[4]  == 1'b1 ? 3'd7 : 3'd0;

            6'd8:  colour = pixelData[5]  == 1'b1 ? 3'd7 : 3'd0;
            6'd9:  colour = pixelData[6]  == 1'b1 ? 3'd7 : 3'd0;
            6'd10: colour = pixelData[7]  == 1'b1 ? 3'd7 : 3'd0;
            6'd11: colour = pixelData[8]  == 1'b1 ? 3'd7 : 3'd0;
            6'd12: colour = pixelData[9]  == 1'b1 ? 3'd7 : 3'd0;

            6'd16: colour = pixelData[10] == 1'b1 ? 3'd7 : 3'd0;
            6'd17: colour = pixelData[11] == 1'b1 ? 3'd7 : 3'd0;
            6'd18: colour = pixelData[12] == 1'b1 ? 3'd7 : 3'd0;
            6'd19: colour = pixelData[13] == 1'b1 ? 3'd7 : 3'd0;
            6'd20: colour = pixelData[14] == 1'b1 ? 3'd7 : 3'd0;
    
            6'd24: colour = pixelData[15] == 1'b1 ? 3'd7 : 3'd0;
            6'd25: colour = pixelData[16] == 1'b1 ? 3'd7 : 3'd0;
            6'd26: colour = pixelData[17] == 1'b1 ? 3'd7 : 3'd0;
            6'd27: colour = pixelData[18] == 1'b1 ? 3'd7 : 3'd0;
            6'd28: colour = pixelData[19] == 1'b1 ? 3'd7 : 3'd0;

            6'd32: colour = pixelData[20] == 1'b1 ? 3'd7 : 3'd0;
            6'd33: colour = pixelData[21] == 1'b1 ? 3'd7 : 3'd0;
            6'd34: colour = pixelData[22] == 1'b1 ? 3'd7 : 3'd0;
            6'd35: colour = pixelData[23] == 1'b1 ? 3'd7 : 3'd0;
            6'd36: colour = pixelData[24] == 1'b1 ? 3'd7 : 3'd0;

            6'd40: colour = pixelData[25] == 1'b1 ? 3'd7 : 3'd0;
            6'd41: colour = pixelData[26] == 1'b1 ? 3'd7 : 3'd0;
            6'd42: colour = pixelData[27] == 1'b1 ? 3'd7 : 3'd0;
            6'd43: colour = pixelData[28] == 1'b1 ? 3'd7 : 3'd0;
            6'd44: colour = pixelData[29] == 1'b1 ? 3'd7 : 3'd0;

            6'd48: colour = pixelData[30] == 1'b1 ? 3'd7 : 3'd0;
            6'd49: colour = pixelData[31] == 1'b1 ? 3'd7 : 3'd0;
            6'd50: colour = pixelData[32] == 1'b1 ? 3'd7 : 3'd0;
            6'd51: colour = pixelData[33] == 1'b1 ? 3'd7 : 3'd0;
            6'd52: colour = pixelData[34] == 1'b1 ? 3'd7 : 3'd0;

            default: colour = 3'd0;
        endcase
    end

endmodule // pixelDecoder

module hexToPixel(hexValue, pixelValue);

    input [6:0] hexValue;

    output reg [34:0] pixelValue;

    always @(*)
    begin
        case(hexValue)
            7'b1000000: pixelValue = 35'b01110_10001_10011_10101_11001_10001_01110;   // Store data for the number 0
            7'b1111001: pixelValue = 35'b11111_00100_00100_00100_00100_00111_00100;   // Store data for the number 1
            7'b0100100: pixelValue = 35'b11111_00001_00010_00100_01000_10001_01110;   // Store data for the number 2
            7'b0110000: pixelValue = 35'b01110_10001_10000_01100_10000_10001_01110;   // Store data for the number 3
            7'b0011001: pixelValue = 35'b01000_01000_11111_01001_01010_01100_01000;   // Store data for the number 4
            7'b0010010: pixelValue = 35'b01111_10000_10000_01111_00001_00001_11111;   // Store data for the number 5
            7'b0000010: pixelValue = 35'b01110_10001_10001_01111_00001_10001_01110;   // Store data for the number 6
            7'b1111000: pixelValue = 35'b00100_00100_00100_00100_01000_10000_11111;   // Store data for the number 7
            7'b0000000: pixelValue = 35'b01110_10001_10001_01110_10001_10001_01110;   // Store data for the number 8
            7'b0011000: pixelValue = 35'b01110_10001_10000_11110_10001_10001_01110;   // Store data for the number 9
        endcase
    end
endmodule // hexToPixel

module textToPixel(textValue, player, pixelValue);

    input [4:0] textValue;
    input player;

    output reg [34:0] pixelValue;

    always @(*)
    begin
        case(textValue)
            5'd0:  pixelValue = 35'b10001_10001_11111_10001_10001_01010_00100;  // Store data for the letter A
            5'd1:  pixelValue = 35'b01111_10001_10001_01111_10001_10001_01111;  // Store data for the letter B
            5'd2:  pixelValue = 35'b01110_10001_00001_00001_00001_10001_01110;  // Store data for the letter C
            5'd3:  pixelValue = 35'b01111_10001_10001_10001_10001_10001_01111;  // Store data for the letter D
            5'd4:  pixelValue = 35'b11111_00001_00001_01111_00001_00001_11111;  // Store data for the letter E
            5'd5:  pixelValue = 35'b00001_00001_00001_01111_00001_00001_11111;  // Store data for the letter F
            5'd6:  pixelValue = 35'b01110_10001_10001_01101_00001_10001_01110;  // Store data for the letter G
            5'd7:  pixelValue = 35'b10001_10001_10001_11111_10001_10001_10001;  // Store data for the letter H
            5'd8:  pixelValue = 35'b11111_00100_00100_00100_00100_00100_11111;  // Store data for the letter I
            5'd9:  pixelValue = 35'b01110_10001_10000_10000_10000_10000_11111;  // Store data for the letter J
            5'd10: pixelValue = 35'b10001_10001_01001_00111_01001_10001_10001;  // Store data for the letter K
            5'd11: pixelValue = 35'b11111_00001_00001_00001_00001_00001_00001;  // Store data for the letter L
            5'd12: pixelValue = 35'b10001_10001_10001_10001_10101_11011_10001;  // Store data for the letter M
            5'd13: pixelValue = 35'b10001_10001_11001_10101_10011_10001_10001;  // Store data for the letter N
            5'd14: pixelValue = 35'b01110_10001_10001_10001_10001_10001_01110;  // Store data for the letter O
            5'd15: pixelValue = 35'b00001_00001_00001_01111_10001_10001_01111;  // Store data for the letter P
            5'd16: pixelValue = 35'b01110_11001_10101_10001_10001_10001_01110;  // Store data for the letter Q
            5'd17: pixelValue = 35'b10001_01001_00101_01111_10001_10001_01111;  // Store data for the letter R
            5'd18: pixelValue = 35'b01110_10001_10000_01110_00001_10001_01110;  // Store data for the letter S
            5'd19: pixelValue = 35'b00100_00100_00100_00100_00100_00100_11111;  // Store data for the letter T
            5'd20: pixelValue = 35'b01110_10001_10001_10001_10001_10001_10001;  // Store data for the letter U
            5'd21: pixelValue = 35'b00100_01010_10001_10001_10001_10001_10001;  // Store data for the letter V
            5'd22: pixelValue = 35'b01010_10101_10101_10001_10001_10001_10001;  // Store data for the letter W
            5'd23: pixelValue = 35'b10001_10001_01010_00100_01010_10001_10001;  // Store data for the letter X
            5'd24: pixelValue = 35'b00100_00100_00100_01010_10001_10001_10001;  // Store data for the letter Y
            5'd25: pixelValue = 35'b11111_00001_00010_00100_01000_10001_11111;  // Store data for the letter Z
            5'd26: pixelValue = 35'b00100_00000_00000_00000_00000_00000_00000;  // Store data for the charac .
            5'd27: pixelValue = 35'b00100_00000_00100_01000_10000_10001_01110;  // Store data for the charac ?
            5'd28: pixelValue = 35'b00100_00000_00100_00100_00100_00100_00100;  // Store data for the charac !
            
            default: pixelValue = (player ? 35'b11111_00001_00010_00100_01000_10001_01110 : 35'b11111_00100_00100_00100_00100_00111_00100); // Store the winning player as the default
        endcase                    
    end
endmodule // hexToPixel