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

  /*your code here*/
  //Internal Signles
  wire [32-1:0] pc_in;
  wire [32-1:0] pc_out;
  wire [32-1:0] pc_add;
  wire [32-1:0] pc_branch;
  wire [32-1:0] pc_no_jump;
  wire [32-1:0] pc_temp;
  wire [32-1:0] instr;
  wire RegWrite;
  wire [2-1:0] ALUOp;
  wire ALUSrc;
  wire RegDst;
  wire Jump;
  wire Branch;
  wire BranchType;
  wire JRsrc;
  wire MemRead;
  wire MemWrite;
  wire MemtoReg;
  wire [5-1:0] RegAddrTemp;
  wire [5-1:0] RegAddr;
  wire [32-1:0] WriteData;
  wire [32-1:0] RSdata;
  wire [32-1:0] RTdata;
  wire [4-1:0] ALU_operation;
  wire [2-1:0] FURslt;
  wire sftVariable;
  wire leftRight;
  wire [32-1:0] extendData;
  wire [32-1:0] zeroData;
  wire [32-1:0] ALUsrcData;
  wire [32-1:0] ALUresult;
  wire zero;
  wire overflow;
  wire [5-1:0] shamt;
  wire [32-1:0] sftResult;
  wire [32-1:0] RegData;
  wire [32-1:0] MemData;
  wire [32-1:0] DataNoJal;

  //modules
  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(pc_in),
      .pc_out_o(pc_out)
  );

  Adder Adder1 (
      .src1_i(pc_out),
      .src2_i(32'd4),
      .sum_o (pc_add)
  );

  Adder Adder2 (
      .src1_i(pc_add),
      .src2_i({extendData[29:0], 2'b00}),
      .sum_o (pc_branch)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_branch (
      .data0_i (pc_add),
      .data1_i (pc_branch),
      .select_i(Branch & (~BranchType ^ zero)),
      .data_o  (pc_no_jump)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_jump (
      .data0_i (pc_no_jump),
      .data1_i ({pc_add[31:28], instr[25:0], 2'b00}),
      .select_i(Jump),
      .data_o  (pc_temp)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_jr (
      .data0_i (pc_temp),
      .data1_i (RSdata),
      .select_i(JRsrc),
      .data_o  (pc_in)
  );

  Instr_Memory IM (
      .pc_addr_i(pc_out),
      .instr_o  (instr)
  );

  Mux2to1 #(
      .size(5)
  ) Mux_RS_RT (
      .data0_i (instr[20:16]),
      .data1_i (instr[15:11]),
      .select_i(RegDst),
      .data_o  (RegAddrTemp)
  );

  Mux2to1 #(
      .size(5)
  ) Mux_Write_Reg (
      .data0_i (RegAddrTemp),
      .data1_i (5'd31),
      .select_i(Jump),
      .data_o  (RegAddr)
  );

  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(instr[25:21]),
      .RTaddr_i(instr[20:16]),
      .RDaddr_i(RegAddr),
      .RDdata_i(WriteData),
      .RegWrite_i(RegWrite & (~JRsrc)),
      .RSdata_o(RSdata),
      .RTdata_o(RTdata)
  );

  Decoder Decoder (
      .instr_op_i(instr[31:26]),
      .RegWrite_o(RegWrite),
      .ALUOp_o(ALUOp),
      .ALUSrc_o(ALUSrc),
      .RegDst_o(RegDst),
      .Jump_o(Jump),
      .Branch_o(Branch),
      .BranchType_o(BranchType),
      .MemRead_o(MemRead),
      .MemWrite_o(MemWrite),
      .MemtoReg_o(MemtoReg)
  );

  ALU_Ctrl AC (
      .funct_i(instr[5:0]),
      .ALUOp_i(ALUOp),
      .ALU_operation_o(ALU_operation),
      .FURslt_o(FURslt),
      .sftVariable_o(sftVariable),
      .leftRight_o(leftRight),
      .JRsrc_o(JRsrc)
  );

  Sign_Extend SE (
      .data_i(instr[15:0]),
      .data_o(extendData)
  );

  Zero_Filled ZF (
      .data_i(instr[15:0]),
      .data_o(zeroData)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i (RTdata),
      .data1_i (extendData),
      .select_i(ALUSrc),
      .data_o  (ALUsrcData)
  );

  ALU ALU (
      .aluSrc1(RSdata),
      .aluSrc2(ALUsrcData),
      .ALU_operation_i(ALU_operation),
      .result(ALUresult),
      .zero(zero),
      .overflow(overflow)
  );

  Mux2to1 #(
      .size(5)
  ) Shamt_Src (
      .data0_i (instr[10:6]),
      .data1_i (RSdata[4:0]),
      .select_i(sftVariable),
      .data_o  (shamt)
  );

  Shifter shifter (
      .leftRight(leftRight),
      .shamt(shamt),
      .sftSrc(ALUsrcData),
      .result(sftResult)
  );

  Mux3to1 #(
      .size(32)
  ) RDdata_Source (
      .data0_i (ALUresult),
      .data1_i (sftResult),
      .data2_i (zeroData),
      .select_i(FURslt),
      .data_o  (RegData)
  );

  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(RegData),
      .data_i(RTdata),
      .MemRead_i(MemRead),
      .MemWrite_i(MemWrite),
      .data_o(MemData)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_Read_Mem (
      .data0_i (RegData),
      .data1_i (MemData),
      .select_i(MemRead),
      .data_o  (DataNoJal)
  );

  Mux2to1 #(
      .size(32)
  ) Mux_Jal (
      .data0_i (DataNoJal),
      .data1_i (pc_add),
      .select_i(Jump),
      .data_o  (WriteData)
  );
endmodule



