`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// pc_mux.sv
// Engineer: Brian Li and Joshua Naim
// Description: A multiplexer to select the next program counter value based on control signals.
// 
//////////////////////////////////////////////////////////////////////////////////


module pc_mux (
    input logic [2:0] sel,
    input logic [31:0] pc_plus4,
    input logic [31:0] jalr,
    input logic [31:0] branch,
    input logic [31:0] jal,
    input logic [31:0] mtvec,
    input logic [31:0] mepc,
    output logic [31:0] pc_din
);

    always_comb begin
        case (sel)
            3'b000: pc_din = pc_plus4;
            3'b001: pc_din = jalr;
            3'b010: pc_din = branch;
            3'b011: pc_din = jal;
            3'b100: pc_din = mtvec;
            3'b101: pc_din = mepc;
            default: pc_din = 32'b0;
        endcase
    end
endmodule
