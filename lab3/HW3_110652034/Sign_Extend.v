module Sign_Extend (
    data_i,
    data_o
);

  //I/O ports
  input [16-1:0] data_i;

  output [32-1:0] data_o;

  //Internal Signals
  wire [32-1:0] data_o;

  //Sign extended
  /*your code here*/
  assign data_o[31:0] = (data_i[15]==1) ? {16'b1111111111111111, data_i[15:0]} : {16'b0000000000000000, data_i[15:0]};

endmodule
