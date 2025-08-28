`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////
// reg_file.sv
// Engineer: Brian Li and Joshua Naim
// Description: A 32x32 register file with two read ports and one write port. Register x0 is hardwired to 0.
//
//////////////////////////////////////////////////////////////////////////////

module RegFile(
    input logic en,
    input logic [4:0] addr1,
    input logic [4:0] addr2,
    input logic [4:0] wa,
    input logic [31:0] write_data,
    input logic clk,
    output logic [31:0] rs1,
    output logic [31:0] rs2
    );

    // 32x32 register file
    logic [31:0] registers [0:31] = '{default:32'h0}; //Initialize all registers to 0
    
    
    assign rs1 = (addr1 == 5'b0) ? 32'h0 : registers[addr1];
    assign rs2 = (addr2 == 5'b0) ? 32'h0 : registers[addr2];
    
    always_ff @(posedge clk) begin
        // lui
        if (en && (wa != 5'b0)) begin
            registers[wa] <= write_data;
        end
    end
endmodule
