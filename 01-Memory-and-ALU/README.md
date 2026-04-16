# Memory and Hardware Multiplier ALU

This folder contains my hardware logic implementations for Assignment 1, spanning from basic sequential logic to an advanced O(1) hardware multiplier integration.

## Memory Architecture (`src/Memory/`)
I started by implementing a foundational `Bit` register utilizing a DFF and a load signal. Then, I progressed through building a continuous 1-bit counter, a full `Register`, and ultimately scaled up to standard RAM block implementations like `RAM8`, `RAM16K`, etc.

## Hardware Multiplier ALU (`src/ALU/`)
The standard Hack architecture lacks a dedicated hardware multiplier. Because of this, multiplying two numbers requires software-level loops which takes $O(N)$ time. I upgraded the CPU by designing a customized Wallace Tree multiplier that computes products in true $O(1)$ time, and embedded it directly into the ALU.

### Wallace Tree Implementation
A Wallace tree multiplier changes how addition is performed. It utilizes a "Carry-Save" architecture:
- I used **Full Adders** to compress 3 input bits into 2 output bits in parallel columns without propagating carries horizontally.
- I used **Half Adders** for groups where only 2 bits remained.
- Finally, I used a **Carry-Lookahead Adder (CLA)** at the very end to sum the final two rows in parallel.

This replaces 15 slow, carry-propagating sequential row additions with 6 fast compression stages.

### Custom Control Encoding
The Hack ALU natively supports 18 instructions using 6 control bits (`zx, nx, zy, ny, f, no`). I integrated the multiplier without overlapping these instructions by mapping `x*y` to two mathematically unmapped bitwise sequences. Because multiplying two 16-bit words outputs a 32-bit product, I split the retrieval to fit the 16-bit register limits:
- `MUL_LOWER` (`010110`)
- `MUL_UPPER` (`010111`)

## Testing
Please use the Nand2Tetris Hardware Simulator. Load `ALU.tst` and `ALU.cmp` to verify that my custom multiplier integration does not impact the 18 pre-existing ALU functions and successfully matches the outputs.
