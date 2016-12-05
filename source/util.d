module util;
import std.stdio;
import std.algorithm.searching : startsWith;
import vm;

void dbg(size_t addr) {
    writeln("PC: ", PC, " OP_CODE: ", RAM[addr]);
    assert(RAM[addr] <= 21);
    writeln("OP_NAME: ", op_names[RAM[addr]]);
    foreach(i; 0..3) writeln(cast(char)('A' + i), ": ", RAM[addr + i + 1]);
    foreach(i ; 0..8) {
        writeln(i, " r: ", RAM[32768 + i]);
    }
    for(int i = 0; i < stack.length; ++i) {
        writeln(i, " s: ", stack[i], " ", callstack_labels.get(stack[i], ""));
    }
}

void print_callstack() {
    foreach(addr; callstack) {
        writeln(addr, ": ", callstack_labels.get(addr, ""));
    }
}

void print_stack() {
    foreach(i, addr; stack) {
        writeln(i, ": ", addr, " -> ", callstack_labels.get(addr, ""));
    }
}

void add_breakpoint() {
    breakpoints ~= PC;
}

void handle_command(string cmd) {
    if(cmd.startsWith("s")) {
        print_stack();
    }
    if(cmd.startsWith("c")) {
        print_callstack();
    }
    if(cmd.startsWith("i")) {
        dbg(PC);
    }
    if(cmd.startsWith("b")) {
        add_breakpoint();
    }
}

// register-or-value
T access(T)(T addr)
{
    if(RAM[addr] >= 32768 && RAM[addr] <= 32775)
    {
        return RAM[addr];
    }
    else
        return addr;
}
