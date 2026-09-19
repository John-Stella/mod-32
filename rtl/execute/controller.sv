module controller (
    input  logic [6:0] op,
    input  logic [2:0] func3,
    input  logic       func7b5,
    input  logic       zero,
    output logic [1:0] result_src,
    output logic       mem_write,
    output logic       pc_src,
    output logic       alu_src,
    output logic       reg_write,
    output logic       jump,
    output logic [1:0] imm_src,
    output logic [2:0] alu_control
);

  logic [1:0] alu_op;
  logic       branch;

  main_decoder md (
      op,
      result_src,
      mem_write,
      branch,
      alu_src,
      reg_write,
      jump,
      imm_src,
      alu_op,
  );

  alu_decoder ad (
      op[5],
      func3,
      func7b5,
      alu_op,
      alu_control
  );

  assign pc_src = branch & zero | jump;

endmodule
