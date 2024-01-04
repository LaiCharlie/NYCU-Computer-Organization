`include "fourBitMUX.v"
`include "twoBitMUX.v"
`include "twoBitMUX_32.v"
`include "ALU_31.v"
`include "ALU_1bit.v"
`include "Full_adder.v" 
module ALU (aluSrc1, aluSrc2, invertA, invertB, operation, result, zero, overflow);

  //I/O ports
  input [31:0] aluSrc1;
  input [31:0] aluSrc2;
  input invertA;
  input invertB;
  input [1:0] operation;

  output [31:0] result;
  output zero;
  output overflow;

  //Internal Signals
  wire [31:0] result;
  wire zero;
  wire overflow;

  //Main function
  /*your code here*/
  wire [32:1] cI;
  wire set;

  ALU_1bit a0(aluSrc1[0], aluSrc2[0], invertA, invertB, operation, invertB, set, result[0], cI[1]);

  genvar i;
	generate
		for(i = 1; i < 31; i = i + 1) begin:a1_30
			ALU_1bit ai(aluSrc1[i], aluSrc2[i], invertA, invertB, operation, cI[i], 1'b0, result[i], cI[i+1]);
    end
	endgenerate

  ALU_31 a31(aluSrc1[31], aluSrc2[31], invertA, invertB, operation, cI[31], 1'b0, result[31], cI[32], set, overflow);

  // nor(zero, result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15], result[16], result[17], result[18], result[19], result[20], result[21], result[22], result[23], result[24], result[25], result[26], result[27], result[28], result[29], result[30], result[31]);
  assign zero = (result == 0);
endmodule
