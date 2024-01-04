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
`include "Pipe_Reg.v"

module Pipeline_CPU (
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

// IF ------------------------------------

  Program_Counter PC (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .pc_in_i(pc_in),
      .pc_out_o(pc_out)
  );

  Adder Adder1 (
      .src1_i(pc_out),
      .src2_i(32'd4),
      .sum_o (pc_in)
  );

  Instr_Memory IM (
      .pc_addr_i(pc_out),
      .instr_o  (instr)
  );

// IF/ID ---------------------------------

  wire [31:0] IF_instr;
  Pipe_Reg #(
      .size(32)
  ) pipe_IM (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(instr),
      .data_o(IF_instr)
  );

// ID ------------------------------------

  Reg_File RF (
      .clk_i(clk_i),
      .rst_n(rst_n),
      .RSaddr_i(IF_instr[25:21]),
      .RTaddr_i(IF_instr[20:16]),
      .RDaddr_i(MEM_RegAddr),
      .RDdata_i(WriteData),
      .RegWrite_i(MEM_RegWrite & (~JRsrc)),
      .RSdata_o(RSdata),
      .RTdata_o(RTdata)
  );

  Decoder Decoder (
      .instr_op_i(IF_instr[31:26]),
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

  Sign_Extend SE (
      .data_i(IF_instr[15:0]),
      .data_o(extendData)
  );

  Zero_Filled ZF (
      .data_i(IF_instr[15:0]),
      .data_o(zeroData)
  );

// ID/EX ---------------------------------

  wire ID_RegWrite;
  wire [1:0] ID_ALUOp;
  wire ID_ALUSrc;
  wire ID_RegDst;
  wire ID_MemRead;
  wire ID_MemWrite;
  wire ID_MemtoReg;
  Pipe_Reg #(
      .size(8)
  ) pipe_IDctrl (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i({RegWrite, ALUOp, ALUSrc, RegDst, MemRead, MemWrite, MemtoReg}),
      .data_o({ID_RegWrite, ID_ALUOp, ID_ALUSrc, ID_RegDst, ID_MemRead, ID_MemWrite, ID_MemtoReg})
  );

  wire [31:0] ID_RSdata;
  Pipe_Reg #(
      .size(32)
  ) pipe_RS (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(RSdata),
      .data_o(ID_RSdata)
  );

  wire [31:0] ID_RTdata;
  Pipe_Reg #(
      .size(32)
  ) pipe_RT (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(RTdata),
      .data_o(ID_RTdata)
  );

  wire [31:0] ID_extendData;
  Pipe_Reg #(
      .size(32)
  ) pipe_SE (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(extendData),
      .data_o(ID_extendData)
  );

  wire [31:0] ID_zeroData;
  Pipe_Reg #(
      .size(32)
  ) pipe_ZE (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(zeroData),
      .data_o(ID_zeroData)
  );

  wire [31:0] ID_instr;
  Pipe_Reg #(
      .size(32)
  ) pipe_ID (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(IF_instr),
      .data_o(ID_instr)
  );

// EX ------------------------------------

  Mux2to1 #(
      .size(5)
  ) Mux_RS_RT (
      .data0_i (ID_instr[20:16]),
      .data1_i (ID_instr[15:11]),
      .select_i(ID_RegDst),
      .data_o  (RegAddrTemp)
  );

  Mux2to1 #(
      .size(5)
  ) Mux_Write_Reg (
      .data0_i (RegAddrTemp),
      .data1_i (5'd31), // 11111
      .select_i(Jump),
      .data_o  (RegAddr)
  );

  ALU_Ctrl AC (
      .funct_i(ID_instr[5:0]),
      .ALUOp_i(ID_ALUOp),
      .ALU_operation_o(ALU_operation),
      .FURslt_o(FURslt),
      .sftVariable_o(sftVariable),
      .leftRight_o(leftRight),
      .JRsrc_o(JRsrc)
  );

  Mux2to1 #(
      .size(32)
  ) ALU_src2Src (
      .data0_i (ID_RTdata),
      .data1_i (ID_extendData),
      .select_i(ID_ALUSrc),
      .data_o  (ALUsrcData)
  );

  Mux2to1 #(
      .size(5)
  ) Shamt_Src (
      .data0_i (ID_instr[10:6]),
      .data1_i (ID_RSdata[4:0]),
      .select_i(sftVariable),
      .data_o  (shamt)
  );

  ALU ALU (
      .aluSrc1(ID_RSdata),
      .aluSrc2(ALUsrcData),
      .ALU_operation_i(ALU_operation),
      .result(ALUresult),
      .zero(zero),
      .overflow(overflow)
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
      .data2_i (ID_zeroData),
      .select_i(FURslt),
      .data_o  (RegData)
  );

// EX/MEM --------------------------------

  wire EX_RegWrite;
  wire EX_MemRead;
  wire EX_MemWrite;
  wire EX_MemtoReg;
  Pipe_Reg #(
      .size(4)
  ) pipe_EXctrl (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i({ID_RegWrite, ID_MemRead, ID_MemWrite, ID_MemtoReg}),
      .data_o({EX_RegWrite, EX_MemRead, EX_MemWrite, EX_MemtoReg})
  );

  wire [31:0] EX_RegData;
  Pipe_Reg #(
      .size(32)
  ) pipe_RegDataEX (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(RegData),
      .data_o(EX_RegData)
  );

  wire [31:0] EX_RTdata;
  Pipe_Reg #(
      .size(32)
  ) pipe_RTData (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(ID_RTdata),
      .data_o(EX_RTdata)
  );

  wire [4:0] EX_RegAddr;
  Pipe_Reg #(
      .size(5)
  ) pipe_RegAddrEX (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(RegAddr),
      .data_o(EX_RegAddr)
  );

// MEM -----------------------------------

  Data_Memory DM (
      .clk_i(clk_i),
      .addr_i(EX_RegData),
      .data_i(EX_RTdata),
      .MemRead_i(EX_MemRead),
      .MemWrite_i(EX_MemWrite),
      .data_o(MemData)
  );

// MEM/WB --------------------------------

  wire MEM_MemWrite;
  wire MEM_MemtoReg;
  Pipe_Reg #(
      .size(2)
  ) pipe_MEMctrl (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i({EX_RegWrite, EX_MemtoReg}),
      .data_o({MEM_RegWrite, MEM_MemtoReg})
  );

  wire [31:0] MEM_RegData;
  Pipe_Reg #(
      .size(32)
  ) pipe_RegDataMEM (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(EX_RegData),
      .data_o(MEM_RegData)
  );

  wire [31:0] MEM_MemData;
  Pipe_Reg #(
      .size(32)
  ) pipe_MemData (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(MemData),
      .data_o(MEM_MemData)
  );

  wire [4:0] MEM_RegAddr;
  Pipe_Reg #(
      .size(5)
  ) pipe_RegAddrMem (
      .clk_i (clk_i),
      .rst_n (rst_n),
      .data_i(EX_RegAddr),
      .data_o(MEM_RegAddr)
  );

// WB ------------------------------------

  Mux2to1 #(
      .size(32)
  ) WB_MUX (
      .data0_i (MEM_RegData),
      .data1_i (MEM_MemData),
      .select_i(MEM_MemtoReg),
      .data_o  (WriteData)
  );

endmodule