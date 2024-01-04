`timescale 1ns / 1ps
`define CYCLE_TIME 10
`define END_COUNT 600
`define NUM_OF_TEST_R_TYPE_ADDI 3
`define NUM_OF_TEST_I_TYPE_JUMP 1
`include "Simple_Single_CPU.v"

module Testbench;
  //Parameter
  parameter OP_R_TYPE = 6'b000000;
  parameter OP_ADDI = 6'b010011;
  parameter OP_BEQ = 6'b011001;
  // parameter OP_LUI = 6'b001101;
  parameter OP_LW = 6'b011000;
  parameter OP_SW = 6'b101000;
  parameter OP_BNE = 6'b011010;
  parameter OP_JUMP = 6'b001100;
  parameter OP_JAL = 6'b001111;
  parameter OP_BLT = 6'b011100;
  parameter OP_BNEZ = 6'b011101;
  parameter OP_BGEZ = 6'b011110;

  parameter FUNC_ADD = 6'b100011;
  parameter FUNC_SUB = 6'b010011;
  parameter FUNC_AND = 6'b011111;
  parameter FUNC_OR  = 6'b101111;
  parameter FUNC_NOR = 6'b010000;
  parameter FUNC_SLT = 6'b010100;
  parameter FUNC_SLLV = 6'b011000;
  parameter FUNC_SLL = 6'b010010;
  parameter FUNC_SRLV = 6'b101000;
  parameter FUNC_SRL = 6'b100010;
  parameter FUNC_JR = 6'b000001;

  //Internal Signals
  reg CLK;
  reg RST;
  integer count, score, total_score, testing, error, reg_error, mem_error, wa;

  reg [32-1:0] instruction;
  reg [32-1:0] register_file[0:32-1];
  reg [8-1:0] mem_file[0:128-1];
  reg [32-1:0] pc;
  reg [5-1:0] rs, rt, rd;
  reg [32-1:0] addr, data;
  reg [8*10-1:0] instr_name;
  integer i;

  wire [32-1:0] memory[0:32-1];
  genvar j;
  generate
    for (j = 0; j < 32; j = j + 1) begin : gen_alu
      assign memory[j] = {mem_file[j*4+3], mem_file[j*4+2], mem_file[j*4+1], mem_file[j*4]};
    end
  endgenerate

  //Clock
  always #5 CLK = ~CLK;

  //Top module
  Simple_Single_CPU cpu (
      .clk_i(CLK),
      .rst_n(RST)
  );

  initial begin
    score = 0;
    total_score = 0;
    for (testing = 1; testing <= `NUM_OF_TEST_R_TYPE_ADDI + `NUM_OF_TEST_I_TYPE_JUMP; testing++)
    begin
      if (testing == 1) $display("+++++ R-type & addi +++++");
      if (testing == `NUM_OF_TEST_R_TYPE_ADDI + 1) $display("+++++ I-type & jump +++++");
      $display($sformatf("test %1d", testing));
      // reset
      wa = 0;

      for (i = 0; i < 32; i = i + 1) begin
        cpu.IM.Instr_Mem[i] = 32'd0;
      end

      for (i = 0; i < 32; i = i + 1) begin
        register_file[i] = 32'd0;
      end
      register_file[29] = 32'd128;  //stack pointer

      for (i = 0; i < 128; i = i + 1) begin
        mem_file[i]   = 8'b0;
        cpu.DM.Mem[i] = 8'b0;
      end

      // init
      $readmemb($sformatf("testcases/test_%1d.txt", testing), cpu.IM.Instr_Mem);
      
      // $dumpfile("wave.vcd");
      // $dumpvars;

      CLK = 0;
      RST = 0;
      count = 0;
      instruction = 32'd0;
      @(negedge CLK);
      RST = 1;
      pc  = 32'd0;

      // prevent infinite loop
      while (count != `END_COUNT) begin
        instruction = cpu.IM.Instr_Mem[pc>>2];
        pc = pc + 32'd4;

        // simulate cpu
        case (instruction[31:26])
          OP_R_TYPE: begin
            rs = instruction[25:21];
            rt = instruction[20:16];
            rd = instruction[15:11];
            case (instruction[5:0])
              FUNC_ADD: begin
                instr_name = "add";
                register_file[rd] = $signed(register_file[rs]) + $signed(register_file[rt]);
              end
              FUNC_SUB: begin
                instr_name = "sub";
                register_file[rd] = $signed(register_file[rs]) - $signed(register_file[rt]);
              end
              FUNC_AND: begin
                instr_name = "and";
                register_file[rd] = register_file[rs] & register_file[rt];
              end
              FUNC_OR: begin
                instr_name = "or";
                register_file[rd] = register_file[rs] | register_file[rt];
              end
              FUNC_NOR: begin
                instr_name = "nor";
                register_file[rd] = ~(register_file[rs] | register_file[rt]);
              end
              FUNC_SLT: begin
                instr_name = "slt";
                register_file[rd] = ($signed(register_file[rs]) < $signed(register_file[rt])) ?
                    (32'd1) : (32'd0);
              end
              FUNC_SLLV: begin
                instr_name = "sllv";
                register_file[rd] = register_file[rt] << register_file[rs];
              end
              FUNC_SLL: begin
                instr_name = "sll";
                register_file[rd] = register_file[rt] << instruction[10:6];
              end
              FUNC_SRLV: begin
                instr_name = "srlv";
                register_file[rd] = register_file[rt] >> register_file[rs];
              end
              FUNC_SRL: begin
                instr_name = "srl";
                register_file[rd] = register_file[rt] >> instruction[10:6];
              end
              FUNC_JR: begin
                instr_name = "jr";
                pc = register_file[rs];
              end
              default: begin
                $display("ERROR: invalid function code (0b%06b)!!\nStop simulation", instruction[5:0]);
                #(`CYCLE_TIME * 1);
                $finish;
              end
            endcase
          end
          OP_ADDI: begin
            instr_name = "addi";
            rs = instruction[25:21];
            rt = instruction[20:16];
            register_file[rt] = $signed(register_file[rs]) +
                $signed({{16{instruction[15]}}, {instruction[15:0]}});
          end
          OP_BEQ: begin
            instr_name = "beq";
            rs = instruction[25:21];
            rt = instruction[20:16];
            if (register_file[rt] == register_file[rs]) begin
              pc = pc + $signed({{14{instruction[15]}}, {instruction[15:0]}, {2'd0}});
            end
          end
          // OP_LUI: begin
          //   instr_name = "lui";
          //   rs = instruction[25:21];
          //   rt = instruction[20:16];
          //   register_file[rt] = $signed(register_file[rs]) +
          //       $signed({{instruction[15:0]}, {16'h0000}});
          // end
          OP_LW: begin
            instr_name = "lw";
            rs = instruction[25:21];
            rt = instruction[20:16];
            addr = $signed(register_file[rs]) +
                $signed({{16{instruction[15]}}, {instruction[15:0]}});
            register_file[rt] = {
              mem_file[addr+3], mem_file[addr+2], mem_file[addr+1], mem_file[addr]
            };
          end
          OP_SW: begin
            instr_name = "sw";
            rs = instruction[25:21];
            rt = instruction[20:16];
            addr = $signed(register_file[rs]) +
                $signed({{16{instruction[15]}}, {instruction[15:0]}});
            data = register_file[rt];
            {mem_file[addr+3], mem_file[addr+2], mem_file[addr+1], mem_file[addr]} = {
              data[31:24], data[23:16], data[15:8], data[7:0]
            };
          end
          OP_BNE: begin
            instr_name = "bne";
            rs = instruction[25:21];
            rt = instruction[20:16];
            if (register_file[rt] != register_file[rs]) begin
              pc = pc + $signed({{14{instruction[15]}}, {instruction[15:0]}, {2'd0}});
            end
          end
          OP_JUMP: begin
            instr_name = "jump";
            pc = {{pc[31:28]}, {instruction[25:0]}, {2'b00}};
          end
          OP_JAL: begin
            instr_name = "jal";
            register_file[31] = pc;
            pc = {{pc[31:28]}, {instruction[25:0]}, {2'b00}};
          end
          OP_BLT: begin
            instr_name = "blt";
            rs = instruction[25:21];
            rt = instruction[20:16];
            if ($signed(register_file[rs]) < $signed(register_file[rt])) begin
              pc = pc + $signed({{14{instruction[15]}}, {instruction[15:0]}, {2'd0}});
            end
          end
          OP_BNEZ: begin
            instr_name = "bnez";
            rs = instruction[25:21];
            if ($signed(register_file[rs]) != 0) begin
              pc = pc + $signed({{14{instruction[15]}}, {instruction[15:0]}, {2'd0}});
            end
          end
          OP_BGEZ: begin
            instr_name = "bgez";
            rs = instruction[25:21];
            if ($signed(register_file[rs]) >= 0) begin
              pc = pc + $signed({{14{instruction[15]}}, {instruction[15:0]}, {2'd0}});
            end
          end
          default: begin
            $display("ERROR: invalid op code (0b%06b) !!\nStop simulation", instruction[31:26]);
            #(`CYCLE_TIME * 1);
            $finish;
          end
        endcase

        error = 0;
        reg_error = 0;
        mem_error = 0;
        @(negedge CLK);
        // check pc address
        if (cpu.PC.pc_out_o !== pc) begin
          if (error == 0) begin
            $display("ERROR: instruction (%1s) fail", instr_name);
            $display("instruction: %1b", instruction);
            error = 1;
          end
          $display("(correct value) pc_addr:%1d", pc);
          $display("(your value)    pc_addr:%1d", cpu.PC.pc_out_o);
          wa = 1;
        end
        // check the register & memory
        for (i = 0; i < 32; i = i + 1) begin
          if (cpu.RF.Reg_File[i] != register_file[i]) begin
            if (error == 0) begin
              $display("ERROR: instruction (%1s) fail", instr_name);
              $display("instruction: %1b", instruction);
              error = 1;
            end
            if (cpu.RF.Reg_File[i] !== register_file[i]) begin
              if (reg_error == 0) begin
                $display("(correct value)");
                $display(
                  "===== Register =====\n",
                  " r0=%1d,  r1=%1d,  r2=%1d,  r3=%1d,  r4=%1d,  r5=%1d,  r6=%1d,  r7=%1d,\n",
                  $signed(register_file[0]), $signed(register_file[1]), $signed(register_file[2]), $signed(register_file[3]),
                  $signed(register_file[4]), $signed(register_file[5]), $signed(register_file[6]), $signed(register_file[7]),
                  " r8=%1d,  r9=%1d, r10=%1d, r11=%1d, r12=%1d, r13=%1d, r14=%1d, r15=%1d,\n",
                  $signed(register_file[8]), $signed(register_file[9]), $signed(register_file[10]), $signed(register_file[11]),
                  $signed(register_file[12]), $signed(register_file[13]), $signed(register_file[14]), $signed(register_file[15]),
                  "r16=%1d, r17=%1d, r18=%1d, r19=%1d, r20=%1d, r21=%1d, r22=%1d, r23=%1d,\n",
                  $signed(register_file[16]), $signed(register_file[17]), $signed(register_file[18]), $signed(register_file[19]),
                  $signed(register_file[20]), $signed(register_file[21]), $signed(register_file[22]), $signed(register_file[23]),
                  "r24=%1d, r25=%1d, r26=%1d, r27=%1d, r28=%1d, r29=%1d, r30=%1d, r31=%1d,\n",
                  $signed(register_file[24]), $signed(register_file[25]), $signed(register_file[26]), $signed(register_file[27]),
                  $signed(register_file[28]), $signed(register_file[29]), $signed(register_file[30]), $signed(register_file[31]),
                  "===================="
                );
                reg_error = 1;
              end
              $display("(your value)    r%1d:%1d", i, $signed(cpu.RF.Reg_File[i]));
            end
            wa = 1;
          end
        end
        for (i = 0; i < 32; i = i + 1) begin
          if (cpu.DM.memory[i] != memory[i]) begin
            if (error == 0) begin
              $display("ERROR: instruction (%1s) fail", instr_name);
              $display("instruction: %1b", instruction);
              error = 1;
            end
            if (cpu.DM.memory[i] !== memory[i]) begin
              if (mem_error == 0) begin
                $display("(correct value)");
                $display(
                  "====== Memory ======\n",
                  " m0=%1d,  m1=%1d,  m2=%1d,  m3=%1d,  m4=%1d,  m5=%1d,  m6=%1d,  m7=%1d,\n",
                  $signed(memory[0]), $signed(memory[1]), $signed(memory[2]), $signed(memory[3]),
                  $signed(memory[4]), $signed(memory[5]), $signed(memory[6]), $signed(memory[7]),
                  " m8=%1d,  m9=%1d, m10=%1d, m11=%1d, m12=%1d, m13=%1d, m14=%1d, m15=%1d,\n",
                  $signed(memory[8]), $signed(memory[9]), $signed(memory[10]), $signed(memory[11]),
                  $signed(memory[12]), $signed(memory[13]), $signed(memory[14]), $signed(memory[15]),
                  "m16=%1d, m17=%1d, m18=%1d, m19=%1d, m20=%1d, m21=%1d, m22=%1d, m23=%1d,\n",
                  $signed(memory[16]), $signed(memory[17]), $signed(memory[18]), $signed(memory[19]),
                  $signed(memory[20]), $signed(memory[21]), $signed(memory[22]), $signed(memory[23]),
                  "m24=%1d, m25=%1d, m26=%1d, m27=%1d, m28=%1d, m29=%1d, m30=%1d, m31=%1d,\n",
                  $signed(memory[24]), $signed(memory[25]), $signed(memory[26]), $signed(memory[27]),
                  $signed(memory[28]), $signed(memory[29]), $signed(memory[30]), $signed(memory[31]),
                  "===================="
                );
                mem_error = 1;
              end
              $display("(your value)    m%1d:%1d", i, $signed(cpu.DM.memory[i]));
            end
            wa = 1;
          end
        end

        if (cpu.IM.Instr_Mem[pc>>2] == 32'd0 || wa == 1) begin
          if (wa == 1) begin
            $display("Break");
          end
          count = `END_COUNT;
          #(`CYCLE_TIME * 2);
        end else begin
          count = count + 1;
        end
      end

      if (testing <= `NUM_OF_TEST_R_TYPE_ADDI) begin
        if (wa == 0) score += 9;
        total_score += 9;
      end
      if (testing > `NUM_OF_TEST_R_TYPE_ADDI) begin
        if (wa == 0) score += 25;
        total_score += 25;
      end

    end
    $display("Score: %0d\/%0d \n", score, total_score);
    $finish;
  end
endmodule
