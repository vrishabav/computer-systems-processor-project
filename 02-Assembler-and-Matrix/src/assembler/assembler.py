import os
import argparse
from parser import Parser
from code import Code
from symbol_table import SymbolTable


def assemble(filepath):
    symbol_table = SymbolTable()
    
    # First pass to record labels
    parser = Parser(filepath)
    rom_address = 0
    while parser.hasMoreCommands():
        parser.advance()
        if parser.instructionType() == 'L_COMMAND':
            symbol_table.addEntry(parser.symbol(), rom_address)
        else:
            rom_address += 1

    # Second pass to translate and resolve variables
    parser = Parser(filepath)
    output_lines = []
    ram_address = 16   # for custom variables

    while parser.hasMoreCommands():
        parser.advance()
        instr_type = parser.instructionType()

        if instr_type == 'A_COMMAND':
            symbol = parser.symbol()
            if symbol.isdigit():
                address = int(symbol)
            else:
                if not symbol_table.contains(symbol):
                    symbol_table.addEntry(symbol, ram_address)
                    ram_address += 1
                address = symbol_table.GetAddress(symbol)

            binary_inst = format(address, '016b')
            output_lines.append(binary_inst)

        elif instr_type == 'C_COMMAND':
            c_comp = Code.comp(parser.comp())
            c_dest = Code.dest(parser.dest())
            c_jump = Code.jump(parser.jump())

            binary_inst = f'111{c_comp}{c_dest}{c_jump}'   # as per the Hack syntax convention
            output_lines.append(binary_inst)

    # Saving output
    out_filepath = os.path.splitext(filepath)[0] + '.hack'
    with open(out_filepath, 'w') as file:
        file.write('\n'.join(output_lines) + '\n')
    print(f'Assembly successful. Output saved to {out_filepath}')


if __name__ == '__main__':
    arg_parser = argparse.ArgumentParser(description='Assemble Hack assembly code to machine code.')
    arg_parser.add_argument('filepath', help='Path to the .asm file to be processed.')
    args = arg_parser.parse_args()
    
    assemble(args.filepath)
