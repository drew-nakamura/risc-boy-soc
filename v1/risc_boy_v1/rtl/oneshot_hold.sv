//debounce #(
//    .DEBOUNCE_CYCLES(1_000_000)
//) u_debounce (
//    .clk          (),
//    .on           (),
//    .rst          (),
//    .button_raw   (),
//    .button_clean ()
//);

module oneshot_hold #(
    parameter int unsigned CYCLES = 1_000_000
) (
    input  logic clk,
    input  logic on,
    input  logic rst,          // Active-high synchronous reset
    input  logic [3:0] button_raw,
    output logic [3:0] button_pulse
);

    localparam int COUNT_WIDTH = $clog2(CYCLES + 1);
    
    logic [3:0] sync1, sync2;
    logic [COUNT_WIDTH-1:0] count;
    logic [COUNT_WIDTH-1:0] hold_count;
    logic arm, hold;
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
            count <= '0;
            arm <= 1'b1;
            button_pulse <= 1'b0;
        end else if(!on) begin
            button_pulse <= button_raw;
            arm <= 1'b1;
            count <= '0;
        end
        else begin
            button_pulse <= 0;
            if(count != 0)begin
                count <= count - 1'b1;
            end
            else if(!sync2) begin
                arm <= 1;
            end
            else if(arm) begin
                button_pulse <= sync2;
                arm <= 1'b0;
                hold_count <= 45;
            end else if(hold_count) begin
                button_pulse <= button_pulse;
                hold_count = hold_count - 1'b1;
                if(!hold_count) count <= CYCLES;
            end
        end
    end

endmodule