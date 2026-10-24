module Interconnect(
    input logic CLK,
    input logic [31:0] address,
    input logic WE,
    input logic RDEN,
    input logic [31:0] DMEM_DATA,
    input logic [31:0] VRAM_DATA,
    input logic [31:0] SWITCHES,
    input logic [31:0] BUTTONS,
    output logic DMEM_RDEN,
    output logic DMEM_WE,
    output logic LEDS_WE,
    output logic SSEG_WE,
    output logic VRAM_WE, VRAM_RDEN,
    output logic [31:0] IOBUS_in
);
    typedef enum logic [1:0] {
        READ_NONE,
        READ_DMEM,
        READ_VRAM,
        READ_MMIO
    } read_region_e;

    read_region_e region_q;
    logic [31:0] mmio_q;

    initial begin
        region_q = READ_NONE;
        mmio_q   = '0;
    end

    // Live address: start a RAM read, or write. Does not drive IOBUS_in.
    always_comb begin
        DMEM_RDEN  = 1'b0;
        DMEM_WE    = 1'b0;
        LEDS_WE    = 1'b0;
        SSEG_WE    = 1'b0;
        VRAM_WE    = 1'b0;
        VRAM_RDEN  = 1'b0;

        if (address >= 32'h4000) begin
            case (address)
                32'h11000000: ;
                32'h11000020: LEDS_WE = WE;
                32'h11000040: if (WE) SSEG_WE = 1'b1;
            endcase
        end else if (address >= 32'h3000) begin
            VRAM_WE   = WE;
            VRAM_RDEN = RDEN;
        end else if (address >= 32'h1000) begin
            DMEM_RDEN = RDEN;
            DMEM_WE   = WE;
        end
    end

    // WE need to do a slight buffer
    // Read / write happens on the posedge of the instruciton going into mem
    // this then casues a werid read delay, 
    //Ex: imagine lw followed by sw, the lw reads in mem stage because the 
    // memroy had to address/signasl on the posedge it moved there, but the
    // combinational interconnect will instant switch the mapping, so the mappign
    // will be for the next isnturciotn but the incoming data wil be wrong. The write
    // to all other thigns are totalyl normaly though
    always_ff @(posedge CLK) begin
        if (RDEN) begin
            if (address == 32'h4000) begin
                region_q <= READ_MMIO;
                mmio_q   <= BUTTONS;
            end else if (address == 32'h11000000) begin
                region_q <= READ_MMIO;
                mmio_q   <= SWITCHES;
            end else if (address == 32'h4004 || address == 32'h4008 ||
                         (address >= 32'h3000 && address < 32'h4000)) begin
                region_q <= READ_VRAM;
            end else if (address >= 32'h1000 && address < 32'h3000) begin
                region_q <= READ_DMEM;
            end else begin
                region_q <= READ_NONE;
            end
        end
    end

    always_comb begin
        case (region_q)
            READ_DMEM: IOBUS_in = DMEM_DATA;
            READ_VRAM: IOBUS_in = VRAM_DATA;
            READ_MMIO: IOBUS_in = mmio_q;
            default:   IOBUS_in = 32'b0;
        endcase
    end
endmodule