`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// pc_top.sv
// Engineer: Brian Li and Joshua Naim
// Description: Top-level module integrating the PC register and PC multiplexer to manage the program counter.
// 
//////////////////////////////////////////////////////////////////////////////////


module pc_top (
    input logic clk,
    input logic rst,
    input logic we,
    input logic [2:0] sel,
    input logic [31:0] jalr,
    input logic [31:0] branch,
    input logic [31:0] jal,
    input logic [31:0] mtvec,
    input logic [31:0] mepc,
    output logic [31:0] pc_out
);

    logic [31:0] pc_plus4, pc_din, pc_current;

    assign pc_plus4 = pc_current + 32'd4;

    pc_mux u_mux (
        .sel(sel),
        .pc_plus4(pc_plus4),
        .jalr(jalr),
        .branch(branch),
        .jal(jal),
        .mtvec(mtvec),
        .mepc(mepc),
        .pc_din(pc_din)
    );

    pc_register u_pc (
        .clk(clk),
        .rst(rst),
        .we(we),
        .pc_in(pc_din),
        .pc_out(pc_current)
    );

    assign pc_out = pc_current;

endmodule
