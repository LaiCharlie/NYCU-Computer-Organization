module Shifter (
    result,
    leftRight,
    shamt,
    sftSrc
);

  //I/O ports
  output [32-1:0] result;

  input leftRight;
  input [5-1:0] shamt;
  input [32-1:0] sftSrc;

  //Internal Signals
  wire [32-1:0] result;

  //Main function
  /*your code here*/

  // lr = 1 -> shift right
  assign result = leftRight ? (sftSrc >> shamt) : (sftSrc << shamt);

endmodule
