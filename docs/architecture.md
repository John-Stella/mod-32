# mod-32 v0.1 Architecture Layout


## General Info
This version of the RV32I ISA removes system-call related functions for simplicity. 

## ISA

| Instruction | Description | Syntax | Op-code | Func-3 | Func-7 | Type |
|---|---|---|---|---|---|---|
| LUI | Load upper immediate | LUI rd, imm20 | 0x37 | - | - | U |
| AUIPC | Add upper immediate to PC | AUIPC rd, imm20 | 0x17 | - | - | U |
| JAL | Jump and link | JAL rd, offset | 0x6F | - | - | J |
| JALR | Jump and link register | JALR rd, rs1, offset | 0x67 | 0x0 | - | I |
| BEQ | Branch if equal | BEQ rs1, rs2, offset | 0x63 | 0x0 | - | B |
| BNE | Branch if not equal | BNE rs1, rs2, offset | 0x63 | 0x1 | - | B |
| BLT | Branch if less than | BLT rs1, rs2, offset | 0x63 | 0x4 | - | B |
| BGE | Branch if greater or equal | BGE rs1, rs2, offset | 0x63 | 0x5 | - | B |
| BLTU | Branch if less than unsigned | BLTU rs1, rs2, offset | 0x63 | 0x6 | - | B |
| BGEU | Branch if greater or equal unsigned | BGEU rs1, rs2, offset | 0x63 | 0x7 | - | B |
| LB | Load byte | LB rd, offset(rs1) | 0x03 | 0x0 | - | I |
| LH | Load halfword | LH rd, offset(rs1) | 0x03 | 0x1 | - | I |
| LW | Load word | LW rd, offset(rs1) | 0x03 | 0x2 | - | I |
| LBU | Load byte unsigned | LBU rd, offset(rs1) | 0x03 | 0x4 | - | I |
| LHU | Load halfword unsigned | LHU rd, offset(rs1) | 0x03 | 0x5 | - | I |
| SB | Store byte | SB rs2, offset(rs1) | 0x23 | 0x0 | - | S |
| SH | Store halfword | SH rs2, offset(rs1) | 0x23 | 0x1 | - | S |
| SW | Store word | SW rs2, offset(rs1) | 0x23 | 0x2 | - | S |
| ADDI | Add immediate | ADDI rd, rs1, imm | 0x13 | 0x0 | - | I |
| SLTI | Set less than immediate | SLTI rd, rs1, imm | 0x13 | 0x2 | - | I |
| SLTIU | Set less than immediate unsigned | SLTIU rd, rs1, imm | 0x13 | 0x3 | - | I |
| XORI | XOR immediate | XORI rd, rs1, imm | 0x13 | 0x4 | - | I |
| ORI | OR immediate | ORI rd, rs1, imm | 0x13 | 0x6 | - | I |
| ANDI | AND immediate | ANDI rd, rs1, imm | 0x13 | 0x7 | - | I |
| SLLI | Shift left logical immediate | SLLI rd, rs1, shamt | 0x13 | 0x1 | 0x00 | I |
| SRLI | Shift right logical immediate | SRLI rd, rs1, shamt | 0x13 | 0x5 | 0x00 | I |
| SRAI | Shift right arithmetic immediate | SRAI rd, rs1, shamt | 0x13 | 0x5 | 0x20 | I |
| ADD | Add | ADD rd, rs1, rs2 | 0x33 | 0x0 | 0x00 | R |
| SUB | Subtract | SUB rd, rs1, rs2 | 0x33 | 0x0 | 0x20 | R |
| SLL | Shift left logical | SLL rd, rs1, rs2 | 0x33 | 0x1 | 0x00 | R |
| SLT | Set less than | SLT rd, rs1, rs2 | 0x33 | 0x2 | 0x00 | R |
| SLTU | Set less than unsigned | SLTU rd, rs1, rs2 | 0x33 | 0x3 | 0x00 | R |
| XOR | XOR | XOR rd, rs1, rs2 | 0x33 | 0x4 | 0x00 | R |
| SRL | Shift right logical | SRL rd, rs1, rs2 | 0x33 | 0x5 | 0x00 | R |
| SRA | Shift right arithmetic | SRA rd, rs1, rs2 | 0x33 | 0x5 | 0x20 | R |
| OR | OR | OR rd, rs1, rs2 | 0x33 | 0x6 | 0x00 | R |
| AND | AND | AND rd, rs1, rs2 | 0x33 | 0x7 | 0x00 | R |

\**Removed system call functions `FENCE` `EBREAK` `ECALL` for early implimentation*

## Registers
RV32I requires 32 registers of width 32bits, `XLEN=32`. Register declaration is prepended with an `x` for consistancy with the RV32I specification. 

`x0` - reserved as a hardwired Zero.
`x1` - reserved as call return address
`x2` - reserved as stack pointer
`x5` - reserved as alternate link register?

A separate register called the Program Counter, `PC`, tracks the current instruction address.

## Memory
Instruction and Data memory will be assumed as separate interfaces, both spaning 2^32 address space. Addresses access 1 byte of data, where words span 4 a addresses. Memory is stored in little-endian format.
```asm
0x0000_0000 - 0x0000_FFFF | Program / instruction RAM

0x1000_0000 - 0x1000_FFFF | Data RAM

0x8000_0000 - 0x8000_0FFF | Memory-mapped I/O
```
Loads return 32-bit aligned word: (in SV)

`aligned_address = {dmem_addr[31:2], 2'b00}`

`BYTE_SEl` is a 2-bit control used to select the byte out of the loaded word at adrress 

`lb rd, BYTE_SEL(rs)`

### Memory write lanes???
The `dmem_wstrb[3:0]` signal is very useful.

Each bit corresponds to one byte lane:
```asm
wstrb[0] -> bits  7:0
wstrb[1] -> bits 15:8
wstrb[2] -> bits 23:16
wstrb[3] -> bits 31:24
```
For example:

`sw x5, 0(x6)`

would produce:

`wstrb = 1111`

while:

`sb x5, 1(x6)`

could produce:

`wstrb = 0010`

and:

`sh x5, 2(x6)`

could produce:

`wstrb = 1100`

This closely resembles the byte-enable mechanisms you'll later see on real buses and BRAM interfaces.