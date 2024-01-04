
module Shifter (leftRight, shamt, sftSrc, result);

  //I/O ports
  input leftRight;
  input [4:0] shamt;
  input [31:0] sftSrc;

  output [31:0] result;

  //Main function
  /*your code here*/
  
  wire [31:0] r0, r1, r2, r3, r4;
  twoBitMUX_32 SR0(sftSrc, {sftSrc[30:0],1'b0}, shamt[0], r0);
  twoBitMUX_32 SR1(r0, {r0[29:0], 2'b0}, shamt[1], r1);
  twoBitMUX_32 SR2(r1, {r1[27:0], 4'b0}, shamt[2], r2);
  twoBitMUX_32 SR3(r2, {r2[23:0], 8'b0}, shamt[3], r3);
  twoBitMUX_32 SR4(r3, {r3[15:0],16'b0}, shamt[4], r4);
  
  wire [31:0] l0, l1, l2, l3, l4;
  twoBitMUX_32 SL0(sftSrc, {1'b0,sftSrc[31:1]}, shamt[0], l0);
  twoBitMUX_32 SL1(l0, {2'b0, l0[31:2]}, shamt[1], l1);
  twoBitMUX_32 SL2(l1, {4'b0, l1[31:4]}, shamt[2], l2);
  twoBitMUX_32 SL3(l2, {8'b0, l2[31:8]}, shamt[3], l3);
  twoBitMUX_32 SL4(l3, {16'b0,l3[31:16]}, shamt[4], l4);
  
  twoBitMUX_32 FINAL(r4, l4, leftRight, result);

endmodule
