module ALU_Ctrl (
    funct_i,
    ALUOp_i,
    ALU_operation_o,
    FURslt_o,
    sftVariable_o,
    leftRight_o,
    JRsrc_o
);

  //Instruction Format
  parameter ALU_OP_R_TYPE = 2'b00;
  parameter ALU_ADD = 2'b01;
  parameter ALU_SUB = 2'b10;
  parameter ALU_LESS = 2'b11;

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

  //ALU Operation
  parameter ADD = 4'b0000;
  parameter SUB = 4'b0001;
  parameter AND = 4'b0010;
  parameter OR = 4'b0110;
  parameter NOR = 4'b1100;
  parameter LESS = 4'b0111;

  //Src
  parameter SRC_ALU = 2'd0;
  parameter SRC_SHIFTER = 2'd1;
  parameter SRC_ZERO_FILL = 2'd2;

  parameter NO = 1'b0;
  parameter YES = 1'b1;

  //I/O ports
  input [6-1:0] funct_i;
  input [2-1:0] ALUOp_i;

  output [4-1:0] ALU_operation_o;
  output [2-1:0] FURslt_o;
  output sftVariable_o;
  output leftRight_o;
  output JRsrc_o;

  //Internal Signals
  reg [4-1:0] ALU_operation_o;
  reg [2-1:0] FURslt_o;
  reg sftVariable_o;
  reg leftRight_o;
  reg JRsrc_o;

  //Main function
  /*your code here*/
  always @(ALUOp_i, funct_i) begin
    // ALU_operation_o
    case (ALUOp_i)
      ALU_OP_R_TYPE:
      case (funct_i)
        FUNC_ADD: ALU_operation_o <= ADD;
        FUNC_SUB: ALU_operation_o <= SUB;
        FUNC_AND: ALU_operation_o <= AND;
        FUNC_OR:  ALU_operation_o <= OR;
        FUNC_NOR: ALU_operation_o <= NOR;
        FUNC_SLT: ALU_operation_o <= LESS;
        default:  ALU_operation_o <= 4'b0;
      endcase
      ALU_ADD: ALU_operation_o <= ADD;
      ALU_SUB: ALU_operation_o <= SUB;
      ALU_LESS: ALU_operation_o <= LESS;
      default: ALU_operation_o <= 4'b0;
    endcase

    // FURslt_o
    case (ALUOp_i)
      ALU_OP_R_TYPE:
      case (funct_i)
        FUNC_ADD, FUNC_SUB, FUNC_AND, FUNC_OR, FUNC_NOR, FUNC_SLT: FURslt_o <= SRC_ALU;
        FUNC_SLL, FUNC_SRL, FUNC_SLLV, FUNC_SRLV: FURslt_o <= SRC_SHIFTER;
        default: FURslt_o <= 2'b0;
      endcase
      ALU_ADD, ALU_SUB, ALU_LESS: FURslt_o <= SRC_ALU;
      default: FURslt_o <= 2'b0;
    endcase

    // leftRight_o
    case (ALUOp_i)
      ALU_OP_R_TYPE:
      case (funct_i)
        FUNC_SLL, FUNC_SLLV: leftRight_o <= NO;
        FUNC_SRL, FUNC_SRLV: leftRight_o <= YES;
        default: leftRight_o <= 1'b0;
      endcase
      default: leftRight_o <= 1'b0;
    endcase

    // sftVariable_o
    case (ALUOp_i)
      ALU_OP_R_TYPE:
      case (funct_i)
        FUNC_SLL, FUNC_SRL: sftVariable_o <= NO;
        FUNC_SRLV, FUNC_SLLV: sftVariable_o <= YES;
        default: sftVariable_o <= 1'b0;
      endcase
      default: sftVariable_o <= 1'b0;
    endcase

    // JRsrc_o
    case (ALUOp_i)
      ALU_OP_R_TYPE:
      case (funct_i)
        FUNC_JR: JRsrc_o <= YES;
        default: JRsrc_o <= 1'b0;
      endcase
      default: JRsrc_o <= 1'b0;
    endcase
  end

endmodule
