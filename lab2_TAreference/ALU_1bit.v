`include "Full_adder.v"
module ALU_1bit (
    a,
    b,
    invertA,
    invertB,
    operation,
    carryIn,
    less,
    result,
    carryOut
);

  parameter ADD = 2'b10;
  parameter AND = 2'b01;
  parameter OR = 2'b00;
  parameter LESS = 2'b11;

  //I/O ports
  input a;
  input b;
  input invertA;
  input invertB;
  input [2-1:0] operation;
  input carryIn;
  input less;

  output result;
  output carryOut;

  //Internal Signals
  wire result;
  wire carryOut;

  //Main function
  /*your code here*/
  wire sum;
  wire ia, ib;

  assign ia = a ^ invertA;
  assign ib = b ^ invertB;
  assign result = (operation == ADD) ? sum :
    (operation == AND) ? ia & ib :
    (operation == OR) ? ia | ib :
    (operation == LESS) ? less : 1'b0;

  Full_adder fa (
      .carryIn(carryIn),
      .input1(ia),
      .input2(ib),
      .sum(sum),
      .carryOut(carryOut)
  );

endmodule
