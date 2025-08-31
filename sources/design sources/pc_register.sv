`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// pc_register.sv
// Engineer: Brian Li and Joshua Naim
// Description: A program counter register that updates on the clock edge, with reset and write enable functionality.
// 
//////////////////////////////////////////////////////////////////////////////////


//pc register responsible for reset and write enable
module pc_register ( 
    input logic clk,
    input logic rst,
    input logic we,
    input logic [31:0] pc_in,
    output logic [31:0] pc_out
);
    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            pc_out <= 32'b0;
        else if (we)
            pc_out <= pc_in;
    end
endmodule
