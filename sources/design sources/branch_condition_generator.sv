`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// branch_condition_generator.sv
// Engineer: Brian Li and Joshua Naim
// Description: The branch condition generator creates 3 signals that are the result of 3 comparisons on 2 input values. 
// The 3 comparisons are Equal, Less Than (assuming inputs are unsigned), and Less Than (assuming inputs are signed). 
// The results of those 3 comparisons are sufficient to determine every branch condition instruction in the OTTER.
// 
//////////////////////////////////////////////////////////////////////////////////


module branch_condition_generator (
    input logic [31:0] srcA,
    input logic [31:0] srcB,
    output logic eq,
    output logic ltu,
    output logic lt
    );
    
    assign eq = (srcA == srcB);
    assign ltu = (srcA < srcB);
    assign lt = (srcA[31] & ~srcB[31]) | (~(srcA[31] ^ srcB[31]) & ltu);
endmodule