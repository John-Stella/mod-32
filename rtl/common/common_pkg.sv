`timescale 1ns / 1ps

package common_pkg;

  parameter int DATA_WIDTH = 8;
  parameter int INSTR_WIDTH = 24;

  //
  parameter int DEPTH = 256;

  parameter int REG_COUNT = 8;
  parameter int REG_ADDR_WIDTH = $log2(REG_COUNT);  // unknown if this works
  //int REG_ADDR_WIDTH = 4;

  typedef enum logic [3:0] {
    OP_NOP  = 'h0,
    OP_ADD  = 'h2,
    OP_SUB  = 'h3,
    OP_AND  = 'h4,
    OP_OR   = 'h5,
    OP_XOR  = 'h6,
    OP_IMM  = 'h7,
    OP_LOAD = 'h8,
    OP_STR  = 'hF
  } op_code_t;

  // Instr width = 24
  typedef struct packed {
    logic [3:0] op_code;
    logic [3:0] rd;
    logic [3:0] rs1;
    logic [3:0] rs2;
    logic [7:0] imm;
  } instr_t;

endpackage
