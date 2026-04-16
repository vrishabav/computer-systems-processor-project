class Parser:
    def __init__(self, path):
        with open(path, 'r') as file:
            # basic parsing
            self.lines = []
            for line in file:
                line = line.split('//')[0].strip()
                if line:
                    self.lines.append(line)
        self.current_command = ''
        self.current_index = -1

    def hasMoreCommands(self):
        return self.current_index < len(self.lines)-1

    def advance(self):
        if self.hasMoreCommands():
            self.current_index += 1
            self.current_command = self.lines[self.current_index]

    def instructionType(self):
        if self.current_command[0] == '@':
            return 'A_COMMAND'
        elif self.current_command[0] == '(' and self.current_command[-1] == ')':
            return 'L_COMMAND'
        else:
            return 'C_COMMAND'

    def symbol(self):
        if self.instructionType() == 'A_COMMAND':
            return self.current_command[1:]
        elif self.instructionType() == 'L_COMMAND':
            return self.current_command[1:-1]
        else:
            return None

    def dest(self):
        if '=' in self.current_command:
            return self.current_command.split('=')[0]
        else:
            return 'null'

    def comp(self):
        command = self.current_command
        if '=' in command:
            command = command.split('=')[1]
        if ';' in command:
            command = command.split(';')[0]
        return command

    def jump(self):
        if ';' in self.current_command:
            return self.current_command.split(';')[1]
        return 'null'
