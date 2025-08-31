`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// branch_address_generator.sv
// Engineer: Brian Li
// Description: The branch address generator creates 3 signals that conditionally change the program counter (PC). 
// The branch output is used for all branch instructions (B-Type). 
// It is formed by adding the current PC to the B-Type immediate. 
// The jal output is only used for the jal instruction which is the only J-Type instruction. 
// It is formed by adding the current PC to the J-Type immediate. 
// The jalr output is only used for jalr instructions. 
// It is formed by adding the output of rs1 to the I-Type immediate. 
// 
//////////////////////////////////////////////////////////////////////////////////


module branch_address_generator (
    input logic [31:0] pc,
    input logic [31:0] rs1_data,
    input logic [31:0] imm_b,
    input logic [31:0] imm_j,
    input logic [31:0] imm_i,
    output logic [31:0] branch_addr,
    output logic [31:0] jal_addr,
    output logic [31:0] jalr_addr
    );
    
    assign branch_addr = pc + imm_b;
    assign jal_addr = pc + imm_j;
    assign jalr_addr = (rs1_data + imm_i) & 32'hFFFFFFFE;
endmodule