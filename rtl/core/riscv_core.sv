module riscv_core (
    input  logic        clk,
    input  logic        rst,
    output logic [31:0] pc,
    input  logic [31:0] instr,
    output logic        mem_write,
    output logic [31:0] alu_result,
    output logic        write_data,
    input  logic [31:0] read_data
);

  logic alu_src, reg_write, jump, zero;
  logic [1:0] result_src, imm_src;
  logic [1:0] alu_control;

  controller c (
      instr[6:0],
      instr[14:12],
      instr[30],
      zero,
      result_src,
      mem_write,
      pc_src,
      alu_src,
      reg_write,
      jump,
      imm_src,
      alu_control
  );

  datapath dp (
      clk,
      rst,
      result_src,
      pc_src,
      alu_src,
      reg_write,
      imm_src,
      alu_control,
      zero,
      pc,
      instr,
      alu_result,
      write_data,
      read_data
  );

endmodule
