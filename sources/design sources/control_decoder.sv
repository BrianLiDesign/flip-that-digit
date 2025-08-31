`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// control_decoder.sv
// Engineer: Brian Li and Joshua Naim
// Description: Control signal decoder for RISC-V instructions.
// 
//////////////////////////////////////////////////////////////////////////////////


module control_decoder (
    input  logic [31:0] IR,
    output logic        rf_we,
    output logic [3:0]  alu_fun,
    output logic [1:0]  b_sel,
    output logic        is_branch,
    output logic        is_jal,
    output logic        is_jalr,
    // CSR / MRET
    output logic        csr_en,
    output logic [1:0]  csr_funct,
    output logic [11:0] csr_addr,
    output logic        is_mret
);
    logic [6:0] opcode = IR[6:0]; 
    logic [2:0] funct3 = IR[14:12];
    logic [6:0] funct7 = IR[31:25];

    always_comb begin
        rf_we     = 1'b0;
        alu_fun   = 4'b0000;
        b_sel     = 2'b00;
        is_branch = 1'b0;
        is_jal    = 1'b0;
        is_jalr   = 1'b0;
        csr_en    = 1'b0;
        csr_funct = 2'b00;
        csr_addr  = 12'h000;
        is_mret   = 1'b0;

        unique case (opcode)
            // LUI
            7'b0110111: begin
                rf_we   = 1'b1;
                b_sel   = 2'b10;
                alu_fun = 4'b1001; // passB
            end

            // Jumps
            7'b1101111: begin rf_we = 1'b1; is_jal  = 1'b1; end
            7'b1100111: begin rf_we = 1'b1; is_jalr = 1'b1; b_sel = 2'b01; end

            // Branches
            7'b1100011: begin is_branch = 1'b1; end

            // Loads
            7'b0000011: begin rf_we = 1'b1; b_sel = 2'b01; alu_fun = 4'b0000; end

            // Stores
            7'b0100011: begin rf_we = 1'b0; b_sel = 2'b01; alu_fun = 4'b0000; end

            // I-ALU
            7'b0010011: begin
                rf_we = 1'b1; b_sel = 2'b01;
                unique case (funct3)
                    3'b000: alu_fun = 4'b0000;                 // ADDI
                    3'b010: alu_fun = 4'b0010;                 // SLTI
                    3'b011: alu_fun = 4'b0011;                 // SLTIU
                    3'b100: alu_fun = 4'b0100;                 // XORI
                    3'b110: alu_fun = 4'b0110;                 // ORI
                    3'b111: alu_fun = 4'b0111;                 // ANDI
                    3'b001: if (funct7==7'b0000000) alu_fun = 4'b0001; // SLLI
                    3'b101: begin
                        if (funct7==7'b0000000) alu_fun = 4'b0101;     // SRLI
                        else if (funct7==7'b0100000) alu_fun = 4'b1101; // SRAI
                    end
                    default: alu_fun = 4'b0000;
                endcase
            end

            // R-ALU
            7'b0110011: begin
                rf_we = 1'b1; b_sel = 2'b00;
                unique case ({funct7,funct3})
                    {7'b0000000,3'b000}: alu_fun = 4'b0000;    // ADD
                    {7'b0100000,3'b000}: alu_fun = 4'b1000;    // SUB
                    {7'b0000000,3'b001}: alu_fun = 4'b0001;    // SLL
                    {7'b0000000,3'b010}: alu_fun = 4'b0010;    // SLT
                    {7'b0000000,3'b011}: alu_fun = 4'b0011;    // SLTU
                    {7'b0000000,3'b100}: alu_fun = 4'b0100;    // XOR
                    {7'b0000000,3'b101}: alu_fun = 4'b0101;    // SRL
                    {7'b0100000,3'b101}: alu_fun = 4'b1101;    // SRA
                    {7'b0000000,3'b110}: alu_fun = 4'b0110;    // OR
                    {7'b0000000,3'b111}: alu_fun = 4'b0111;    // AND
                    default:             alu_fun = 4'b0000;
                endcase
            end

            // SYSTEM / CSR / MRET
            7'b1110011: begin
                if (funct3 == 3'b000) begin
                    if (IR[31:20] == 12'h302) begin // MRET
                        is_mret = 1'b1;
                        rf_we   = 1'b0;
                    end
                end else begin
                    // CSR* rd <- old CSR
                    rf_we    = 1'b1;
                    csr_en   = 1'b1;
                    csr_addr = IR[31:20];
                    unique case (funct3)
                      3'b001: csr_funct = 2'b01;  // CSRRW
                      3'b010: csr_funct = 2'b10;  // CSRRS
                      3'b011: csr_funct = 2'b11;  // CSRRC
                      default: csr_funct = 2'b00;
                    endcase
                end
            end
        endcase
    end
endmodule
