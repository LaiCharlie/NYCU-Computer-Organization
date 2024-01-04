module twoBitMUX(d0, d1, select, result);

  input d0;
  input d1;
  input select;

  output result;

  assign result = select ? d1 : d0;

endmodule

/* 
  0 d0
  1 d1
*/