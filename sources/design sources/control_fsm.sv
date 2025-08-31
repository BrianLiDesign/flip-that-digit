`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// control_fsm.sv
// Engineer: Brian Li/Joshua Naim
// Description: 4-state FSM (INIT, FETCH, EXEC, WRITEBACK) with interrupt gating
//
//////////////////////////////////////////////////////////////////////////////////


module control_fsm (
    input  logic CLK,
    input  logic RESET,
    input  logic decoder_rf_we,
    output logic ir_we,
    output logic pc_we,
    output logic rf_we_out,
    output logic [1:0] ps,       // 00=INIT, 01=FETCH, 10=EXEC, 11=WRITEBACK
    // interrupt interface
    input  logic INTR,
    input  logic MIE,
    input  logic MTVEC_READY,    // NEW: only take interrupt after mtvec is programmed
    output logic TAKE_INTR,
    output logic DO_MRET,
    input  logic IS_MRET
);
    logic [1:0] ns;

    // State register
    always_ff @(posedge CLK or posedge RESET) begin
        if (RESET) ps <= 2'b00;      // INIT
        else       ps <= ns;
    end

    // Next-state / outputs
    always_comb begin
        ir_we     = 1'b0;
        pc_we     = 1'b0;
        rf_we_out = 1'b0;
        TAKE_INTR = 1'b0;
        DO_MRET   = 1'b0;
        ns        = ps;

        unique case (ps)
            2'b00: begin // INIT
                ns = 2'b01;          // -> FETCH
            end
            2'b01: begin // FETCH
                ns = 2'b10;          // -> EXEC
            end
            2'b10: begin // EXEC
                ir_we = 1'b1;        // latch instruction
                ns    = 2'b11;       // -> WRITEBACK
                if (IS_MRET) DO_MRET = 1'b1;   // signal MRET side effects this cycle
            end
            2'b11: begin // WRITEBACK
                pc_we     = 1'b1;             // update PC
                rf_we_out = decoder_rf_we;    // WB when decoder says so
                ns        = 2'b01;            // -> FETCH
                // Only allow interrupt when: external INTR=1, MIE=1, and mtvec is ready
                if (INTR && MIE && MTVEC_READY) TAKE_INTR = 1'b1;
            end
        endcase
    end
endmodule
