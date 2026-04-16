# Assignment 1: Hardware Logic Rationale and Report

## 1-Bit Register vs. DFF
A standard Data Flip-Flop (DFF) always outputs its previous input at the next clock cycle. But a 1-Bit Register chooses whether to preserve its state based on the load signal. If the load signal is 1, it captures the new input, but if load is 0, it ignores the input and maintains its current state across multiple clock cycles.

For the counter implementation, I only needed a D-Flip-Flop, not a full register. A continuous 1-bit counter must increment on every single clock tick, which for binary just means toggling between 0 and 1. Since the state never needs to be held, the load functionality of a register is redundant. To build it using the 1-bit `Bit` register, I hardwired the register's load pin to 1, forcing it to continuously accept the inverted output on every cycle.

## Byte-Level Access
The standard 16-bit register operates as one unit with a single load signal which updates all 16 bits at once. To achieve "Byte-Level Access" (i.e. interacting with one of the individual 8-bit registers) I must be able to selectively write to one 8-bit register without overwriting the other. Without an additional control signal and logic to distinguish between the two bytes, independent access is not possible. 
To fix this, I added an input signal for selection. This 1-bit signal acts as a steering mechanism for the load signal. By using a DMux while writing, the selection bit routes the load command specifically to either one of the 8-bit registers. While reading, the selection bit is used as the selector for a Mux which chooses one of the 2 8-bit registers.

Byte-Level Access allows for precise modification of small data (like ASCII characters) without needing to "read-modify-write" the entire word; however, this requires more control logic (address bits and DMuxes) and may take more cycles to fill a 16-bit word. Word-Level Access is much faster for large data transfers, as it moves twice the data in a single clock cycle compared to byte-wise operations. But it is inefficient for byte-specific tasks; to change 1 byte, I must load the whole word, mask the bits, and write it back.

## Memory Sizing and Routing
When using RAM8 chips which store 8 words each, the 3 lower-order bits are required as LSBs of the address. I need 64 of these RAM8 chips to reach 512 words. To select one out of 64 chips, I need 6 bits (2^6=64). These are the MSBs. Totally, the 9-bit address is split as 6 bits for selecting the chip + 3 bits for offset.
When using RAM64 chips, the 6 lower-order bits map to the RAM64's internal address (to select one of 64 words). 3 higher-order bits are used to select one of the 8 chips, since I need 8 such chips to hold 512 words. Totally, the 9-bit address is split as 3 bits for selecting the chip + 6 bits for offset.

Using a larger underlying block does not change the total number of address bits required by the system. The total number of address bits required by a memory system is determined strictly by the total number of addressable locations i.e. words in the entire memory unit, not by the size of the internal blocks. Changing the underlying block size from RAM8 to RAM64 only changes the ratio of how those 9 bits are divided between routing to a specific chip and routing inside that chip.

## Architectural Impact (Extra Credit)
Building a massive memory module using larger contiguous blocks (e.g., RAM4K) significantly reduces routing complexity, control logic, and latency, as the signal travels through fewer layers of multiplexers and demultiplexers. For AI workloads, which require streaming massive, contiguous blocks of data like matrices, larger memory blocks provide higher throughput and more proximity. Relying on many small blocks like RAM8 creates a massive structure of multiplexer trees that increase propagation delay and slow down the maximum clock frequency, ultimately increasing processing time drastically.

Using 1K RAM8 chips is vastly more costlier to design and implement for a 16KB memory than using 8 RAM1K chips. Routing 1024 individual RAM8 components needs extremely complex control wiring, massive decoding logic, and consumes significantly more physical area and power as compared to the denser and more optimized internal structure of just 8 larger RAM1K chips.

## Hardware Multiplier Architecture
A Wallace tree multiplier changes how addition is performed. Instead of adding complete rows together sequentially and propagating carries slowly, it uses a "Carry-Save" architecture to compress bits in the same column.
- **Full Adders (3:2 Compressors):** Takes 3 input bits from the same column and compresses them into 2 output bits: a sum bit and a carry bit passed to the next column. This provides the maximum compression ratio without horizontally propagating carries. It operates in constant time, and the entire stage is computed in parallel.
- **Half Adders (2:2 Compressors):** I use Half Adders when a column strictly has 2 bits remaining to be processed in a given group. If a column only has 2 bits, using a Full Adder would be a waste of hardware (requiring one input to be hardcoded to 0), so a Half Adder does the required compression with fewer logic gates, optimizing chip resources.
- When a column only has 1 bit remaining, I use an OR gate with 0 to pass the signal to the next stage. A single bit requires no mathematical reduction.
- **Final CLA:** After Stage 6 it is reduced to exactly two rows: sums and carries. I therefore add these final two rows using a Carry-Lookahead Adder, since the Wallace tree cannot reduce 2 rows to 1. If I used a Ripple Carry Adder the carry would sequentially ripple through all 32 bits, which would be a massive bottleneck. The CLA calculates the p and g signals in parallel, allowing the final addition to occur significantly faster.

### Reduction in Addition Operations
The Wallace tree does not necessarily reduce the total number of adder gates but it drastically reduces the number of sequential, dependent addition operations. In a standard 16x16 array multiplier, multiplying two 16-bit numbers generates 16 rows of partial products. A naive architecture requires 15 sequential additions. Because each addition must wait for the carry to ripple from the previous bits, the time delay scales linearly with N (O(N) delay).

By utilizing a Carry-Save architecture, I prevent carries from rippling horizontally during the reduction phases. Because Full Adders reduce 3 inputs to 2, the number of rows at each stage shrinks by a factor of roughly 2/3.
This replaces 15 slow, carry-propagating sequential row additions with 6 fast, parallel compression stages, and 1 optimized CLA addition. The Wallace tree structure reduces the internal gate-propagation delay of the addition operations from O(N) to O(log N). From the perspective of the software and the instruction set, this hardware upgrades the multiplication time complexity from the original software-level O(N) loop to a true O(1) execution.

## New Instruction Encoding
Based on the ALU integration I implemented, I needed to map the multiplication operation `x*y` to a 6-bit control that does not overlap with the standard 18 Hack instructions. Because a 16x16 multiplication natively produces a 32-bit product, and the Hack architecture is strictly limited to 16-bits, full precision is achieved by splitting the retrieval into two distinct instructions:
- `MUL_LOWER` (zx, nx, zy, ny, f, no): `010110`
- `MUL_UPPER` (zx, nx, zy, ny, f, no): `010111`

The standard Hack ALU uses only 18 out of the 64 possible combinations of these 6 control bits. These 2 combinations are mathematically unmapped to any of the required basic arithmetic or logical operations in the standard Hack specification. By rerouting my hardware to detect these exact bitwise sequences, I safely output either the lower or upper 16 bits of the multiplier.
