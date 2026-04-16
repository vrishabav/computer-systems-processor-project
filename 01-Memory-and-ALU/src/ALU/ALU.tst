load ALU.hdl,
output-file ALU.out,
compare-to ALU.cmp,
output-list x%D1.6.1 y%D1.6.1 zx%B2.1.2 nx%B2.1.2 zy%B2.1.2 ny%B2.1.2 f%B2.1.2 no%B2.1.2 out%D1.6.1 zr%B2.1.2 ng%B2.1.2;

// showing multiplier does not impact existing operations

set x 17, set y 3;

// 0
set zx 1, set nx 0, set zy 1, set ny 0, set f 1, set no 0, eval, output;
// 1
set zx 1, set nx 1, set zy 1, set ny 1, set f 1, set no 1, eval, output;
// -1
set zx 1, set nx 1, set zy 1, set ny 0, set f 1, set no 0, eval, output;
// x
set zx 0, set nx 0, set zy 1, set ny 1, set f 0, set no 0, eval, output;
// y
set zx 1, set nx 1, set zy 0, set ny 0, set f 0, set no 0, eval, output;
// !x
set zx 0, set nx 0, set zy 1, set ny 1, set f 0, set no 1, eval, output;
// !y
set zx 1, set nx 1, set zy 0, set ny 0, set f 0, set no 1, eval, output;
// -x
set zx 0, set nx 0, set zy 1, set ny 1, set f 1, set no 1, eval, output;
// -y
set zx 1, set nx 1, set zy 0, set ny 0, set f 1, set no 1, eval, output;
// x+1
set zx 0, set nx 1, set zy 1, set ny 1, set f 1, set no 1, eval, output;
// y+1
set zx 1, set nx 1, set zy 0, set ny 1, set f 1, set no 1, eval, output;
// x-1
set zx 0, set nx 0, set zy 1, set ny 1, set f 1, set no 0, eval, output;
// y-1
set zx 1, set nx 1, set zy 0, set ny 0, set f 1, set no 0, eval, output;
// x+y
set zx 0, set nx 0, set zy 0, set ny 0, set f 1, set no 0, eval, output;
// x-y
set zx 0, set nx 1, set zy 0, set ny 0, set f 1, set no 1, eval, output;
// y-x
set zx 0, set nx 0, set zy 0, set ny 1, set f 1, set no 1, eval, output;
// x&y
set zx 0, set nx 0, set zy 0, set ny 0, set f 0, set no 0, eval, output;
// x|y
set zx 0, set nx 1, set zy 0, set ny 1, set f 0, set no 1, eval, output;


// multiplier functionality (MUL_UPPER = 010111)
set zx 0, set nx 1, set zy 0, set ny 1, set f 1, set no 1;
// Checking upper bits of previous tests
set x 5, set y 6, eval, output;
set x 1234, set y 0, eval, output;
set x -4, set y 3, eval, output;
set x -5, set y -5, eval, output;

// multiplier functionality for full 32 bits
// 20000 * 100 = 2,000,000
set x 20000, set y 100;
// Fetch Lower 16 bits
set zx 0, set nx 1, set zy 0, set ny 1, set f 1, set no 0, eval, output;
// Fetch Upper 16 bits
set zx 0, set nx 1, set zy 0, set ny 1, set f 1, set no 1, eval, output;