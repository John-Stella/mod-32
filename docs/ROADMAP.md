# RV32I CPU Design Project Roadmap

A from-scratch RISC-V processor project for computer architecture and RTL/SystemVerilog practice.

## Project priorities

1. Design a correct RV32I processor.
2. Validate and synthesize the basic CPU.
3. Explore pipelining.
4. Explore microarchitectural optimizations such as caches and branch prediction.
5. Add ISA extensions or specialized accelerators.

## Project philosophy

- **Correctness before performance.** Keep a known-good reference core before introducing pipeline or memory-system complexity.
- **One architectural change at a time.** Every optimization should have measurable effects on correctness, timing, area, or performance.
- **Verification is part of the design.** Add directed and automated tests as each block is introduced.
- Preserve major checkpoints in version control so the project remains useful as a teaching/reference artifact.
- Prefer simple, readable RTL over aggressive optimization during early phases.

## Recommended initial scope

| Decision | Recommended starting point |
|---|---|
| ISA | RV32I only; machine-mode execution is sufficient for the initial core. |
| Datapath | 32-bit integer datapath, 32 x 32-bit GPRs; `x0` hard-wired to zero. |
| First microarchitecture | Single-cycle conceptual design, or a simple multi-cycle implementation if timing/structure is cleaner. |
| Memory interface | Separate instruction and data interfaces initially, with simple ready/valid or request/response semantics. |
| Privileged features | Defer CSRs, interrupts, and most exception machinery until the base CPU is stable. |
| Tooling | SystemVerilog RTL + Verilator/iverilog-class simulation + Vivado or Yosys synthesis depending on target. |
| Software | Hand-written assembly first; then use a RISC-V cross compiler/binutils for test programs. |

## Suggested repository structure

```text
riscv-cpu/
├── README.md
├── ROADMAP.md
├── docs/
│   ├── architecture.md
│   ├── memory-interface.md
│   └── verification-plan.md
├── rtl/
│   ├── core/
│   ├── execute/
│   ├── decode/
│   ├── memory/
│   └── common/
├── tb/
│   ├── unit/
│   ├── core/
│   └── programs/
├── sw/
│   ├── asm/
│   ├── linker/
│   └── tools/
├── scripts/
├── synth/
│   ├── constraints/
│   └── reports/
└── results/
    ├── waveforms/
    ├── regressions/
    └── benchmarks/
```

# Phase 0 - Architecture Definition and Tool Bring-Up

**Goal:** Freeze the smallest useful RV32I target and prove the simulation/software toolchain before writing the full CPU.

### Build
- Write a short microarchitecture specification covering PC behavior, register file, ALU, immediate generation, branches/jumps, loads/stores, and memory interfaces.
- Create an RV32I instruction/control table containing opcode/funct fields, operands, immediate type, ALU action, register writeback, memory action, and PC behavior.
- Define reset vector, memory map, little-endian behavior, alignment policy, and simulation termination.
- Verify a RISC-V GNU or LLVM toolchain capable of assembling/linking RV32I programs.
- Create a script that converts ELF/binary output into the memory initialization format used by the testbench.

### Verification / analysis
- Assemble a trivial RV32I program and inspect its disassembly.
- Load instructions into a dummy instruction memory and verify the expected words are fetched.
- Establish lint/compile commands and a one-command smoke test.

### Exit criteria
- [ ] Architecture decisions are documented.
- [ ] A known assembly program can be assembled, loaded, and observed in simulation.
- [ ] The RTL/testbench toolchain runs from a clean checkout.

# Phase 1 - Build and Unit-Test the RV32I Datapath Blocks

**Goal:** Implement reusable combinational/sequential blocks independently before integrating the processor.

### Build
- Program counter and next-PC selection.
- 32 x 32-bit register file with two read ports, one write port, and `x0` hard-wired to zero.
- ALU: ADD/SUB, shifts, signed/unsigned comparisons, XOR/OR/AND.
- Immediate generator for I, S, B, U, and J formats.
- Instruction decoder/control generation.
- Branch comparator and branch/jump target generation.
- Load/store byte-lane handling and sign/zero extension.

### Verification / analysis
- Write focused unit testbenches for the ALU, register file, immediate decoder, branch comparator, and load formatting.
- Test edge cases: `0`, `-1`, INT_MIN/MAX, shift amounts, signed vs unsigned comparisons, `x0` writes, and immediate sign extension.
- Add assertions for invariants such as `x0 == 0`.

### Exit criteria
- [ ] Every block has automated tests.
- [ ] All RV32I arithmetic/logical operations have explicit test coverage.
- [ ] Decoder behavior is traceable to the RV32I instruction table.

# Phase 2 - Integrate a Basic RV32I Core

**Goal:** Produce the first processor that can fetch and execute complete RV32I programs correctly.

### Build
- Integrate fetch, decode, execute, memory, and writeback behavior.
- Support all base RV32I instruction classes: integer ALU, immediate ALU, branches, `JAL/JALR`, `LUI/AUIPC`, loads, and stores.
- Use a simple instruction/data memory model with deterministic latency.
- Expose a retirement trace containing at least PC, instruction, destination register/value, and memory access information.
- Add a simulation-only mechanism for program pass/fail or halt.

### Verification / analysis
- Start with small directed assembly programs by instruction class.
- Run mixed programs containing loops, jumps, loads/stores, and branches.
- Compare architectural state against a reference model or instruction-set simulator where practical.
- Add RISC-V architectural tests appropriate to RV32I if compatible with the environment.

### Exit criteria
- [ ] Core correctly executes representative programs from reset to completion.
- [ ] All intended RV32I instructions are implemented and regression-tested.
- [ ] Failures can be debugged using a readable retirement trace.

# Phase 3 - Verification Hardening

**Goal:** Turn the functioning core into a design with repeatable evidence of ISA correctness.

### Build
- Create a regression runner that compiles/loads programs, runs simulation, and reports pass/fail.
- Add SystemVerilog assertions for architectural invariants and protocol behavior.
- Add randomized instruction streams after directed coverage is strong.
- Introduce differential testing against a RISC-V ISA simulator when feasible.
- Track functional coverage by instruction, branch direction, load/store width, signedness, and important edge cases.

### Verification / analysis
- Run regressions from a clean build.
- Inject intentional RTL faults to confirm that tests detect common failures.
- Check for X propagation, uninitialized state, illegal writes to `x0`, and incorrect PC alignment.

### Exit criteria
- [ ] Regression suite is automated and stable.
- [ ] Every RV32I instruction has at least one passing architectural test.
- [ ] The core can be compared against a reference architectural state/trace for nontrivial programs.

# Phase 4 - Synthesis and Baseline Characterization

**Goal:** Establish area, timing, and implementation baselines before adding performance-oriented complexity.

### Build
- Synthesize the core for a chosen FPGA family or generic standard-cell flow.
- Add realistic clock/reset constraints.
- Collect LUT/FF/BRAM/DSP usage or cell area, critical path, maximum clock estimate, and synthesis warnings.
- Identify long combinational paths and high-fanout control signals.
- Preserve reports with commit identifiers/configuration.

### Verification / analysis
- Review synthesis warnings.
- Where practical, run a post-synthesis or timing-aware smoke test.
- Confirm synthesis does not optimize away architectural state unexpectedly.

### Exit criteria
- [ ] Core synthesizes without serious warnings.
- [ ] Baseline area and timing numbers are recorded.
- [ ] Critical path is understood well enough to motivate the next architectural step.

### Stretch
- Put the baseline core on an FPGA with a tiny BRAM program and UART/GPIO signature output.

# Phase 5 - Introduce Pipelining

**Goal:** Convert the known-good core into a pipelined implementation while preserving architectural behavior.

### Build
- Start with a classic 5-stage model: IF, ID, EX, MEM, WB, unless synthesis results motivate another partition.
- Define pipeline-register contents and valid/kill semantics explicitly.
- Implement data forwarding/bypassing.
- Detect load-use and other non-forwardable hazards; insert stalls/bubbles.
- Flush wrong-path instructions on taken control transfers.
- Keep the original non-pipelined core or reference model available for differential testing.

### Verification / analysis
- Create directed RAW-hazard tests for every stage distance.
- Test branch/jump flushes, back-to-back branches, load-use hazards, and stores dependent on recent results.
- Compare retired instruction traces between baseline and pipelined cores.
- Measure CPI, clock frequency, and area versus baseline.

### Exit criteria
- [ ] Pipelined core passes the same RV32I regression suite.
- [ ] Hazards are resolved without architectural corruption.
- [ ] Performance/area/timing comparison with the baseline core is documented.

# Phase 6 - Memory Hierarchy and Cache Exploration

**Goal:** Learn how the CPU/memory boundary changes once memory is no longer a fixed-latency abstraction.

### Build
- Refactor instruction/data ports around an explicit request/response protocol with stalls.
- Add a small direct-mapped instruction cache first; then consider a data cache.
- Implement tag, valid, data arrays, hit detection, refill state machine, and replacement behavior.
- For a data cache, choose write-through vs write-back and write-allocate vs no-write-allocate.
- Define uncached/MMIO behavior separately from normal cacheable memory.

### Verification / analysis
- Unit-test hits, compulsory misses, conflicts, refills, and evictions.
- Stress pipeline stalls during cache misses.
- Measure hit rate and CPI on small benchmark loops.
- Re-synthesize and quantify BRAM/LUT/timing cost.

### Exit criteria
- [ ] CPU remains correct under variable memory latency.
- [ ] Cache behavior is independently tested.
- [ ] Performance impact is measured rather than inferred.

### Stretch
- Explore 2-way set associativity, a victim buffer, simple prefetching, or separate L1 I/D caches after the direct-mapped design is stable.

# Phase 7 - Branch Prediction and Front-End Optimization

**Goal:** Reduce control-hazard cost and study prediction accuracy versus hardware complexity.

### Build
- Establish an always-not-taken or static baseline.
- Add a small branch target buffer if useful for target prediction.
- Implement a 1-bit then 2-bit saturating-counter predictor.
- Define recovery/flush behavior carefully; prediction must never affect architectural correctness.
- Collect branch outcome and prediction statistics.

### Verification / analysis
- Test aliasing, repeated loops, alternating branches, `JAL/JALR` interactions, and misprediction recovery.
- Measure accuracy, misprediction penalty, CPI, area, and timing effects.

### Exit criteria
- [ ] Core passes full regressions with prediction enabled and disabled.
- [ ] Prediction accuracy and performance improvement are quantified.
- [ ] Misprediction recovery is covered by directed tests.

### Stretch
- Explore a return-address stack, gshare-style history, or more advanced predictors only after establishing a simple baseline.

# Phase 8 - ISA Extensions and Specialized Acceleration

**Goal:** Use the stable CPU as a platform for ISA modification, coprocessor interfaces, and hardware/software co-design.

### Build
- Choose one extension at a time and write its architectural behavior before RTL implementation.
- Natural first extension: RV32M multiply/divide, including multi-cycle implementations.
- Other options: selected bit-manipulation operations, custom packed/SIMD operations, or application-specific instructions.
- For larger accelerators, consider memory-mapped or coprocessor-style interfaces rather than forcing everything into the scalar pipeline.
- Add assembler/compiler support only as needed; custom instructions can initially be emitted using `.word`/`.insn` mechanisms.

### Verification / analysis
- Add directed ISA tests for every extension instruction.
- Verify stalls/handshakes for multi-cycle functional units.
- Benchmark a small workload before and after acceleration.
- Measure area/timing/performance tradeoffs.

### Exit criteria
- [ ] Extension behavior is documented and tested.
- [ ] Base RV32I regressions still pass.
- [ ] Acceleration benefit is demonstrated on at least one representative workload.

# Cross-Phase Verification Strategy

| Level | Purpose |
|---|---|
| Unit | ALU, decoder, immediate generator, register file, branch unit, cache controller, predictor. |
| Directed core tests | Small assembly programs designed to isolate one architectural feature or hazard. |
| ISA compliance | RV32I architectural/compliance tests or equivalent systematic instruction tests. |
| Differential | Compare retirement trace/register/memory state against a trusted RISC-V reference simulator. |
| Randomized | Constrained-random instruction sequences with reproducible seeds. |
| Synthesis/implementation | Lint, reset/protocol checks, synthesis warnings, timing, utilization, and optional FPGA execution. |

# Metrics to Track

- **Correctness:** regression pass count, instruction/feature coverage, differential mismatches.
- **Performance:** cycle count, retired instructions, CPI/IPC, branch-mispredict rate, cache hit/miss rate.
- **Timing:** target clock, achieved Fmax estimate, critical path and path category.
- **Area/resources:** LUTs, FFs, BRAMs, DSPs or equivalent synthesized cell area.
- **Complexity:** RTL/module size and number of pipeline/cache/predictor states.

# Suggested Milestone Tags

- `v0.1-toolchain` - build/simulation/software toolchain working
- `v0.2-blocks` - core datapath/control blocks unit-tested
- `v0.3-rv32i` - complete basic RV32I core running programs
- `v0.4-verified` - automated RV32I regression/reference comparison
- `v0.5-synth` - synthesized baseline with reports
- `v1.0-pipeline` - validated pipelined RV32I core
- `v1.1-cache` - cache-enabled core
- `v1.2-bpred` - branch-predicted core
- `v2.0-extension` - first ISA extension/accelerator

# Recommended First Concrete Target

A simple RV32I core that:

- runs small assembled/compiled programs;
- passes an automated instruction-level regression suite;
- produces a retirement trace suitable for comparison against a reference model; and
- synthesizes with recorded timing/resource reports.

**Do not begin pipelining until this checkpoint is stable.**

# Immediate Next Tasks

- [ ] Create the repository skeleton and commit this roadmap.
- [ ] Write `docs/architecture.md` with the initial datapath, memory interface, reset vector, and implementation assumptions.
- [ ] Create the RV32I instruction/control table.
- [ ] Bring up the assembler/compiler + binary-to-memory-image flow.
- [ ] Implement and unit-test the ALU, register file, and immediate generator.
- [ ] Build the first fetch/decode/execute loop using `ADDI` as the earliest end-to-end instruction.
- [ ] Grow instruction support incrementally while keeping every previously supported instruction in regression.
