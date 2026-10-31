# ARM-CPU-SystemVerilog

An ARM-inspired 32-bit CPU written in SystemVerilog. It implements a small subset of the ARMv4 instruction set (data processing, load/store and branch) with every instruction conditional, and each block is verified with a self-checking testbench in ModelSim.

This is the hardware follow-up to my [8-bit CPU simulator in Python](https://github.com/Mysticz11/8-bit-CPU-Simulation): I prototyped the architecture in software first, then redesigned it as ARM-style RTL.

## Status

Work in progress. Building bottom-up, one tested block at a time.

- [x] Architecture specs and general design
- [x] ALU with NZCV flags + testbench
- [x] Register file (16 x 32-bit, 2 read ports, 1 write port) + testbench
- [x] Condition logic (16 ARM condition codes) + testbench
- [ ] Flag register (written, testbench in progress)
- [ ] Immediate generator
- [ ] Instruction and data memories
- [ ] Control unit / decoder
- [ ] Top level (`cpu_top`), single-cycle datapath
- [ ] Programs assembled with the GNU ARM toolchain (countdown, load/store)

## Architecture (planned)

- 32-bit data and instructions, fixed-width, load/store architecture
- Single-cycle: one instruction per clock
- Separate instruction and data memories (Harvard-style simplification)
- Registers R0-R14, PC held separately; flags N, Z, C, V
- Every instruction is conditional (`cond` field)
- Subset: AND, EOR, SUB, ADD, CMP, ORR, MOV, LDR, STR, B
- No shifter or BL in the MVP (listed as future work).

## Verification

Every module has a self-checking testbench that prints a pass/fail summary.

- **ALU:** table-driven tests of results and flags, including carry-out, signed overflow, borrow and zero-result edge cases.
- **Register file:** reset, write-then-read on both ports, write-enable gating and R0 behaving like any other register.
- **Condition logic:** the ALU is run as CMP and its real flags feed the condition logic, then each condition is compared with SystemVerilog's own `==`, `<` and `$signed(...)` operators over edge-case and random operands. This cross-checks the ALU's carry and overflow flags as well. The testbench caught a latch bug in the first version of the condition logic.

## Running the tests

Requires ModelSim (the Intel/Altera edition works).

1. Compile all the `.sv` files in `RTL/` (Compile > Compile...).
2. Start a simulation (Simulate > Start Simulation), expand the `work` library and choose a testbench: `alu_tb`, `regfile_tb` or `cond_check_tb`.
3. In the Transcript window, type `run -all`. Each testbench prints a pass/fail summary when it finishes.

There is another way to do this through commands, but I prefer this process.

## Repository layout

```
RTL/      design and testbench files (*.sv, *_tb.sv)
SPEC.md   architecture specification
```

## Tools

SystemVerilog, ModelSim (simulation), Quartus (synthesis checks).

## Future work

Barrel shifter, BL/BX, more data-processing opcodes (ADC, SBC, TST and others), byte loads/stores, pre/post-index addressing, LDM/STM, PC as R15, and a multi-cycle or pipelined core. End goal is to implement this onto a FPGA and connect it to a display.
