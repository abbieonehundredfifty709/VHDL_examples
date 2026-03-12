# VHDL Examples for Beginners

> **Important mindset shift:** VHDL is **not** a programming language — it is a *hardware description language*. You are not writing instructions for a CPU to execute one at a time. Instead, you are **describing physical circuits** that all exist and operate **simultaneously**. Think of it as drawing a schematic with text.

---

## Repository Structure

```
VHDL_examples/
├── hello_world.vhd            1. Your first VHDL design — entity & architecture basics
├── work/                      2. Library of reusable components (AND, OR, XOR gates)
│   ├── and_gate.vhd           2a. Minimal AND gate component
│   ├── or_gate.vhd            2b. Minimal OR gate component
│   └── xor_gate.vhd           2c. Minimal XOR gate component
├── full_adder.vhd             3. Structural design — wiring components together
├── processes.vhd              4. Concurrent vs. sequential execution & sensitivity lists
├── signals_vs_variables.vhd   5. Signals vs. variables — a crucial distinction
├── d_flip_flop.vhd            6. Clocked logic — creating memory with flip-flops
└── UART_tx_FSM.vhd            7. Finite State Machine — a real-world UART transmitter controller
```

### Suggested reading order

| Step | File(s) | Concept |
|------|---------|---------|
| 1 | `hello_world.vhd` | Entity/Architecture, continuous assignments |
| 2 | `work/and_gate.vhd`, `work/or_gate.vhd`, `work/xor_gate.vhd` | Simple gate components |
| 3 | `full_adder.vhd` | Structural design — instantiating & wiring components |
| 4 | `processes.vhd` | Processes, sensitivity lists, concurrent vs. sequential |
| 5 | `signals_vs_variables.vhd` | Signal scheduling vs. immediate variable updates |
| 6 | `d_flip_flop.vhd` | Clocked processes, flip-flops, and memory |
| 7 | `UART_tx_FSM.vhd` | Finite state machines (FSM) with Moore outputs |

---

## File-by-File Guide

### 1. `hello_world.vhd` — Your First VHDL Design

**Concepts introduced:**
- `library` and `use` declarations (importing `IEEE.STD_LOGIC_1164`)
- **Entity** — the interface (inputs and outputs, like pins on a chip)
- **Architecture** — the behavior (what the circuit *does*)
- **Continuous assignment** (`<=`) — signals are always driven, not assigned once

**What it does:**
Defines an entity `AND_GATE` with two inputs (`A`, `B`) and two outputs (`Y`, `Z`). The architecture contains two concurrent statements:
- `Y <= A AND B;` — a physical AND gate
- `Z <= A OR B;` — a physical OR gate

**Key takeaway:** Both assignments exist **at the same time** as physical hardware. There is no "line 1 runs before line 2" — both gates are always active simultaneously. This is fundamentally different from `y = a && b;` in C, which only executes when the CPU reaches that line.

---

### 2. `work/and_gate.vhd`, `work/or_gate.vhd`, `work/xor_gate.vhd` — Basic Gate Components

**Concepts introduced:**
- Minimal, reusable VHDL components
- The `work` library (the default library where your compiled designs live)

**What they do:**
Each file defines a single logic gate as a standalone entity with two inputs (`A`, `B`) and one output (`Y`):

| File | Operation |
|------|-----------|
| `and_gate.vhd` | `Y <= A AND B;` |
| `or_gate.vhd` | `Y <= A OR B;` |
| `xor_gate.vhd` | `Y <= A XOR B;` |

**Key takeaway:** In VHDL, you can create small, self-contained building blocks and then **wire them together** to build larger circuits (see `full_adder.vhd` next). This is called *structural design*.

---

### 3. `full_adder.vhd` — Structural Design (Wiring Components Together)

**Concepts introduced:**
- **Structural architecture** — building a circuit by instantiating and connecting sub-components
- **Internal signals** — wires between components (`signal s1, s2, s3`)
- **Component instantiation** — `entity work.XOR_GATE port map (...)`
- **Port mapping** — connecting signals to component ports using `=>`

**What it does:**
Implements a **1-bit full adder** by wiring together the gate components from the `work/` folder:

```
Sum  = A XOR B XOR Cin
Cout = (A AND B) OR ((A XOR B) AND Cin)
```

The circuit is built from 5 gate instances:
1. `XOR1`: computes `s1 = A XOR B`
2. `XOR2`: computes `Sum = s1 XOR Cin`
3. `AND1`: computes `s2 = A AND B`
4. `AND2`: computes `s3 = s1 AND Cin`
5. `OR1`: computes `Cout = s2 OR s3`

**Key takeaway:** Structural VHDL is like drawing a schematic — you place components and connect their ports with wires (signals). All five gates exist physically and operate in parallel.

---

### 4. `processes.vhd` — Concurrent vs. Sequential Execution

**Concepts introduced:**
- **Processes** — blocks where statements execute sequentially (top to bottom)
- **Sensitivity lists** — `process(A, B)` means "re-evaluate this block whenever `A` or `B` changes"
- **Concurrent statements** vs. **sequential statements** inside processes
- Multiple processes running in **parallel** with each other

**What it does:**
Defines three concurrent blocks that all run at the same time:

| Block | Sensitivity | Drives |
|-------|------------|--------|
| Concurrent assignment | always active | `W <= A AND B` |
| Process 1 | `A`, `B` | `Y` (with if/else logic) |
| Process 2 | `B`, `C` | `Z` (with if/else logic) |

**Key takeaways:**
- **Between processes:** everything is concurrent (parallel). Process 1 and Process 2 have no ordering relative to each other.
- **Inside a process:** statements execute sequentially, top to bottom, like a traditional programming language.
- **Sensitivity list matters:** Process 1 reacts to changes in `A` or `B`. Even though it *reads* `C` inside, a change to `C` alone will **not** wake up Process 1. Process 2 reacts to `B` or `C`, and ignores changes to `A`.

---

### 5. `signals_vs_variables.vhd` — The Signal vs. Variable Distinction

**Concepts introduced:**
- **Signals** (`signal S`) — updated **after** the process completes (scheduled with "delta delay")
- **Variables** (`variable V`) — updated **immediately**, the next line sees the new value
- The **last assignment wins** rule for signals within a process

**What it does:**
Demonstrates the critical difference with a simple example:

```
-- Variable: immediate
V := '1';
V := not V;        -- V is now '0' (immediately flipped)

-- Signal: scheduled
S <= '1';
S <= not S;        -- S reads its OLD value ('0'), so this schedules S = NOT('0') = '1'
                   -- The LAST assignment wins, so S becomes '1' after the process
```

**Key takeaway:** This is one of the **most common sources of confusion** for beginners.

| | Variable | Signal |
|---|----------|--------|
| **Update timing** | Immediately | After the process ends |
| **Read value** | Latest assigned value | Old value (from before the process started) |
| **Scope** | Local to the process | Visible across the entire architecture |
| **Hardware meaning** | Intermediate computation | A physical wire or register |

---

### 6. `d_flip_flop.vhd` — Clocked Logic and Memory

**Concepts introduced:**
- **Clocked processes** — using `rising_edge(CLK)` to create synchronous logic
- **Flip-flops** — the fundamental unit of memory in digital circuits
- The difference between **combinational logic** (no memory) and **sequential logic** (has memory)

**What it does:**
Implements a **D flip-flop**: on every rising edge of the clock (`CLK`), the output `Q` captures the value of input `D`.

```vhdl
process(CLK)
begin
    if rising_edge(CLK) then
        Q <= D;   -- This synthesizes to an actual flip-flop
    end if;
end process;
```

**Key takeaway:** In VHDL, you don't declare a variable to "store" a value like in C. Instead, you use a **clocked process** with `rising_edge()`, and the synthesis tool creates a physical **flip-flop** (a tiny memory element) in hardware. Without `rising_edge()`, you get combinational logic that has no memory.

---

### 7. `UART_tx_FSM.vhd` — Finite State Machine (Capstone Example)

**Concepts introduced:**
- **Finite State Machines (FSMs)** — the standard way to design controllers in VHDL
- **Enumeration types** for states (`type state_type is (IDLE, START, DATA, STOP)`)
- **Three-process FSM pattern** (the idiomatic VHDL approach):
  1. **State register** (clocked) — stores the current state in flip-flops
  2. **Next-state logic** (combinational) — computes the next state based on inputs
  3. **Output logic** (combinational) — computes outputs based on the current state
- **Moore machine** — outputs depend *only* on the current state, not on inputs
- **Synchronous reset**

**What it does:**
Implements the control FSM for a **UART transmitter** with four states:

```
         vld=1          bit_end=1       bit_end=1 AND word_end=1      bit_end=1
IDLE  ────────►  START  ────────►  DATA  ────────────────────────►  STOP  ────────►  IDLE
```

**State outputs (Moore):**

| State | `rdy` | `start` | `stop` | `count` | `data_count` |
|-------|-------|---------|--------|---------|--------------|
| IDLE  | 1 | 0 | 1 | 0 | 0 |
| START | 0 | 1 | 0 | 1 | 0 |
| DATA  | 0 | 0 | 0 | 1 | 1 |
| STOP  | 0 | 0 | 1 | 1 | 0 |

**Key takeaway:** This is a real-world pattern you will use in nearly every VHDL project. The three-process architecture cleanly separates concerns: one process for storing state, one for computing the next state, and one for computing outputs. Always use enumeration types for state names — never use raw bit vectors like `"00"`, `"01"`.

---

## Core Concepts Summary

### VHDL ≠ Software

| Concept | Software (C, Python, etc.) | VHDL (Hardware) |
|---------|---------------------------|-----------------|
| Execution | Sequential, line by line | Everything runs **concurrently** |
| Assignment | Immediate | Signals update after the process; continuous assignments are always active |
| Variables | Hold state naturally | Only **flip-flops** (clocked processes) create memory |
| Functions | Called and return | Entities are **physical blocks** that always exist |
| If/else | Conditional execution | Conditional **wiring** (muxes) or process control flow |

### The Two Architecture Styles

1. **Behavioral** — describe *what* the circuit does using processes, if/else, case statements (used in most files here)
2. **Structural** — describe *how* the circuit is built by wiring together sub-components (used in `full_adder.vhd`)

### Essential Syntax Reference

```vhdl
-- Library import (almost always needed)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Entity: the interface
entity MY_DESIGN is
    port (
        INPUT_1 : in  STD_LOGIC;
        OUTPUT_1 : out STD_LOGIC
    );
end MY_DESIGN;

-- Architecture: the implementation
architecture Behavioral of MY_DESIGN is
    signal internal_wire : STD_LOGIC;   -- internal signal (wire)
begin
    -- Concurrent assignment
    OUTPUT_1 <= INPUT_1;

    -- Process with sensitivity list
    process(INPUT_1)
        variable temp : STD_LOGIC;      -- local variable
    begin
        temp := INPUT_1;                -- immediate update
        internal_wire <= temp;          -- scheduled update
    end process;
end Behavioral;
```

---

## Getting Started

To simulate and test these designs, you can use one of the following open-source tools:

- **[GHDL](https://github.com/ghdl/ghdl)** — open-source VHDL simulator (command line)
- **[GTKWave](https://gtkwave.sourceforge.net/)** — waveform viewer to visualize simulation results
- **[EDA Playground](https://www.edaplayground.com/)** — free online VHDL simulation environment (no install required)

### Quick start with GHDL (example for the full adder)

```bash
# Analyze (compile) the gate components first
ghdl -a work/and_gate.vhd work/or_gate.vhd work/xor_gate.vhd

# Then analyze the full adder
ghdl -a full_adder.vhd

# Elaborate
ghdl -e FULL_ADDER

# Run simulation (you would need a testbench for meaningful output)
ghdl -r FULL_ADDER
```

---

## Further Reading

- [VHDL Reference (Doulos)](https://www.doulos.com/knowhow/vhdl/)
- [Free Range VHDL (free textbook, PDF)](https://github.com/fabriziotappero/Free-Range-VHDL-book)
- [VHDL Whiz — Tutorials & Examples](https://vhdlwhiz.com/)


