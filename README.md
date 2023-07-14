# x86-avg-calculator

Simple 8088 assembly program to calculate summation and the average of input variables.
It uses TASM to Assemble and runs under DOSbox for the architecture emulation
___

# Configuration

VsCode:
    Install the following Extensions:
    1. .run
    2. markdownlint
    3. x86 and x86_64 assembly
    
configuration files are already set for VsCode, select your platform (windows / Linux) from the settings file inside the .vscode folder.
**If on Linux make sure to install DOSBox.

Others:
    this program uses TASM as an assembler, to assemble it manually make sure you have the TASM.EXE and the TLINK.EXE files.

# Usage

1. Enter the number of variables
2. Enter the length of the variables (in bytes: each byte represents 2 digits).
3. Enter the variables one by one
