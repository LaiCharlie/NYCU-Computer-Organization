module ALU (
    aluSrc1,
    aluSrc2,
    ALU_operation_i,
    result,
    zero,
    overflow
);

  //I/O ports
  input [32-1:0] aluSrc1;
  input [32-1:0] aluSrc2;
  input [4-1:0] ALU_operation_i;

  output [32-1:0] result;
  output zero;
  output overflow;

  //Internal Signals
  reg [32-1:0] result;
  wire zero;
  wire overflow;

  input [31:0] as1;
  input [31:0] as2;

  //Main function
  /*your code here*/
  assign zero = (result==0);

  assign overflow = ((aluSrc1[31] == 0 && aluSrc2[31] == 0 && result[31] == 1) || (aluSrc1[31] == 1 && aluSrc2[31] == 1 && result[31] == 0)) ? 1'b1 : 1'b0;

  always @(ALU_operation_i, aluSrc1, aluSrc2) begin
    case (ALU_operation_i)
      0:  result <= aluSrc1 & aluSrc2;
      1:  result <= aluSrc1 | aluSrc2;
      2:  result <= aluSrc1 + aluSrc2;
      6:  result <= aluSrc1 - aluSrc2;
      7: result <= $signed(aluSrc1) < $signed(aluSrc2) ? 1 : 0;
      8: result <= $signed(aluSrc1) < $signed(aluSrc2) ? 0 : 1;
      9: result <= aluSrc1 << aluSrc2;
      10: result <= aluSrc1 >> aluSrc2;
      12: result <= ~(aluSrc1 | aluSrc2);
      default: result <= 0;
    endcase
  end

endmodule

// 0000
// 0001
// 0010
// 0110
// 0111
// 1100