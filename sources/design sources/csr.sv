`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// csr.sv
// Engineer: Joshua Naim/Brian Li
// Description: MSTATUS(MIE/MPIE), MTVEC, MEPC with CSRRW/CSRRS/CSRRC and MRET
// Interrupt/MRET have priority over CSR writes.
// Force clean MSTATUS values on entry/exit (ISR sees 0x80; after MRET 0x08).
// Mask software writes to MSTATUS while inside ISR (MPIE==1).
// mtvec_ready goes high after first write to MTVEC; use it to gate TAKE_INTR.
//////////////////////////////////////////////////////////////////////////////////


module CSR (
  input  logic        clk,
  input  logic        rst,
  // CSR ops
  input  logic        csr_en,          // enable CSR op
  input  logic [1:0]  csr_funct,       // 01=CSRRW, 10=CSRRS, 11=CSRRC
  input  logic [11:0] csr_addr,        // 0x300, 0x305, 0x341
  input  logic [31:0] csr_wdata,       // rs1
  output logic [31:0] csr_rdata,       // old CSR to rd
  // interrupt / return
  input  logic        take_intr,       // latch MEPC, mask MIE, jump to MTVEC
  input  logic        do_mret,         // restore MIE from MPIE
  input  logic [31:0] mepc_in,         // next PC to save on interrupt
  // status outs
  output logic [31:0] mtvec_q,
  output logic [31:0] mepc_q,
  output logic        mie_q,           // MSTATUS.MIE
  output logic        mtvec_ready      // high once MTVEC programmed
);

  logic [31:0] mstatus_q;              // bit3=MIE, bit7=MPIE

  // read
  always_comb begin
    unique case (csr_addr)
      12'h300: csr_rdata = mstatus_q;
      12'h305: csr_rdata = mtvec_q;
      12'h341: csr_rdata = mepc_q;
      default: csr_rdata = 32'h00000000;
    endcase
  end

  // write helper
  function automatic [31:0] csr_write_val(input [31:0] oldv);
    case (csr_funct)
      2'b01: csr_write_val = csr_wdata;         // CSRRW
      2'b10: csr_write_val = oldv |  csr_wdata; // CSRRS
      2'b11: csr_write_val = oldv & ~csr_wdata; // CSRRC
      default: csr_write_val = oldv;
    endcase
  endfunction

  // state w/ priority: take_intr > do_mret > csr_en
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
      mstatus_q   <= 32'h00000000;
      mtvec_q     <= 32'h00000000;
      mepc_q      <= 32'h00000000;
      mtvec_ready <= 1'b0;
    end
    else if (take_intr) begin
      // interrupt entry
      mepc_q    <= mepc_in;
      mstatus_q <= 32'h00000080;  // MPIE=1, MIE=0, others 0
    end
    else if (do_mret) begin
      // return
      mstatus_q <= 32'h00000008;  // MPIE=0, MIE=1, others 0
    end
    else if (csr_en) begin
      unique case (csr_addr)
        12'h300: begin
          // block software writes to mstatus while inside ISR (MPIE==1)
          if (mstatus_q[7] == 1'b0)
            mstatus_q <= csr_write_val(mstatus_q);
        end
        12'h305: begin
          mtvec_q     <= csr_write_val(mtvec_q);
          mtvec_ready <= 1'b1; // mark MTVEC programmed
        end
        12'h341: mepc_q <= csr_write_val(mepc_q);
        default: ;
      endcase
    end
  end

  assign mie_q = mstatus_q[3];

endmodule
