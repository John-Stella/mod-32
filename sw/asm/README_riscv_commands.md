# RISC-V CPU Toolchain Commands

Common GNU RISC-V commands for building and inspecting programs for an RV32I CPU.

## Toolchain

On Arch Linux:

```bash
sudo pacman -S riscv64-elf-gcc riscv64-elf-binutils
```

Optional bare-metal C library:

```bash
sudo pacman -S riscv64-elf-newlib
```

Verify installation:

```bash
riscv64-elf-gcc --version
riscv64-elf-as --version
riscv64-elf-ld --version
riscv64-elf-objdump --version
```

---

## Assemble an RV32I Assembly File

```bash
riscv64-elf-as -march=rv32i program.S -o program.o
```

Input:

```text
program.S
```

Output:

```text
program.o
```

---

## Link an Object File

Place the `.text` section at address `0x00000000`:

```bash
riscv64-elf-ld     -m elf32lriscv     -Ttext=0x00000000     program.o     -o program.elf
```

For multiple object files:

```bash
riscv64-elf-ld     -m elf32lriscv     -Ttext=0x00000000     startup.o main.o functions.o     -o program.elf
```

---

## Link Using a Linker Script

```bash
riscv64-elf-ld     -T linker.ld     program.o     -o program.elf
```

---

## Disassemble an ELF File

```bash
riscv64-elf-objdump -d program.elf
```

Show registers as `x0`, `x1`, `x2`, etc.:

```bash
riscv64-elf-objdump -d -M numeric program.elf
```

Save disassembly to a file:

```bash
riscv64-elf-objdump -d -M numeric program.elf > program.dump
```

---

## Inspect ELF Information

Show ELF headers:

```bash
riscv64-elf-readelf -h program.elf
```

Show sections:

```bash
riscv64-elf-readelf -S program.elf
```

Show symbols:

```bash
riscv64-elf-readelf -s program.elf
```

Show program headers and memory segments:

```bash
riscv64-elf-readelf -l program.elf
```

---

## Convert ELF to Raw Binary

```bash
riscv64-elf-objcopy -O binary program.elf program.bin
```

Inspect the binary:

```bash
hexdump -C program.bin
```

---

## Convert ELF to Intel HEX

```bash
riscv64-elf-objcopy -O ihex program.elf program.hex
```

---

## Compile C for RV32I

Compile only:

```bash
riscv64-elf-gcc     -march=rv32i     -mabi=ilp32     -ffreestanding     -c main.c     -o main.o
```

Compile with optimizations disabled:

```bash
riscv64-elf-gcc     -march=rv32i     -mabi=ilp32     -O0     -ffreestanding     -c main.c     -o main.o
```

---

## Compile and Link Bare-Metal C

```bash
riscv64-elf-gcc     -march=rv32i     -mabi=ilp32     -nostdlib     -nostartfiles     -T linker.ld     startup.S main.c     -o program.elf
```

Useful options:

```text
-march=rv32i       Target the RV32I ISA
-mabi=ilp32        Use the 32-bit integer ABI
-O0                Disable optimization
-ffreestanding     Do not assume a hosted OS environment
-nostdlib          Do not link the standard C library
-nostartfiles      Do not use standard startup files
-T linker.ld       Use a custom linker script
```

---

## Common Build Flow

```bash
# 1. Assemble
riscv64-elf-as -march=rv32i program.S -o program.o

# 2. Link
riscv64-elf-ld     -m elf32lriscv     -Ttext=0x00000000     program.o     -o program.elf

# 3. Inspect/disassemble
riscv64-elf-objdump -d -M numeric program.elf

# 4. Save disassembly
riscv64-elf-objdump -d -M numeric program.elf > program.dump

# 5. Generate raw binary
riscv64-elf-objcopy -O binary program.elf program.bin

# 6. Inspect bytes
hexdump -C program.bin
```

---

## Useful Linux Commands

List files:

```bash
ls
ls -lh
```

Change directory:

```bash
cd path/to/project
cd ..
```

Create directories:

```bash
mkdir build
```

Remove build files:

```bash
rm program.o program.elf program.bin
```

Remove an entire build directory:

```bash
rm -rf build/
```

Create an empty file:

```bash
touch test.S
```

View a text file:

```bash
cat program.dump
less program.dump
```

Find a command:

```bash
which riscv64-elf-gcc
```

Search command history:

```bash
history | grep riscv
```

---

## Suggested Project Layout

```text
cpu/
├── rtl/
├── sim/
├── software/
│   ├── test.S
│   ├── main.c
│   └── linker.ld
├── build/
└── README.md
```

A typical build might produce:

```text
test.S
  |
  v
test.o
  |
  v
test.elf
  |------------------|
  v                  v
test.dump          test.bin
                       |
                       v
                 RTL simulation
```
