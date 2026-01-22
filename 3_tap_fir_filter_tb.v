`timescale 1ns / 1ps

module tb_fir_filter;

    reg clk;
    reg rst_n;
    reg signed [7:0] data_in;
    reg valid_in;
    wire signed [19:0] data_out;
    wire valid_out;

    // Instantiate the DUT (Device Under Test)
    fir_filter_3tap uut (
        .clk(clk), .rst_n(rst_n), 
        .data_in(data_in), .valid_in(valid_in), 
        .data_out(data_out), .valid_out(valid_out)
    );

    // Clock Setup
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0; rst_n = 0; valid_in = 0; data_in = 0;
        #20 rst_n = 1;

        // TEST 1: Impulse Response (Input = 10, 0, 0...)
        // Expected Output sequence: 10*C0, 10*C1, 10*C2 -> 10, 20, 10
        
        @(posedge clk);
        valid_in = 1; data_in = 10; // Impulse
        
        @(posedge clk);
        data_in = 0; // Zeroes follow

        @(posedge clk);
        data_in = 0;

        @(posedge clk);
        data_in = 0;
        
        @(posedge clk);
        valid_in = 0;
        
        #50;
        $stop;
    end
endmodule