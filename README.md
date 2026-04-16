# Hack Computer System from Scratch

This repository contains my implementation of a 16-bit computer architecture constructed entirely from logic gates, specifically developed for the **DA2304 Computer Systems** coursework. The hardware modules were built sequentially from foundational logic components. The project is separated into hardware and software steps, closely mapping the concepts taught in the *Nand to Tetris* curriculum but extending the requirements.

## Overview of Projects

### 1. [01-Memory-and-ALU](./01-Memory-and-ALU)
This hardware module entails the construction of the CPU's memory units (ranging from fundamental Bit registers to robust `RAM16K` configurations) and an extended Arithmetic Logic Unit (ALU). The standout feature of this milestone is the modification of the classic ALU to include an **$O(1)$ Hardware Multiplier** utilizing a **Wallace Tree** multiplier paradigm (reducing gate delays drastically compared to naive addition loops or simple ripple-carry blocks).

### 2. [02-Assembler-and-Matrix](./02-Assembler-and-Matrix)
Operating on the software side, this milestone features a completely refactored **Python Assembler** tailored for the Hack machine language. It accurately processes pseudo-commands, manages custom variables across symbol tables, and encodes `.asm` files directly into binary `.hack` files. It also includes an advanced demonstration application: standard $3 \times 3$ Matrix Multiplication written natively in Hack Assembly mapping array traversal inside limited memory addressing space.

## Architecture

The system operates conceptually via a Von Neumann architecture, featuring:
- **Instruction Memory**: Read-only ROM fetching instructions based on a Program Counter.
- **ALU**: Executing computations based on specified dynamic control bits (`zx`, `nx`, `zy`, `ny`, `f`, `no`).
- **Data Memory**: RAM layout mapped tightly to specific variables and system boundaries (A register vs M register).

---
*Authored for DA2304 Computer Systems Engineering.*
