module Shifter (
    leftRight,
    shamt,
    sftSrc,
    result
);

  //I/O ports
  input leftRight;
  input [5-1:0] shamt;
  input [32-1:0] sftSrc;

  output [32-1:0] result;

  //Internal Signals
  wire [32-1:0] result;

  //Main function
  /*your code here*/
  assign result = (leftRight) ? sftSrc >> shamt : sftSrc << shamt;

endmodule
