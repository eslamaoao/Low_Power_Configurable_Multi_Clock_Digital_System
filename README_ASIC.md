# Low Power Configurable Multi-Clock Digital System — RTL to GDS

A complete digital ASIC design project taken from scratch RTL all the way to a signed-off GDS file. The system receives commands over UART, processes them using an ALU or Register File, and sends results back — all across two clock domains with proper CDC handling.

> Final project for the Digital IC Design Diploma — covers the full ASIC flow end to end.

---

## What This Project Is

The goal was simple in concept but involved in execution: build a real digital system from scratch, then take it through every phase of an ASIC design flow until you have a GDS file you could hand to a fab.

The system sits between a testbench (acting as a master) and internal processing logic. The master sends commands over UART. The system decodes them, performs ALU operations or register file reads/writes, and sends the result back — all while managing two separate clock domains cleanly.

---

## System Architecture

The design spans two clock domains with three synchronizer blocks handling the boundaries between them.

```
Clock Domain 1 (REF_CLK = 50 MHz)        Clock Domain 2 (UART_CLK = 3.6864 MHz)
─────────────────────────────────         ────────────────────────────────────────
  SYS_CTRL  (main controller)               UART_RX  (serial → parallel)
  RegFile   (8×16 register file)            UART_TX  (parallel → serial)
  ALU       (arithmetic & logic)            PULSE_GEN (level → pulse converter)
  CLK_GATE  (gated clock for ALU)           Clock Divider (generates TX/RX clocks)

                    CDC Boundary
         ┌──────────────────────────────┐
         │  RST_SYNC_1  (domain 1 rst)  │
         │  RST_SYNC_2  (domain 2 rst)  │
         │  Data_Sync + ASYNC_FIFO      │
         └──────────────────────────────┘
```

---

## Blocks

### Clock Domain 1 — REF_CLK (50 MHz)

**SYS_CTRL** — The main controller. Decodes incoming UART commands and orchestrates all internal operations. Routes data between the ALU, RegFile, and UART paths.

**RegFile** — 8×16 parameterized register file. Addresses `0x0–0x3` are reserved for configuration (UART parity, prescale, clock division ratio, ALU operands). Addresses `0x4–0x15` are available for general read/write operations.

**ALU** — Supports 16 operations: addition, subtraction, multiplication, division, AND, OR, NAND, NOR, XOR, XNOR, two comparison operations (A=B, A>B), and two shift operations (A>>1, A<<1). Clock-gated for power saving.

**CLK_GATE** — Latch-based clock gate. Enables the ALU clock only when needed, controlled by SYS_CTRL.

### Clock Domain 2 — UART_CLK (3.6864 MHz)

**UART_RX** — Deserializes incoming frames. Configurable parity (enable + type) and prescale via RegFile. Outputs parallel data with a data-valid flag. Detects parity and stop-bit errors.

**UART_TX** — Serializes outgoing frames. Reads data from ASYNC_FIFO. Outputs a `Busy` signal used by PULSE_GEN.

**PULSE_GEN** — Converts the TX `Busy` level signal into a single-cycle pulse for the ASYNC_FIFO read increment.

**Clock Divider** — Generates divided clocks for UART TX and RX from the UART_CLK input. Division ratio is runtime-configurable via REG3.

### Synchronizers

**RST_SYNC** (×2) — One per clock domain. Synchronizes the asynchronous reset into each domain safely.

**Data_Sync** — Two-flop synchronizer with enable pulse generation. Moves the UART_RX output from domain 2 into domain 1 safely.

**ASYNC_FIFO** — Dual-clock FIFO bridging domain 1 (write side, REF_CLK) and domain 2 (read side, UART_CLK). Gray-coded pointers for safe CDC. FULL flag goes to SYS_CTRL, EMPTY flag goes to UART_TX.

---

## Supported Commands

| Command | Code | Frames | Description |
|---|---|---|---|
| RegFile Write | `0xAA` | 3 | Write data to a register address |
| RegFile Read | `0xBB` | 2 | Read from a register address |
| ALU Op (with operands) | `0xCC` | 4 | Load operands A & B, then execute function |
| ALU Op (no operands) | `0xDD` | 2 | Execute ALU function using existing RegFile values |

---

## ASIC Design Flow

The project was taken through every phase of a real ASIC flow:

```
Phase 1 — RTL Design
  All blocks written from scratch in Verilog. Self-checking testbench
  for integration verification.

Phase 2 — Synthesis
  Constrained using TCL scripts. Synthesized and optimized with
  Synopsys Design Compiler. Gate-level netlist generated.

Phase 3 — Static Timing Analysis
  Setup and hold violations identified and fixed on critical paths.

Phase 4 — Formal Verification
  RTL vs. netlist equivalence verified using Synopsys Formality.

Phase 5 — DFT (Design for Testability)
  Scan chains inserted for manufacturing test coverage.

Phase 6 — Physical Design (Place & Route)
  Floorplanning → placement → CTS → routing → timing closure → GDS.

Phase 7 — Post-Layout Verification
  Gate-level simulation with back-annotated delays to verify
  functional correctness after physical implementation.
```

---

## System Specifications

| Parameter | Value |
|---|---|
| REF_CLK frequency | 50 MHz |
| UART_CLK frequency | 3.6864 MHz |
| Default prescale | 32 |
| Default division ratio | 32 |
| Default parity | Even (enabled) |
| RegFile depth | 8×16 (parameterized) |
| ALU operand width | 8-bit (parameterized) |

---

## Tools Used

| Phase | Tool |
|---|---|
| RTL Design & Simulation | Verilog HDL, ModelSim / VCS |
| Synthesis | Synopsys Design Compiler |
| Formal Verification | Synopsys Formality |
| Physical Design | Cadence / Synopsys IC Compiler |

---

## Author

**Eslam Ashraf**
Electronics & Communications Engineering — Benha University

Interests: FPGA & Digital IC Design · ASIC & VLSI · Communication Systems

[![GitHub](https://img.shields.io/badge/GitHub-eslamaoao-181717?style=flat&logo=github)](https://github.com/eslamaoao)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Eslam%20Ashraf-0A66C2?style=flat&logo=linkedin)](https://linkedin.com/in/eslam-ashraf-b23692229)
