# verilog2json: Known Limitations

This document tracks the currently known parser limitations and unsupported Verilog/SystemVerilog syntaxes in the `verilog2json` conversion tool.

## 1. Supported Data Types
The `ModulePort::populate_port_varga` subroutine currently handles `wire`, `reg`, `logic`, `integer`, `real`, `realtime`, and `time` keywords. 

If a module port or local variable uses an unsupported net type (e.g., `wand`, `wor`, `tri`, `triand`, `trior`, `tri0`, `tri1`, `trireg`, `uwire`, `supply0`, `supply1`), the parser explicitly intercepts it and aborts with an `ERR_UNSUPPORTED_NET` diagnostic error.

**Fails:**
```verilog
wand my_net;
uwire my_uwire;
```

## 2. Real and Time Literals
Numeric literal parsing (`convert_to_binary`) is strictly calibrated for standard integer-based literal expressions (binary, hex, decimal, octal).
Floating point numbers and SystemVerilog time literals will not be evaluated and may corrupt JSON output or cause string-matching failures.

**Fails:**
```verilog
wire [63:0] float_val = 1.23;
wire [63:0] float_exp = 123.4e-2;
wire [63:0] time_val = 2ns;
```

## 3. Multiple Variables Per Line (Line-by-Line Parsing)
Because `ModulePort.pm` parses files using an end-anchored regex state machine, it DOES NOT support comma-separated list declarations on a single line (e.g., `real a, b, c;`). If multiple variables are declared on the same line, the parser will fail to extract the intermediate variables and will likely crash or yield corrupt JSON metadata.

**Fails:**
```verilog
wire [7:0] a, b, c;
real x, y = 1.23, z;
```

**Required Constraint:**
Always declare exactly **one** variable per line (ending strictly with `;`).

**Passes:**
```verilog
wire [7:0] a;
wire [7:0] b;
wire [7:0] c;
```

## 4. Strings, Escaped Characters, and System Tasks
The tool currently does not have logic to safely parse string literals (`"hello"`), escaped characters (`\n`, `\t`), or SystemVerilog system tasks (e.g., `$display`, `$finish`). These constructs will likely confuse the binary evaluator or cause the parser to crash when scanning blocks.

**Fails:**
```verilog
string my_str = "hello world\n";
initial begin
    $display("Test: %s", my_str);
end
```

## 5. Attributes
Verilog attributes using the `(* ... *)` syntax are currently unsupported. To prevent regex parsing failures and string extraction errors, the parser aggressively and silently ignores (strips out) all attributes during the initial file sanitization loop. The tool will parse the underlying logic, but any metadata contained within the attributes is lost.

## 6. Parameters and Commas
The same 1-variable-per-line parsing constraint from Section 3 also strictly applies to module-level parameters and localparams. We do not support parsing a comma-separated list of assignments in a single statement. 

## 7. Namespaces and Hierarchical Identifiers
The `verilog2json` converter does not currently support namespaces, packages, or hierarchical identifier resolution (e.g., `my_pkg::my_var` or `top.submodule.signal`). All identifiers are treated as simple, local names within their enclosing module scope. Using hierarchical paths in assignments or declarations will likely result in syntax errors or skipped expressions.

## 8. Drive and Charge Strengths
Verilog allows specifying drive strengths (e.g., `strong1`, `pull0`, `highz1`) or charge strengths (`small`, `medium`, `large`) in net declarations and continuous assignments. These strength qualifiers are strictly unsupported by the parser and will trigger fatal parsing failures (`ERR_UNKNOWN_BAREWORD`) if encountered. 

## 9. Implicit Declarations
Variables and nets must be explicitly declared before use (or explicitly mapped within the port list). The parser does not support implicit net declarations (i.e., using a wire in a structural assignment without explicitly declaring it with `wire` beforehand). All nets and variables must have a definitive declaration statement for the AST metadata generator to bind them correctly.

## 10. Unsupported Operators (Chapter 5)
The parser does not support the following operators from Chapter 5 (Table 5-1):
- Power / Exponentiation: `**`
- Arithmetic Shifts: `<<<` and `>>>`
- Concatenation and Replication: `{ }` and `{ { } }`

If the AST expression evaluator encounters these operators, it will explicitly halt parsing and throw an `ERR_UNSUPPORTED_OPERATOR` diagnostic error.


## 11. Delays in Expressions
The parser currently does not support Verilog time delay expressions (e.g., `#10` or `# (delay_value)`) within assignment statements, continuous assignments, or procedural blocks. Any delay operators encountered within an expression will likely cause string parsing corruption or trigger a diagnostic failure.

**Fails:**
```verilog
assign #10 out = in;
always @(a) begin
    #5 out = a;
    out <= #10 b;
end
```

## 12. Signed/Unsigned System Functions
The tool currently does not evaluate type-casting system functions such as `$signed()` or `$unsigned()`. Because system tasks starting with `$` are fundamentally unsupported by the expression parser (as noted in Section 4), attempting to pass variables through these casting functions will cause parsing corruption and potential diagnostic failures.

**Fails:**
```verilog
assign out = $signed(a) + $signed(b);
```
