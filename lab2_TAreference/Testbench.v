`timescale 1ns / 1ps
`define CYCLE_TIME 10
`define END_COUNT 600
`define TEST_FILE_ALU "testcases/test_ALU.txt"
`define TEST_FILE_SHIFTER "testcases/test_Shifter.txt"
`define NUM_OF_TEST_ALU 70
`define NUM_OF_TEST_SHIFTER 30
`include "ALU.v"
`include "Shifter.v"

module Testbench;
  //Parameter
  parameter ADD = 2'b10;
  parameter AND = 2'b01;
  parameter OR = 2'b00;
  parameter LESS = 2'b11;
  parameter INVERT = 1'b1;
  parameter SHIFT_RIGHT = 1'b1;

  //Internal Signals
  reg CLK;

  reg [68-1:0] mem_inp_ALU[0:`NUM_OF_TEST_ALU-1];
  reg [38-1:0] mem_inp_Shifter[0:`NUM_OF_TEST_SHIFTER-1];
  reg [68-1:0] inp;  //ALU inp is 68 bits (shifter: 38)
  reg [32-1:0] result, A, B;
  reg zero_t, overflow_t;

  reg invertA, invertB, leftRight;
  reg [2-1:0] operation;
  reg [5-1:0] shamt;
  reg [32-1:0] aluSrc1, aluSrc2, sftSrc;
  wire [32-1:0] result_ALU, result_Shifter;
  wire zero, overflow;
  integer i, score;

  //Clock
  always #5 CLK = ~CLK;

  //Top module
  ALU #(
      .ADD(ADD),
      .AND(AND),
      .OR (OR),
      .LESS(LESS)
  ) alu (
      .aluSrc1(aluSrc1),
      .aluSrc2(aluSrc2),
      .invertA(invertA),
      .invertB(invertB),
      .operation(operation),
      .result(result_ALU),
      .zero(zero),
      .overflow(overflow)
  );

  Shifter #(
      .SHIFT_RIGHT(SHIFT_RIGHT)
  ) shifter (
      .leftRight(leftRight),
      .shamt(shamt),
      .sftSrc(sftSrc),
      .result(result_Shifter)
  );

  always @(posedge CLK) begin
    aluSrc1 <= inp[63:32];
    aluSrc2 <= inp[31:0];
    invertA <= inp[67];
    invertB <= inp[66];
    operation <= inp[65:64];

    leftRight <= inp[37];
    shamt <= inp[36:32];
    sftSrc <= inp[31:0];
  end

  initial begin
    CLK = 0;
    i = 0;
    score = 0;

    $readmemb(`TEST_FILE_ALU, mem_inp_ALU);
    $readmemb(`TEST_FILE_SHIFTER, mem_inp_Shifter);

    @(negedge CLK);
    while (i != `NUM_OF_TEST_ALU + `NUM_OF_TEST_SHIFTER) begin
      if (i < `NUM_OF_TEST_ALU) inp = mem_inp_ALU[i];
      else inp = mem_inp_Shifter[i-`NUM_OF_TEST_ALU];

      @(negedge CLK);
      if (i < `NUM_OF_TEST_ALU) begin
        A = (invertA == INVERT) ? ~aluSrc1 : aluSrc1;
        B = (invertB == INVERT) ? ~aluSrc2 : aluSrc2;

        case (inp[65:64])
          ADD: result = A + B + (invertB == INVERT);
          AND: result = A & B;
          OR: result = A | B;
          LESS: result = {31'b0, $signed(aluSrc1) < $signed(aluSrc2)};
          default: result = 32'b0;
        endcase

        zero_t = (result == 32'b0);
        if (inp[65:64] == ADD) begin
          B = (invertB == INVERT) ? ~aluSrc2 : aluSrc2 + (invertB == INVERT);
          if ((A[31] == B[31]) && (A[31] != result[31])) overflow_t = 1'b1;
          else overflow_t = 1'b0;

          if ((overflow == overflow_t) && (zero == zero_t) && result_ALU == result)
            score = score + 1;
          else begin
            $display("ERROR: ALU testcase fail");
            $display("input: %b", inp);
            $display("(correct value) overflow:%b zero:%b result:%b", overflow_t, zero_t, result);
            $display("(your value)    overflow:%b zero:%b result:%b", overflow, zero, result_ALU);
          end
        end else begin
          if ((zero == zero_t) && result == result_ALU) score = score + 1;
          else begin
            $display("ERROR: ALU testcase fail");
            $display("input: %b", inp);
            $display("(correct value) zero:%b result:%b", zero_t, result);
            $display("(your value)    zero:%b result:%b", zero, result_ALU);
          end
        end
      end else begin
        if (inp[37] == SHIFT_RIGHT) result = sftSrc >> shamt;
        else result = sftSrc << shamt;

        if (result_Shifter == result) score = score + 1;
        else begin
          $display("ERROR: Shifter testcase fail");
          $display("input: %b", inp[37:0]);
          $display("(correct value) result:%b", result);
          $display("(your value)    result:%b", result_Shifter);
        end
      end
      i = i + 1;
    end
    $display("Score: %0d\/%0d \n", score, `NUM_OF_TEST_ALU + `NUM_OF_TEST_SHIFTER);
    $finish;
  end
endmodule
