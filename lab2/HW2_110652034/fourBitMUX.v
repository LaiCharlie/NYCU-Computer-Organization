
module fourBitMUX(d, select, result);

  input [0:3] d;
  input [1:0] select;

  output result;

  wire A,B;
  twoBitMUX t0(d[0], d[1], select[0], A);
  twoBitMUX t1(d[2], d[3], select[0], B);
  twoBitMUX t2(A, B, select[1], result);
  
endmodule

/* 
  00 d[0]
  01 d[1]
  10 d[2]
  11 d[3]
*/