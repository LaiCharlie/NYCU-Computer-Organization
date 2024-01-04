
module ALU_31(a, b, invertA, invertB, operation, carryIn, less, result, carryOut, set, overflow);

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
  output set;
  output overflow;

  //Main function
  /*your code here*/
  wire A, B;

  twoBitMUX mo(a, ~a, invertA, A);
  twoBitMUX ms(b, ~b, invertB, B);

  wire oR;
  wire anD;
  wire adD;
  
  or (oR, A, B);
  and(anD, A, B);
  Full_adder fa(carryIn, A, B, adD, carryOut);

  // set -> ALU0's less
  // assign set = adD;
  fourBitMUX mt({adD, 1'b0, 1'b1, adD}, {a,b}, set);

  fourBitMUX mf({oR, anD, adD, less}, operation, result);

  // overflow -> if carryIn != carryOut
  wire OF;
  xor(OF, carryIn, carryOut);
  fourBitMUX mff({1'b0, 1'b0, OF, 1'b0}, operation, overflow);

endmodule