`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// immed_gen.sv
// Engineer: Brian Li and Joshua Naim
// Description: Immediate generator for RISC-V instructions.
// 
//////////////////////////////////////////////////////////////////////////////////


module immed_gen (
  input  logic [31:7] IR,
  output logic [31:0] u_type,
  output logic [31:0] i_type,
  output logic [31:0] s_type,
  output logic [31:0] b_type,
  output logic [31:0] j_type
);

  assign u_type = { IR[31:12], 12'b0 };

  assign i_type = { {20{IR[31]}}, IR[30:20] };

  assign s_type = { {20{IR[31]}}, IR[30:25], IR[11:7] };

  // B-type: imm[12]=IR[31], imm[10:5]=IR[30:25], imm[4:1]=IR[11:8], imm[11]=IR[7], imm[0]=0
  assign b_type = { {19{IR[31]}}, IR[31], IR[30:25], IR[11:8], IR[7], 1'b0 };

  assign j_type = { {11{IR[31]}}, IR[31], IR[19:12], IR[20], IR[30:21], 1'b0 };
endmodule
