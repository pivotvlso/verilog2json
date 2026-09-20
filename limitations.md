# verilog2json: Known Limitations

This document tracks the currently known parser limitations and unsupported Verilog/SystemVerilog syntaxes in the `verilog2json` conversion tool.

## 1. Unpacked Arrays
The tool currently relies on regex to find variable names by assuming they appear at the absolute end of the declaration string before the semicolon (e.g., `([A-Za-z][A-Za-z0-9_]*)\s*$`). 
Because of this, declaring **unpacked arrays** where brackets appear *after* the variable name will crash the parser.

**Fails:**
```verilog
wire unpacked_array [0:3];
```

## 2. Supported Data Types
The `ModulePort::populate_port_varga` subroutine explicitly expects declarations to use either the `wire` or `reg` keywords. If a module port or local variable uses a different Verilog/SystemVerilog data type, the parser throws an `Unknown bareword` or `Missing port declaration` error.

**Fails:**
```verilog
real real_val = 1.23;
time t_val = 1ns;
integer int_val = 1234;
logic [7:0] sv_logic;
```

## 3. Real and Time Literals
Numeric literal parsing (`convert_to_binary`) is strictly calibrated for standard integer-based literal expressions (binary, hex, decimal, octal).
Floating point numbers and SystemVerilog time literals will not be evaluated and may corrupt JSON output or cause string-matching failures.

**Fails:**
```verilog
wire [63:0] float_val = 1.23;
wire [63:0] float_exp = 123.4e-2;
wire [63:0] time_val = 2ns;
```

## 4. Array Initialization Literals
The tool does not natively support SystemVerilog unpacked array initialization syntax. Because it relies heavily on simple regex splitting and matching, nested brackets and ticks confuse the parser's logic structure.

**Fails:**
```verilog
wire [7:0] my_array [0:1] = '{ 8'hAA, 8'hBB };
```

## 5. Line-by-Line Parsing Structure
Because `ModulePort.pm` parses files using a line-by-line (`chomp($line1)`) state machine, highly condensed inline declarations or declarations aggressively spanning multiple lines without clean delimiter structures are prone to tripping up the regex matching.

**Recommended Workaround:**
Always declare one heavily delimited variable per line (ending strictly with `;`).
