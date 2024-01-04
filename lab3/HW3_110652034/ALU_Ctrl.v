module ALU_Ctrl (
    funct_i,
    ALUOp_i,
    ALU_operation_o,
    FURslt_o,
    leftRight_o
);

  //I/O ports
  input [6-1:0] funct_i;
  input [3-1:0] ALUOp_i;

  output [4-1:0] ALU_operation_o;
  output [2-1:0] FURslt_o;
  output leftRight_o;

  //Internal Signals
  wire [4-1:0] ALU_operation_o;
  wire [2-1:0] FURslt_o;
  wire leftRight_o;

  //Main function
  /*your code here*/
  
  // 4'b0000 and
	// 4'b0001 or
	// 4'b0010 add
	// 4'b0110 sub
	// 4'b0111 slt
	// 4'b1100 nor

  // add = 6’b100011
  // sub = 6’b010011
  // and = 6’b011111
  // or  = 6’b101111
  // nor = 6’b010000
  // sll = 6’b010010
  // slt = 6’b010100
  // srl = 6’b100010
  // jr  = 6'b000001
  // sllv= 6’b011000
  // slrv= 6’b101000

  //parameter
parameter addi = 3'b011;
parameter lwsw  = 3'b000;
parameter beq  = 3'b001;
parameter bne  = 3'b110; // bnez, bne
parameter blt  = 3'b100;
parameter bgez = 3'b101;
	
  assign ALU_operation_o = ({ALUOp_i,funct_i} == 9'b010100011 || ALUOp_i == 3'b011 || ALUOp_i == 3'b000) ? 4'b0010 
  : ({ALUOp_i,funct_i} == 9'b010010011 || ALUOp_i == 3'b001 || ALUOp_i == 3'b110) ? 4'b0110 
  : ({ALUOp_i,funct_i} == 9'b010010100 || ALUOp_i == 3'b100) ? 4'b0111
  : (ALUOp_i == 3'b101) ? 4'b1000
  : ({ALUOp_i,funct_i} == 9'b010010000) ? 4'b1100
  : ({ALUOp_i,funct_i} == 9'b010011111) ? 4'b0000
  : ({ALUOp_i,funct_i} == 9'b010010010) ? 4'b0000
  : ({ALUOp_i,funct_i} == 9'b010101111) ? 4'b0001
  : ({ALUOp_i,funct_i} == 9'b010100010) ? 4'b0001
  : ({ALUOp_i,funct_i} == 9'b010011000) ? 4'b1001
  : ({ALUOp_i,funct_i} == 9'b010101000) ? 4'b1010 : 4'b0000;

  // assign FURslt_o = ({ALUOp_i,funct_i} == 9'b010100010 || {ALUOp_i,funct_i} == 9'b010101000 || {ALUOp_i,funct_i} == 9'b010011000 || {ALUOp_i,funct_i} == 9'b010010010) ? 2'b01 : 2'b00;
  assign FURslt_o =  	(ALUOp_i == lwsw || ALUOp_i == beq || ALUOp_i == bne || ALUOp_i == blt || ALUOp_i == bgez) ? 2'b00 
  : ({ALUOp_i,funct_i} == 9'b010100011 || ALUOp_i == addi) ? 2'b00 
  : ({ALUOp_i,funct_i} == 9'b010010011) ? 2'b00 
  : ({ALUOp_i,funct_i} == 9'b010011111) ? 2'b00 
  : ({ALUOp_i,funct_i} == 9'b010101111) ? 2'b00 
  : ({ALUOp_i,funct_i} == 9'b010010000) ? 2'b00 
  : ({ALUOp_i,funct_i} == 9'b010010100) ? 2'b00 
  : ({ALUOp_i,funct_i} == 9'b010010010) ? 2'b01 
  : ({ALUOp_i,funct_i} == 9'b010100010) ? 2'b01 
  : ({ALUOp_i,funct_i} == 9'b010011000) ? 2'b01 
  : ({ALUOp_i,funct_i} == 9'b010101000) ? 2'b01 : 2'b00;

  // lr = 1 -> shift right >>
  // lr = 0 -> shift left  <<
  assign leftRight_o = ({ALUOp_i,funct_i} == 9'b010100010 || {ALUOp_i,funct_i} == 9'b010101000) ? 1'b1 : 1'b0;

endmodule