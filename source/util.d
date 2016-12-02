module util;
import std.stdio;
import std.algorithm.searching : startsWith;
import vm;

void dbg(size_t addr) {
    writeln("PC: ", PC, " OP_CODE: ", RAM[addr]);
    assert(RAM[addr] <= 21);
    writeln("OP_NAME: ", op_names[RAM[addr]]);
    foreach(i; 0..3) writeln(cast(char)('A' + i), ": ", RAM[addr + i + 1]);
    foreach(i ; 0..8)
        writeln(i, " r: ", RAM[32768 + i]);
    for(int i = 0; i < stack.length; ++i)
        writeln(i, " s: ", stack[i]);
}

void print_callstack() {
    foreach(addr; callstack) {
        writeln(addr, ": ", callstack_labels.get(addr, ""));
    }
}

void handle_command(string cmd) {
    if(cmd.startsWith("cs")) {
        print_callstack();
    }
    if(cmd.startsWith("i")) {
        dbg(PC-1);
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
