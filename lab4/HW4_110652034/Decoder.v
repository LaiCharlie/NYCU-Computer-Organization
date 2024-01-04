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

  //Instruction Format
  parameter OP_R_TYPE = 6'b000000;
  parameter OP_ADDI = 6'b010011;
  parameter OP_BEQ = 6'b011001;
  parameter OP_LW = 6'b011000;
  parameter OP_SW = 6'b101000;
  parameter OP_BNE = 6'b011010;
  parameter OP_JUMP = 6'b001100;
  parameter OP_JAL = 6'b001111;
  parameter OP_BLT = 6'b011100;
  parameter OP_BNEZ = 6'b011101;
  parameter OP_BGEZ = 6'b011110;

  parameter NO = 1'b0;
  parameter YES = 1'b1;

  //ALU OP
  parameter ALU_OP_R_TYPE = 2'b00;
  parameter ALU_ADD = 2'b01;
  parameter ALU_SUB = 2'b10;
  parameter ALU_LESS = 2'b11;

  //R-type or I-type Src & Dst
  parameter SRC_REG = 1'b0;
  parameter SRC_SIGN_EXTEND = 1'b1;

  parameter DST_RT = 1'b0;
  parameter DST_RD = 1'b1;

  //I/O ports
  input [6-1:0] instr_op_i;

  output RegWrite_o;
  output [2-1:0] ALUOp_o;
  output ALUSrc_o;
  output RegDst_o;
  output Jump_o;
  output Branch_o;
  output BranchType_o;
  output MemRead_o;
  output MemWrite_o;
  output MemtoReg_o;

  //Internal Signals
  reg RegWrite_o;
  reg [2-1:0] ALUOp_o;
  reg ALUSrc_o;
  reg RegDst_o;
  reg Jump_o;
  reg Branch_o;
  reg BranchType_o;
  reg MemRead_o;
  reg MemWrite_o;
  reg MemtoReg_o;

  //Main function
  /*your code here*/
  always @(instr_op_i) begin
    // RegWrite_o
    case (instr_op_i)
      OP_R_TYPE, OP_ADDI, OP_LW, OP_JAL: RegWrite_o <= YES;
      OP_SW, OP_BEQ, OP_BNE, OP_BLT, OP_BNEZ, OP_BGEZ, OP_JUMP: RegWrite_o <= NO;
      default: RegWrite_o <= 1'b0;
    endcase

    // ALUOp_o
    case (instr_op_i)
      OP_R_TYPE: ALUOp_o <= ALU_OP_R_TYPE;
      OP_ADDI, OP_LW, OP_SW: ALUOp_o <= ALU_ADD;
      OP_BEQ, OP_BNE, OP_BNEZ: ALUOp_o <= ALU_SUB;
      OP_BLT, OP_BGEZ: ALUOp_o <= ALU_LESS;
      default: ALUOp_o <= 2'b0;
    endcase

    // ALUSrc_o
    case (instr_op_i)
      OP_R_TYPE, OP_BEQ, OP_BNE, OP_BLT, OP_BNEZ, OP_BGEZ: ALUSrc_o <= SRC_REG;
      OP_ADDI, OP_LW, OP_SW: ALUSrc_o <= SRC_SIGN_EXTEND;
      default: ALUSrc_o <= 1'b0;
    endcase

    // RegDst_o
    case (instr_op_i)
      OP_R_TYPE: RegDst_o <= DST_RD;
      OP_ADDI, OP_LW: RegDst_o <= DST_RT;
      default: RegDst_o <= 1'b0;
    endcase

    // Jump_o
    case (instr_op_i)
      OP_JUMP, OP_JAL: Jump_o <= YES;
      OP_R_TYPE, OP_ADDI, OP_LW, OP_SW, OP_BEQ, OP_BNE, OP_BLT, OP_BNEZ, OP_BGEZ: Jump_o <= NO;
      default: Jump_o <= 1'b0;
    endcase

    // Branch_o
    case (instr_op_i)
      OP_BEQ, OP_BNE, OP_BLT, OP_BNEZ, OP_BGEZ: Branch_o <= YES;
      OP_R_TYPE, OP_ADDI, OP_LW, OP_SW, OP_JUMP, OP_JAL: Branch_o <= NO;
      default: Branch_o <= 1'b0;
    endcase

    // BranchType_o
    case (instr_op_i)
      OP_BEQ, OP_BGEZ: BranchType_o <= YES;
      OP_BNE, OP_BLT, OP_BNEZ: BranchType_o <= NO;
      default: BranchType_o <= 1'b0;
    endcase

    // MemRead_o
    case (instr_op_i)
      OP_LW: MemRead_o <= YES;
      OP_R_TYPE, OP_ADDI, OP_SW, OP_BEQ, OP_BNE, OP_BLT, OP_BNEZ, OP_BGEZ, OP_JUMP, OP_JAL:
      MemRead_o <= NO;
      default: MemRead_o <= 1'b0;
    endcase

    // MemWrite_o
    case (instr_op_i)
      OP_SW: MemWrite_o <= YES;
      OP_R_TYPE, OP_ADDI, OP_LW, OP_BEQ, OP_BNE, OP_BLT, OP_BNEZ, OP_BGEZ, OP_JUMP, OP_JAL:
      MemWrite_o <= NO;
      default: MemWrite_o <= 1'b0;
    endcase

    // MemtoReg_o
    case (instr_op_i)
      OP_LW: MemtoReg_o <= YES;
      OP_R_TYPE, OP_ADDI: MemtoReg_o <= NO;
      default: MemtoReg_o <= 1'b0;
    endcase
  end

endmodule
