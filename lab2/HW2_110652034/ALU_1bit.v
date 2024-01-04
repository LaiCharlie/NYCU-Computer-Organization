
module ALU_1bit (a, b, invertA, invertB, operation, carryIn, less, result, carryOut);

  //I/O ports
  input a;
  input b;
  input invertA;
  input invertB;
  input [1:0] operation;
  input carryIn;
  input less;

  output result;
  output carryOut;

  //Main function
  /*your code here*/
  wire A, B;

  twoBitMUX mo(a, ~a, invertA, A);
  twoBitMUX ms(b, ~b, invertB, B);

  wire oR;
  wire anD;
  wire adD;
  wire co;

  or (oR, A, B);
  and(anD, A, B);
  Full_adder fa(carryIn, A, B, adD, carryOut);

  fourBitMUX mt({oR, anD, adD, less}, operation, result);

endmodule

/* 
  00 OR
  01 AND
  10 ADD
  11 LESS
*/