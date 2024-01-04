module Sign_Extend (
    data_i,
    data_o
);

  //I/O ports
  input [16-1:0] data_i;

  output [32-1:0] data_o;

  //Internal Signals
  wire [32-1:0] data_o;

  //Main function
  /*your code here*/
  assign data_o = {{16{data_i[16-1]}}, data_i};

endmodule
