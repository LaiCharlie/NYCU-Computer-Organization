
module twoBitMUX_32(d0, d1, select, result);

  input [31:0] d0;
  input [31:0] d1;
  input select;

  output [31:0] result;

  genvar i;
  generate
  for(i = 0; i < 32; i = i + 1) begin: mux_bit
        twoBitMUX m(d0[i], d1[i], select, result[i]);
    end
  endgenerate

endmodule

/* 
  0 d0
  1 d1
*/