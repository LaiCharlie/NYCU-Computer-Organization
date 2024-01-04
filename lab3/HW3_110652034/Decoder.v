module Decoder (
    instr_op_i,
    RegWrite_o,
    ALUOp_o,
    ALUSrc_o,
    RegDst_o,
    Jump_o,
    Branch_o,
    BranchType_o,
    MemRead_o,
    MemWrite_o,
    MemtoReg_o
);

  //I/O ports
  input [6-1:0] instr_op_i;

  output RegWrite_o;
  output [3-1:0] ALUOp_o;
  output ALUSrc_o;
  output RegDst_o;
  output Jump_o;
  output Branch_o;
  output BranchType_o;
  output MemRead_o;
  output MemWrite_o;
  output MemtoReg_o;

  //Internal Signals
  wire RegWrite_o;
  wire [3-1:0] ALUOp_o;
  wire ALUSrc_o;
  wire RegDst_o;
  wire Jump_o;
  wire Branch_o;
  wire BranchType_o;
  wire MemRead_o;
  wire MemWrite_o;
  wire MemtoReg_o;

  //Main function
  /*your code here*/
  // sllv , slrv , jr : same Rtype
  parameter RType= 6'b000000;
  parameter addi = 6'b010011;
  parameter lw   = 6'b011000;
  parameter sw   = 6'b101000;
  parameter beq  = 6'b011001;
  parameter bne  = 6'b011010;
  parameter jump = 6'b001100;
  parameter jal  = 6'b001111;
  parameter blt  = 6'b011100;
  parameter bnez = 6'b011101;
  parameter bgez = 6'b011110;

  assign RegWrite_o = (instr_op_i == 6'b000000 || instr_op_i == 6'b010011 || instr_op_i == 6'b011000 || instr_op_i == 6'b001111) ? 1'b1 : 1'b0;

  assign ALUOp_o = 	(instr_op_i == RType) ? 3'b010
  : (instr_op_i == addi) ? 3'b011 
  : (instr_op_i == lw)   ? 3'b000
  : (instr_op_i == sw)   ? 3'b000 
  : (instr_op_i == beq)  ? 3'b001 
  : (instr_op_i == bne)  ? 3'b110 
  :	(instr_op_i == bnez) ? 3'b110 
  :	(instr_op_i == blt)  ? 3'b100 
  : (instr_op_i == bgez) ? 3'b101 : 3'b000;

  assign ALUSrc_o = (instr_op_i == 6'b010011 || instr_op_i == 6'b011000 || instr_op_i == 6'b101000) ? 1'b1 : 1'b0;

  assign RegDst_o = (instr_op_i == 6'b000000) ? 1'b1 : 1'b0;

  assign Jump_o = (instr_op_i == 6'b001100 || instr_op_i == 6'b001111) ? 1'b1 : 1'b0;

  assign BranchType_o = (instr_op_i == 6'b011010 || instr_op_i == 6'b011101 || instr_op_i == 6'b011100) ? 1'b1 : 1'b0;

  assign Branch_o = (instr_op_i == 6'b011010 || instr_op_i == 6'b011001 || instr_op_i == 6'b011101 || instr_op_i == 6'b011100 || instr_op_i == 6'b011110) ? 1'b1 : 1'b0;

  assign MemRead_o = (instr_op_i == 6'b011000) ? 1'b1 : 1'b0;

  assign MemWrite_o = (instr_op_i == 6'b101000) ? 1'b1 : 1'b0;

  assign MemtoReg_o = (instr_op_i == 6'b011000) ? 1'b1 : 1'b0;

endmodule

// R-type: add, sub, and, or, nor, slt, sll, srl, sllv, srlv, jr
// op , rs , rt , rd , shamt , func

// I-type: addi, lw, sw, beq, bne, blt, bnez, bgez
// op , rs , rt , immediate

// J-type: jump, jal
// op , address

