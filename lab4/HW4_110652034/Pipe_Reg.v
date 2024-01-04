module Pipe_Reg (
  clk_i,
  rst_n,
  data_i,
  data_o
);

  parameter size = 0;

  //I/O ports
  input clk_i;
  input rst_n;
  input [size-1:0] data_i;

  output [size-1:0] data_o;

  //Internal Signals
  reg [size-1:0] data_o;

  //Main function
  /*your code here*/
  always @(negedge rst_n or posedge clk_i) begin
	  if (~rst_n)
		  data_o <= 0;
	  else
		  data_o <= data_i;
end


endmodule
