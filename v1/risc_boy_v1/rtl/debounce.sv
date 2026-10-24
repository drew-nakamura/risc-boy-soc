//debounce #(
//    .DEBOUNCE_CYCLES(1_000_000)
//) u_debounce (
//    .clk          (),
//    .on           (),
//    .rst          (),
//    .button_raw   (),
//    .button_clean ()
//);

module debounce #(
    parameter int unsigned DEBOUNCE_CYCLES = 1_000_000
) (
    input  logic clk,
    input  logic on,
    input  logic rst,          // Active-high synchronous reset
    input  logic [3:0] button_raw,
    output logic [3:0] button_clean
);

    localparam int COUNT_WIDTH =
        (DEBOUNCE_CYCLES <= 1) ? 1 : $clog2(DEBOUNCE_CYCLES);

    logic [3:0] sync1, sync2;
    logic [COUNT_WIDTH-1:0] count;

    // Synchronize the physical button to our clock.
    always_ff @(posedge clk) begin
        if (rst) begin
            sync1 <= 4'b0;
            sync2 <= 4'b0;
        end else begin
            sync1 <= button_raw;
            sync2 <= sync1;
        end
    end

    // Accept a change only after it persists long enough.
    always_ff @(posedge clk) begin
        if (rst) begin
            count        <= '0;
            button_clean <= 1'b0;
        end else if(!on) begin
            button_clean <= button_raw;
            count <= '0;
        end
        else if (sync2 == button_clean) begin
            count <= '0;
        end else if (count == DEBOUNCE_CYCLES - 1) begin
            button_clean <= sync2;
            count        <= '0;
        end else begin
            count <= count + 1'b1;
        end
    end

endmodule