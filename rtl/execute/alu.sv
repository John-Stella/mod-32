module alu (
    input  logic [ 2:0] alu_control,
    output logic [31:0] alu_result,
    input  logic [31:0] src_a,
    input  logic [31:0] src_a,
    output logic        zero
);

  /*  known alu op codes = alu_control
  *   3'b000 = add
  *   3'b001 = sub
  *   3'b010 = and
  *   3'b011 = or
  *   3'b100 = x
  *   3'b101 = set less than
  */

  always_comb begin : alu
    unique case (alu_control)
      3'b000: begin
        alu_result = src_a + src_b;  // Addition
      end
      3'b001: begin
        alu_result = src_a - src_b;  // Subtraction
      end
      3'b010: begin
        alu_result = src_a & src_b;  // bitwise AND
      end
      3'b011: begin
        alu_result = src_a | src_b;  // bitwise OR
      end
      3'b100: begin
        alu_result = 'bX;  // x
      end
      3'b101: begin
        alu_result = src_a - src_b;  // set less than
      end
      3'b110: begin
        alu_result = 'bX;  // x
      end
      3'b111: begin
        alu_result = 'bX;  // x
      end
    endcase
  end

endmodule
