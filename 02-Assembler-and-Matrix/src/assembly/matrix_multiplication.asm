// Matrix A is in row-major order
// Matrix B is in column-major order

// Base Addresses (Assuming matrices are loaded here statically via test scripts)
@100
D=A
@A_base   // Matrix A begins at RAM[100]
M=D

@110
D=A
@B_base   // Matrix B begins at RAM[110]
M=D

@120
D=A
@C_idx   // Matrix C begins at RAM[120] and index increments as multiplication is carried out
M=D


// Hardcoding Matrix A with values 1 to 9
@100
D=A
@init_ptr
M=D
@init_val
M=1
@9
D=A
@init_counter
M=D
(INIT_A_LOOP)
@init_val
D=M
@init_ptr
A=M
M=D
@init_val
M=M+1
@init_ptr
M=M+1
@init_counter
MD=M-1
@INIT_A_LOOP
D;JGT


// Hardcoding Matrix B with values all 2s
@110
D=A
@init_ptr
M=D
@9
D=A
@init_counter
M=D
(INIT_B_LOOP)
@2
D=A
@init_ptr
A=M
M=D
@init_ptr
M=M+1
@init_counter
MD=M-1
@INIT_B_LOOP
D;JGT



// Outer loop for iterating over rows of A (i goes from 0 to 2)

@i
M=0
@A_base
D=M
@rowA_start   // Keeps track of where the current row in Matrix A begins
M=D

(LOOP_I)
@i
D=M
@3
D=D-A
@END   // If i == 3 matrix multiplication is completed
D;JEQ


// Middle loop to iterate over columns of B (j goes from 0 to 2)

@j
M=0
@B_base
D=M
@colB_start   // Keeps track of where the current column in Matrix B begins
M=D

(LOOP_J)
@j
D=M
@3
D=D-A
@END_J   // If j == 3, move to the next row of Matrix A
D;JEQ


// Inner loop for dot products (k goes from 0 to 2)

@k
M=0
@sum
M=0
@rowA_start
D=M
@pA   // pointer iterating through A's rows
M=D
@colB_start
D=M
@pB   // pointer iterating through B's columns
M=D

(LOOP_K)
@k
D=M
@3
D=D-A
@END_K   // if k == 3 dot product is complete
D;JEQ

// writing A[i, k] into R0
@pA
A=M
D=M
@R0
M=D

// writign B[k, j] into R1
@pB
A=M
D=M
@R1
M=D

// Call Multiplication
@MULT
0;JMP
(MULT_DONE)

// Accumulate product: sum = sum + R2
@R2
D=M
@sum
M=D+M

// Efficient memory traversal (offset of 1)
@pA
M=M+1
@pB
M=M+1

// Increment k
@k
M=M+1

@LOOP_K
0;JMP

(END_K)
// Store the completed dot product into Matrix C
@sum
D=M
@C_idx
A=M
M=D

// Increment C pointer for the next resulting element
@C_idx
M=M+1

// Advance to the next column in Matrix B i.e. jump by column width 3
@3
D=A
@colB_start
M=D+M
@j
M=M+1

@LOOP_J
0;JMP

(END_J)
// Advance to the next row in Matrix A i.e. jump by row width 3
@3
D=A
@rowA_start
M=D+M
@i
M=M+1

@LOOP_I
0;JMP

(END)
@END
0;JMP


// Multiplication using naive repeated addition

(MULT)
@R2
M=0   // R2 = 0 (Initialize product)

@R1
D=M
@MULT_END
D;JEQ   // If R1 (multiplier counter) is 0 skip to end

@MULT_POS
D;JGT   // If R1 is positive, no issue

// If R1 < 0, we negate both R0 and R1 (-R0*-R1 = R0*R1)
@R0
M=-M
@R1
M=-M

(MULT_POS)
(MULT_LOOP)
@R0
D=M
@R2
M=D+M   // update R2 = R2 + R0

@R1
M=M-1   // Decrement multiplier (R1)
D=M
@MULT_LOOP
D;JGT   // Repeat loop if R1>0

(MULT_END)
@MULT_DONE
0;JMP   // return to caller