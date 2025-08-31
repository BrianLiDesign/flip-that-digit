`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// alu.sv
// Brian Li and Joshua Naim
// Description: 
// 
//////////////////////////////////////////////////////////////////////////////////


module alu (
    input  logic [31:0] srcA,
    input  logic [31:0] srcB,
    input  logic [3:0]  alu_fun,
    output logic [31:0] alu_result
);

    //shift amount from low 5 bits of srcB
    logic [4:0] sh;
    assign sh = srcB[4:0];

    always_comb begin
        case (alu_fun)
            4'b0000: alu_result = srcA + srcB;                   
            4'b1000: alu_result = srcA - srcB;                
            4'b0110: alu_result = srcA | srcB;                 
            4'b0111: alu_result = srcA & srcB;                  
            4'b0100: alu_result = srcA ^ srcB;                   
            4'b0101: alu_result = srcA >> sh;                
            4'b0001: alu_result = srcA << sh;                        
            4'b1101: alu_result = $signed(srcA) >>> sh;              
            4'b0010: alu_result = ($signed(srcA) < $signed(srcB)) ? 
                                 32'd1 : 32'd0;                      
            4'b0011: alu_result = (srcA < srcB) ? 32'd1 : 32'd0;      
            4'b1001: alu_result = srcB;                               
            default: alu_result = 32'h0000_0000;                     
        endcase
    end
endmodule