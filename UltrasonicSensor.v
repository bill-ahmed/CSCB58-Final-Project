module UltrasoundSensor(CLOCK_50, SW, GPIO, HEX0, HEX1);
    input CLOCK_50;
    input [17:0] SW;

    inout [35:0] GPIO;

    output [6:0] HEX0;
    output [6:0] HEX1;

    wire newClock;

    reg countDownFrom = 27'd50000000;

    // Countdown from 50,000,000 to get 1hz
    always @(posedge CLOCK_50)
    begin
        if(countDownFrom == 27'b0)
            countDownFrom <= 27'd50000000;
        else
            countDownFrom <= countDownFrom - 1'b1;
    end

    assign newClock = countDownFrom == 27'b0 ? 1 : 0;

    assign GPIO[1] = newClock; // Send trigger
    hex_display my_hex0(
        .IN(GPIO[1]),
        .OUT(HEX0)
    );

    hex_display my_hex1(
        .IN(GPIO[3]), // Get back echo data
        .OUT(HEX1)
    );

endmodule