`include "Program_Counter.v"
`include "Adder.v"
`include "Instr_Memory.v"
`include "Mux2to1.v"
`include "Mux3to1.v"
`include "Reg_File.v"
`include "Decoder.v"
`include "ALU_Ctrl.v"
`include "Sign_Extend.v"
`include "Zero_Filled.v"
`include "ALU.v"
`include "Shifter.v"
`include "Data_Memory.v"

module Simple_Single_CPU (
    clk_i,
    rst_n
);

  //I/O port
  input clk_i;
  input rst_n;

  //Internal Signles
  wire [31:0] Jr_pc;
  wire [31:0] pc_instr;
  wire [31:0] add_pc;
  wire [31:0] add_add_pc;
  wire [31:0] branch_pc;
  wire [31:0] instr;
  wire [31:0] ex_instr;
  wire [31:0] zero_instr;

  wire RegWrite_o;
  wire [2:0] ALUOp_o;
  wire ALUSrc_o;
  wire RegDst_o;
  wire Jump_o;
  wire Branch_o;
  wire BranchType_o;
  wire MemRead_o;
  wire MemWrite_o;
  wire MemtoReg_o;

  wire [31:0] read_data1;
  wire [31:0] read_data2;
  wire [31:0] write_data;

  wire [31:0] shift_in;
  wire [31:0] shift_out;

  wire [3:0] ALU_operation_o;
  wire [1:0] FURslt_o;
  wire leftRight_o;

  wire [4:0] write_Reg;

  wire [31:0] result;
  wire zero;
  wire overflow;

  wire branch_pend;

  wire [31:0] mux3to1out;

  wire [31:0] dm_out;

  //modules
  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(Jr_pc),
      .pc_out_o(pc_instr)
  );

  Adder Adder1 (
      .src1_i(pc_instr),
      .src2_i(32'd4),
      .sum_o (add_pc)
  );

  Adder Adder2 (
      .src1_i(add_pc),
      .src2_i(ex_instr << 2),
      .sum_o (add_add_pc)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_branch (
      .data0_i (add_pc),
      .data1_i (add_add_pc),
      .select_i(Branch_o & branch_pend),
      .data_o  (branch_pc)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_jump (
      .data0_i (branch_pc),
      .data1_i ({add_pc[31:28], instr[27:0] << 2}),
      .select_i(Jump_o),
      .data_o  (Jr_pc)
  );

  Instr_Memory IM (
      .pc_addr_i(pc_instr),
      .instr_o  (instr)
  );

  Mux2to1 #(
      .size(1)
  ) Mux_ZERO (
      .data0_i (zero),
      .data1_i (~zero),
      .select_i(BranchType_o),
      .data_o  (branch_pend)
  );

  Mux2to1 #(
      .size(5)
  ) Mux_Write_Reg (
      .data0_i (instr[20:16]),
      .data1_i (instr[15:11]),
      .select_i(RegDst_o),
      .data_o  (write_Reg)
  );

  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(instr[25:21]),
      .RTaddr_i(instr[20:16]),
      .RDaddr_i(write_Reg),
      .RDdata_i(write_data),
      .RegWrite_i(RegWrite_o),
      .RSdata_o(read_data1),
      .RTdata_o(read_data2)
  );

  Decoder Decoder (
      .instr_op_i(instr[31:26]),
      .RegWrite_o(RegWrite_o),
      .ALUOp_o(ALUOp_o),
      .ALUSrc_o(ALUSrc_o),
      .RegDst_o(RegDst_o),
      .Jump_o(Jump_o),
      .Branch_o(Branch_o),
      .BranchType_o(BranchType_o),
      .MemRead_o(MemRead_o),
      .MemWrite_o(MemWrite_o),
      .MemtoReg_o(MemtoReg_o)
  );

  ALU_Ctrl AC (
      .funct_i(instr[5:0]),
      .ALUOp_i(ALUOp_o),
      .ALU_operation_o(ALU_operation_o),
      .FURslt_o(FURslt_o),
      .leftRight_o(leftRight_o)
  );

  Sign_Extend SE (
      .data_i(instr[15:0]),
      .data_o(ex_instr)
  );

  Zero_Filled ZF (
      .data_i(instr[15:0]),
      .data_o(zero_instr)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i (read_data2),
      .data1_i (ex_instr),
      .select_i(ALUSrc_o),
      .data_o  (shift_in)
  );

  ALU ALU (
      .aluSrc1(read_data1),
      .aluSrc2(shift_in),
      .ALU_operation_i(ALU_operation_o),
      .result(result),
      .zero(zero),
      .overflow(overflow)
  );

  Shifter shifter (
      .result(shift_out),
      .leftRight(leftRight_o),
      .shamt(instr[10:6]),
      .sftSrc(shift_in)
  );

  Mux3to1 #(
      .size(32)
  ) RDdata_Source (
      .data0_i (result),
      .data1_i (shift_out),
      .data2_i (zero_instr),
      .select_i(FURslt_o),
      .data_o  (mux3to1out)
  );

  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(mux3to1out),
      .data_i(read_data2),
      .MemRead_i(MemRead_o),
      .MemWrite_i(MemWrite_o),
      .data_o(dm_out)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_Write (
      .data0_i(mux3to1out),
      .data1_i(dm_out),
      .select_i(MemtoReg_o),
      .data_o(write_data)
  );

endmodule
