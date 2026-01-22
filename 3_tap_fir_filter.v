module fir_filter_3tap (
    input wire clk,
    input wire rst_n,
    input wire signed [7:0] data_in,  // 8-bit input
    input wire valid_in,              // Input valid signal
    output reg signed [19:0] data_out,// Output (wider to avoid overflow)
    output reg valid_out              // Output valid signal
);

    // ----------------------------------------------------
    // 1. COEFFICIENTS (The "Filter" part)
    // ----------------------------------------------------
    // Let's implement a Low Pass Filter.
    // Example Coeffs: 1, 2, 1 (Simple moving averageish)
    // In real hardware, these might be programmable registers.
    localparam signed [7:0] C0 = 8'sd1;
    localparam signed [7:0] C1 = 8'sd2;
    localparam signed [7:0] C2 = 8'sd1;

    // ----------------------------------------------------
    // 2. DELAY LINE (The "Shift Register")
    // ----------------------------------------------------
    reg signed [7:0] x0, x1, x2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            x0 <= 0; x1 <= 0; x2 <= 0;
            valid_out <= 0;
        end else if (valid_in) begin
            x0 <= data_in; // Current sample
            x1 <= x0;      // Delayed by 1
            x2 <= x1;      // Delayed by 2
            valid_out <= 1; // Pipeline is filling
        end else begin
            valid_out <= 0;
        end
    end

    // ----------------------------------------------------
    // 3. MULTIPLY & ACCUMULATE (The "DSP" part)
    // ----------------------------------------------------
    // We use "blocking" assignments here for combinatorial logic,
    // but in a high-speed design, you would register these outputs too.
    
    reg signed [15:0] mult0, mult1, mult2;
    reg signed [19:0] sum;

    always @(*) begin
        // Multiplication Stage
        mult0 = x0 * C0;
        mult1 = x1 * C1;
        mult2 = x2 * C2;

        // Adder Stage
        sum = mult0 + mult1 + mult2;
    end

    // ----------------------------------------------------
    // 4. FINAL OUTPUT REGISTER
    // ----------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) data_out <= 0;
        else if (valid_in) data_out <= sum; 
    end

endmodule