`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////
// debouncer_one_shot.sv
// Engineer: Brian Li and Joshua Naim
// Description: A debouncer and one-shot pulse generator for push-button inputs.
////////////////////////////////////////////////////////////////////////////////


module debouncer_one_shot #(
    parameter int CLK_HZ   = 50_000_000,
    parameter int RISE_MS  = 5,   // min stable high time
    parameter int FALL_MS  = 5,   // min stable low time
    parameter int PULSE_MS = 1    // one-shot pulse width
)(
    input  logic clk,
    input  logic rst,
    input  logic btn_in,
    output logic pulse_out
);

    // Convert ms to cycles
    localparam int RISE_CLKS  = (CLK_HZ/1000) * RISE_MS;
    localparam int FALL_CLKS  = (CLK_HZ/1000) * FALL_MS;
    localparam int PULSE_CLKS = (CLK_HZ/1000) * PULSE_MS;

    // Counter width big enough for the largest count
    localparam int MAX_COUNT = (RISE_CLKS > FALL_CLKS) ?
                               ((RISE_CLKS > PULSE_CLKS) ? RISE_CLKS : PULSE_CLKS) :
                               ((FALL_CLKS > PULSE_CLKS) ? FALL_CLKS : PULSE_CLKS);
    localparam int CW = (MAX_COUNT <= 1) ? 1 : $clog2(MAX_COUNT);

    typedef enum logic [2:0] {
        ST_INIT,
        ST_LOW,
        ST_LOW_TO_HIGH,
        ST_HIGH,
        ST_HIGH_TO_LOW,
        ST_ONE_SHOT
    } state_t;

    state_t ps, ns;

    logic [CW-1:0] cnt;
    logic          cnt_inc, cnt_rst;

    // 2-FF input synchronizer
    logic btn_meta, btn_sync;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            btn_meta <= 1'b0;
            btn_sync <= 1'b0;
        end else begin
            btn_meta <= btn_in;
            btn_sync <= btn_meta;
        end
    end

    // Counter
    always_ff @(posedge clk or posedge rst) begin
        if (rst)           cnt <= '0;
        else if (cnt_rst)  cnt <= '0;
        else if (cnt_inc)  cnt <= cnt + {{(CW-1){1'b0}},1'b1};
    end

    // State register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) ps <= ST_INIT;
        else     ps <= ns;
    end

    // Next-state / outputs
    always_comb begin
        ns        = ps;
        pulse_out = 1'b0;
        cnt_inc   = 1'b0;
        cnt_rst   = 1'b0;

        unique case (ps)
            ST_INIT: begin
                ns      = ST_LOW;
                cnt_rst = 1'b1;
            end

            ST_LOW: begin
                if (btn_sync) begin
                    ns      = ST_LOW_TO_HIGH;
                    cnt_inc = 1'b1;
                end else begin
                    ns      = ST_LOW;
                    cnt_rst = 1'b1;
                end
            end

            ST_LOW_TO_HIGH: begin
                if (btn_sync) begin
                    if (cnt == RISE_CLKS-1) begin
                        ns      = ST_HIGH;
                        cnt_rst = 1'b1;
                    end else begin
                        ns      = ST_LOW_TO_HIGH;
                        cnt_inc = 1'b1;
                    end
                end else begin
                    ns      = ST_LOW;   // bounce back low
                    cnt_rst = 1'b1;
                end
            end

            ST_HIGH: begin
                if (btn_sync) begin
                    ns      = ST_HIGH;
                    cnt_rst = 1'b1;
                end else begin
                    ns      = ST_HIGH_TO_LOW;
                    cnt_inc = 1'b1;
                end
            end

            ST_HIGH_TO_LOW: begin
                if (!btn_sync) begin
                    if (cnt == FALL_CLKS-1) begin
                        ns      = ST_ONE_SHOT;
                        cnt_rst = 1'b1;
                    end else begin
                        ns      = ST_HIGH_TO_LOW;
                        cnt_inc = 1'b1;
                    end
                end else begin
                    ns      = ST_HIGH;  // bounce back high
                    cnt_rst = 1'b1;
                end
            end

            ST_ONE_SHOT: begin
                pulse_out = 1'b1;
                if (cnt == PULSE_CLKS-1) begin
                    ns      = ST_INIT;
                    cnt_rst = 1'b1;
                end else begin
                    ns      = ST_ONE_SHOT;
                    cnt_inc = 1'b1;
                end
            end

            default: begin
                ns      = ST_INIT;
                cnt_rst = 1'b1;
            end
        endcase
    end
endmodule
