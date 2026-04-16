# Tutorial 2: The Hack Assembler and Matrix Operations Report

## Building the Assembler
The architecture I divided into three core modules:

### Parser Module
Takes in the input code and breaks each assembly command into its components (fields and symbols). It also removes all white space and comments.
- **Constructor/initializer:** Opens the input file and initializes Parser
- **hasMoreLines():** A boolean checker which declares if there are more commands/lines left in the input
- **advance():** Reads the next command from the input and makes it the current command. Only called if hasMoreLines() == True
- **instructionType():** Returns the type of the current command (A_COMMAND, C_COMMAND, L_COMMAND)
- **symbol():** Returns the symbol or decimal Xxx of the current command. Called only when the command type is A_COMMAND or L_COMMAND.
- **dest(), comp(), jump():** Returns the respective mnemonics in the current C-command.

### Code Module
Translates the Hack assembly language mnemonics into the corresponding 16-bit binary representations, according to the set of predefined rules.
- **dest(mnemonic):** Takes the string mnemonic and returns its 3-bit binary code.
- **comp(mnemonic):** Takes the string mnemonic and returns its 7-bit binary code.
- **jump(mnemonic):** Takes the string mnemonic and returns its 3-bit binary code.

### SymbolTable Module
This module maintains the correspondence between symbolic labels and their numeric memory addresses.
- **Constructor:** Creates a new, empty symbol table.
- **addEntry(symbol, address):** Adds the string symbol and its integer address pair to the table.
- **contains(symbol):** Boolean indicating whether the symbol table currently contains the given symbol.
- **GetAddress(symbol):** Returns integer address associated with the given symbol.

Custom variable symbols i.e. any symbol that is not predefined and not a label declaration, is mapped to consecutive memory locations starting from RAM address 16 onwards.

## 3x3 Matrix Multiplication in Hack Assembly
Since each 3x3 matrix contains 9 elements (i.e. 9 16-bit words), I need 9 16-bit registers per matrix. Since there are 3 matrices, I need a total of 27 registers in the memory.

### Multiplication Implementation Options
The naive approach is just to have a repeated sum i.e. for x*y, have a running sum, adding x to it y times. However this ends up with a time complexity of O(y).
The better approach I took, especially considering this is binary multiplication, is to consider the multiplication as a bit-shift. So, I iterate through the bits of y, and if I come across a 1, I add a shifted version of x (to the degree of that bit of y) to the total sum. This bit-shift can be manually implemented using `D=D+M`. I maintain a variable starting at 1 and doubling at each iteration (1, 2, 4, 8...). I use the bitwise AND operator (`D=D&M`) to check if the current bit of y is 1.

### Matrix Initialization
**Static Initialization:** I can write the explicit A and C instructions at the beginning of the program to load constants into the appropriate memory addresses (e.g. `@5 D=A @A_00 M=D`). But in practice, especially when working with the CPU Emulator, I shouldn't hardcode large datasets into the `.asm` file. Instead, I keep the assembly code purely for logic and use a Test Script (`.tst` file) to statically inject values directly into the RAM before the program runs.

**Dynamic Initialization:** The program populates the matrices while it is executing. To do this efficiently without writing 18 separate input blocks, I use pointers and a `(LOOP)`. First I allocate a pointer for the start of Matrix A and Matrix B. Then I read the dynamic input into the D register, go to the address stored in the current pointer, store D in that memory location, increment the pointer by 1 to point to the next matrix cell and decrement the loop counter and repeat until the matrix is full. This won't work perfectly if I want to use live keyboard input without two loops (to wait for key press and then key release), because the CPU executes millions of cycles per second and would execute all 9 loop iterations instantly.

## Memory Layout and Efficiency
Yes, the layout does affect the efficiency of my program. To compute the dot product for a single cell in the resulting Matrix C, I must iterate through a row of Matrix A and a column of Matrix B.

If Matrix A is in row-major order, the elements of its rows are stored sequentially in memory. If Matrix B is also in row-major order, the elements of its columns are separated by an offset of matrix width (here offset is 3). However, if Matrix B is in column-major order, the elements of its columns are stored sequentially. Since there is no cache here, efficiency is not about "cache misses"; it is entirely about instruction count.

In the innermost assembly loop, I must update my pointers to fetch the next values. If a matrix is laid out so I access it sequentially, incrementing the pointer takes only 2 instructions (2 clock cycles):
```
@ptrA
M=M+1
```
But if I store Matrix B in row-major order, accessing its columns requires jumping ahead by 3 memory addresses. This requires 4 instructions (4 clock cycles):
```
@3
D=A
@ptrB
M=M+D
```
Therefore, for optimal efficiency, I store Matrix A in row-major order and Matrix B in column-major order. This allows both iterators in the innermost dot-product loop to simply increment their pointers by 1 (`M=M+1`), saving 2 instructions per multiplication step. Over the 27 multiplications required for a 3x3 matrix, this reduces the total execution time of the program.
