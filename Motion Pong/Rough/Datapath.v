module Datapath(clock,
                resetn,
    
                sel_out,
                sel_col,
                
                ld_val,
                en_delayCounter,                

                fin_DE,
                fin_Wait,
                
                x_out,
                y_out,
                colour_out);
                
/* ------------- INPUT SIGNALS ------------- */

    /* FROM DE2 BOARD */
        input clock, resetn;

    /* FROM CONTROL MODULE */
        /* 
           Determines which shape to draw from the following
           -> left Paddle
           -> Ball
           -> right Paddle       
        */
        input [1:0] sel_out;

        /*
            Determines the colour of the shape i.e black or white
        */
        input sel_col;

        /*
            Enable signals for the counters6
        */
        input en_delayCounter;      // Detrmines the delay time for erasing

/* ----------- END INPUT SIGNALS ----------- */

/* ------------- OUTPUT SIGNALS ------------- */

    /* TO VGA_Adapter */
    output reg [2:0] colour_out;
    output reg [9:0] x_out;
	output reg [9:0] y_out;

    /* TO Control Module */
    output fin_Wait;
    output fin_DE;

/* ----------- END OUTPUT SIGNALS ----------- */

/* --------------- VARIABLES --------------- */
    // Registers for both counters
    reg [27:0] delayCounter;

    // Registers for ball counters
    reg [3:0] B_shapeCounter_D;
    reg [3:0] B_shapeCounter_E;
    reg [9:0] B_XposCounter;
    reg [9:0] B_YposCounter;

    // Registers for paddle1 counters
    reg [5:0] Paddle_shape;
    reg [5:0] P1_shapeCounter_E;
    reg [9:0] P1_posCounter;

    // Registers for paddle1 counters
    reg [5:0] P2_shapeCounter_D;
    reg [5:0] P2_shapeCounter_E;
    reg [9:0] P2_posCounter;

    // Registers for ball direction
    reg B_X_dir;
    reg B_Y_dir;

    // Register for paddle1 counter
    reg P1_dir;

    // Registes for paddle2 counter
    reg P2_dir;

    // Register for original Ball Position
    reg [9:0] OG_B_x;    // Store the original x position of the ball
	reg [9:0] OG_B_y;    // Store the original y position of the ball

    // Register for original Paddle1 Position
    reg [9:0] OG_P1_x;    // Store the original x position of the ball
	reg [9:0] OG_P1_y;    // Store the original y position of the ball

    // Register for original Paddle1 Position
    reg [9:0] OG_P2_x;    // Store the original x position of the ball
	reg [9:0] OG_P2_y;    // Store the original y position of the ball

    // WIRES

    // Datapath to Control wires
    wire fin_DE;        // Determinse whether an object has finished drawn or erased
    wire fin_Wait;      // Determines whether the waiting is done

    // Internal Wires
    wire B_moveX, B_moveY;  // for Ball
    wire P1_move;           // for Paddle1
    wire P2_move;           // for Paddle2

    // helper assignments for ball
    assign fin_B_D = (B_shapeCounter_D == 4'd15) ? 1 : 0;
    assign fin_B_E = (B_shapeCounter_E == 4'd15) ? 1 : 0;
    assign B_moveX = fin_B_E;
    assign B_moveY = fin_B_E;

    // helper assignments for paddle1
    assign fin_P1_D = (Paddle_shape == 6'd63) ? 1 : 0;
    assign fin_P1_E = (P1_shapeCounter_E == 6'd63) ? 1 : 0;
    assign P1_move = fin_P1_E;

    // helper assignments for paddle1
    assign fin_P2_D = (P2_shapeCounter_D == 6'd63) ? 1 : 0;
    assign fin_P2_E = (P2_shapeCounter_E == 6'd63) ? 1 : 0;
    assign P2_move = fin_P2_E;

    assign fin_Wait = (delayCounter == 28'd0) ? 1 : 0;


/* ------------- END VARIABLES ------------- */

/* --------------- MUXES --------------- */
    /* 
        Determines the enable signal depending on the shape to draw.
        Enable Ball -> 2'd0
        Enable Paddle1 -> 2'd1
        Enable Paddle2 -> 2'd2
     */
    always @(*)
    begin
        case (sel_out)
            2'd0: en_shapeCounter = 2'd0;
            2'd1: en_shapeCounter = 2'd1;
            2'd2: en_shapeCounter = 2'd2;
            2'd3: en_shapeCounter = 2'd3;
        endcase
    end

    /*
        Determins which colour should be outputted.
    */
    always @(*)
    begin
        case (sel_col)
            1'd0: colour_out = 3'd7;
            1'b1: colour_out = 3'd0;
        endcase
    end

    /*
        Determins the x coordinate of the shape to be drawn
    */
    always @(*)
    begin
        case (sel_out)
            2'd0: x_out = Ball_xCoord + Ball_xPos;
            2'd1: x_out = Pad1_xCoord;
            2'd2: x_out = Pad2_xCoord;
            2'd3: x_out = 10'd0;
        endcase
    end

    /*
        Determins the y coordinate of the shape to be drawn
    */
    always @(*)
    begin
        case (sel_out)
            2'd0: y_out = Ball_yCoord + Ball_yPos;
            2'd1: y_out = Pad1_yCoord + Paddle_shape + data[7:4];
            2'd2: y_out = Pad2_yCoord + Paddle_shape + data[3:0];
            2'd3: y_out = 10'd0;
        endcase
    end
/* ------------- END MUXES ------------- */

/* --------------- COUNTERS --------------- */

    /* 
        DELAY

        The Counter adds time before drawing and erasing.
        Essentially a delay.
        Value = 20'd833333 - 1'b1
    */
    always @(posedge clock)
    begin
        if(en_delayCounter == 28'd0)
            delayCounter <= 28'd400000 - 1'b1;
        else if(en_delayCounter == 1'b1)
            delayCounter <= delayCounter - 1'b1;
    end

    /* 
        PADDLE SHAPE

        The Counter helps you draw the shape of the paddles
    */
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            Paddle_shape <= 2'd0;
        else if(en_Paddle_shape == 1'b1)
            Paddle_shape <= Paddle_shape + 1'b1;
    end

    /*
        BALL X POSITION

        The Counter helps to move around the x direction
    */
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            Ball_xPos <= 10'd0;
        else if(move_Pad1 == 1'b1)
            Ball_xPos <= Ball_xPos + 1'b1;
    end

    /*
        BALL Y POSITION

        The Counter helps to move around the y direction
    */
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            Ball_yPos <= 10'd0;
        else if(move_Pad1 == 1'b1)
            Ball_yPos <= Ball_yPos + 1'b1;
    end

































/* ------------- BALL COUNTERS ------------- */
    /* 
        BALL - X POSITION Counter

        The counter helps to move the ball around the
        screen in the x direction
    */
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            Ball_xPos <= 10'd0;
        else if((B_moveX == 1'b1) & (B_X_dir == 1'b1))
            B_XposCounter <= B_XposCounter + 1'b1;
        else if((B_moveX == 1'b1) & (B_X_dir == 1'b0))
            B_XposCounter <= B_XposCounter - 1'b1;
    end

    // 3. BALL - y POSITION Counter
    /* 
        The counter helps to move the ball around the
        screen in the y direction
    */
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            B_YposCounter <= 10'd0;
        else if((B_moveY == 1'b1) & (B_Y_dir == 1'b1))
            B_YposCounter <= B_YposCounter + 1'b1;
        else if((B_moveY == 1'b1) & (B_Y_dir == 1'b0))
            B_YposCounter <= B_YposCounter - 1'b1;
    end

/* ----------- END BALL COUNTERS ----------- */

/* ------------ PADDLE1 COUNTERS ------------ */
    // 1. SHAPE Counter
    /* 
        The counter helps to draw a shape by adding
        to the existing x and y value.
    */
    

    // 2. PADDLE1 - Y POSITION Counter
    /* 
        The counter helps to move the ball around the
        screen in the x direction
    */
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            P1_posCounter <= 10'd0;
        else if((P1_move == 1'b1) & (P1_dir == 1'b1))
            P1_posCounter <= P1_posCounter + 1'b1;
        else if((P1_move == 1'b1) & (P1_dir == 1'b0))
            P1_posCounter <= P1_posCounter - 1'b1;
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
            P2_shapeCounter_D <= 6'd0;
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
            P2_posCounter <= 10'd0;
        else if((P2_move == 1'b1) & (P2_dir == 1'b1))
            P2_posCounter <= P2_posCounter + 1'b1;
        else if((P2_move == 1'b1) & (P2_dir == 1'b0))
            P2_posCounter <= P2_posCounter - 1'b1;
    end    


// ---------- END PADDLE COUNTERS ---------- //
/* ------------- END COUNTERS ------------- */

// ------------- REGISTERS ------------- //

	// register for x
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            OG_B_x <= 10'd0;
        else if(ld_bx == 1'b1)
            OG_B_x <= 10'd80;
    end

    // register for y
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            OG_B_y <= 10'd0;
        else if(ld_by == 1'b1)
            OG_B_y <= 10'd60;
    end

    // register for x paddle1
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            OG_P1_x <= 10'd0;
        else if(ld_bx == 1'b1)
            OG_P1_x <= 10'd0;
    end

    // register for y paddle1
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            OG_P1_y <= 10'd0;
        else if(ld_by == 1'b1)
            OG_P1_y <= 10'd112;
    end

    // register for x paddle1
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            OG_P2_x <= 10'd0;
        else if(ld_p2x == 1'b1)
            OG_P2_x <= 10'd10;
    end

    // register for y paddle1
    always @(posedge clock)
    begin
        if(resetn == 1'b0)
            OG_P2_y <= 10'd0;
        else if(ld_p2y == 1'b1)
            OG_P2_y <= 10'd112;
    end


    // Collision Detection
    always @(posedge clock)
    begin
        if(OG_B_x + B_shapeCounter_D[1:0] + B_shapeCounter_E[1:0] + B_XposCounter == 10'd0)
            B_X_dir <= 1'b1;
        else if(OG_B_x + B_shapeCounter_D[1:0] + B_shapeCounter_E[1:0] + B_XposCounter == 10'd156)
            B_X_dir <= 1'b0;
    end

    always @(posedge clock)
    begin
        if(OG_B_y + B_shapeCounter_D[3:2] + B_shapeCounter_E[3:2] + B_YposCounter == 10'd0)
            B_Y_dir <= 1'b1;
        else if(OG_B_y + B_shapeCounter_D[3:2] + B_shapeCounter_E[3:2] + B_YposCounter == 10'd116)
            B_Y_dir <= 1'b0;
    end

// ----------- END REGISTERS ----------- //

endmodule 
