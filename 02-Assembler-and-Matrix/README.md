# Assembler and Matrix Code

This folder contains my software translation components, fulfilling the requirements for Tutorial 2.

## 1. Python Assembler (`src/assembler/`)
To properly parse and encode `.asm` programs into the native Hack `.hack` machine code, I divided the assembler architecture into three core modules:
- **`parser.py`**: Takes in the input code and breaks each assembly command into its components, removing all white space and comments. It uses functions like `hasMoreLines()`, `advance()`, and `instructionType()` to traverse the file.
- **`code.py`**: Translates the Hack assembly language mnemonics into the corresponding 16-bit binary representations.
- **`symbol_table.py`**: Maintains the correspondence between symbolic labels and their numeric memory addresses. Custom variable symbols are properly mapped to consecutive memory locations starting from RAM address 16 onwards.

## 2. Matrix Operations (`src/assembly/`)
I implemented a 3x3 matrix multiplication in native Hack assembly. 

To multiply without utilizing the hardware multiplier, I considered the multiplication as a bit-shift. I iterate through the bits of `y`, and if I come across a 1, I add a shifted version of `x` to the total sum. I maintain a variable starting at 1 and doubling at each iteration, checking bits using `D=D&M`.

### Efficiency through Layout
I made sure this ran with the absolute minimum instruction count possible. Therefore, for optimal efficiency, I chose to store **Matrix A in row-major order and Matrix B in column-major order**. This allows both iterators in the innermost dot-product loop to simply increment their pointers sequentially by 1 (`M=M+1`), which takes only 2 clock cycles instead of 4 clock cycles required to jump ahead by row offsets.

### Testing
Use the Nand2Tetris CPU Emulator to test the `matrix_multiplication.hack` file. Static initialization values for Matrix A and Matrix B should ideally be injected via a `.tst` test script before the program runs.
