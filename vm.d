import std.stdio;
import std.file;

ushort[32776] RAM;
ushort[] stack;
ushort PC = 0;
ushort SP = 0;

string[] op_names = [
    "halt", "set", "push", "pop", "eq", "gt", "jmp", "jt", "jf", "add", "mult", "mod", "and", "or", "not", "rmem", "wmem", "call", "ret", "out", "in", "nop" 
]; 

string stdin_buf;

void dbg() {
    writeln("PC: ", PC, " OP_CODE: ", RAM[PC]);
    assert(RAM[PC] <= 21);
    writeln("OP_NAME: ", op_names[RAM[PC]]);
    foreach(i; 0..3) writeln(cast(char)('A' + i), ": ", RAM[PC + i + 1]);
    foreach(i ; 0..8)
        writeln(i, " r: ", RAM[32768 + i]);
    for(int i = 0; i < stack.length; ++i)
        writeln(i, " s: ", stack[i]);
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

bool exec(){
    ushort p() { return access(PC++); }
    ushort rd() { return RAM[p()]; }
    auto ref ld() { return RAM[p()]; }
    final switch(RAM[PC++]) {
        /* halt: 0 */
        /*   stop execution and terminate the program */
        case 0:
            return false;
            break;
        /* set: 1 a b */
        /*   set register <a> to the value of <b> */
        case 1:
            ld() = rd();
            break;
        /* push: 2 a */
        /*   push <a> onto the stack */
        case 2:
            stack ~= rd();
            break;
        /* pop: 3 a */
        /*   remove the top element from the stack and write it into <a>; empty stack = error */
        case 3:
            ld() = stack[$ - 1]; --stack.length;
            break;
        /* eq: 4 a b c */
        /*   set <a> to 1 if <b> is equal to <c>; set it to 0 otherwise */
        case 4:
            ld() = rd() == rd() ? 1 : 0;
            break;
        /* gt: 5 a b c */
        /*   set <a> to 1 if <b> is greater than <c>; set it to 0 otherwise */
        case 5:
            ld() = rd() > rd() ? 1 : 0;
            break;
        /* jmp: 6 a */
        /*   jump to <a> */
        case 6:
            PC = rd();
            break;
        /* jt: 7 a b */
        /*   if <a> is nonzero, jump to <b> */
        case 7:
            PC = rd() ? rd() : ++PC;
            break;
        /* jf: 8 a b */
        /*   if <a> is zero, jump to <b> */
        case 8:
            PC = !rd() ? rd() : ++PC;
            break;
        /* add: 9 a b c */
        /*   assign into <a> the sum of <b> and <c> (modulo 32768) */
        case 9:
            ld() = cast(ushort)(rd() + rd()) % 0x8000;
            break;
        /* mult: 10 a b c */
        /*   store into <a> the product of <b> and <c> (modulo 32768) */
        case 10:
            ld() = cast(ushort)(rd() * rd()) % 0x8000;
            break;
        /* mod: 11 a b c */
        /*   store into <a> the remainder of <b> divided by <c> */
        case 11:
            ld() = cast(ushort)(rd() % rd()) % 0X8000;
            break;
        /* and: 12 a b c */
        /*   stores into <a> the bitwise and of <b> and <c> */
        case 12:
            ld() = cast(ushort)(rd() & rd()) % 0X8000;
            break;
        /* or: 13 a b c */
        /*   stores into <a> the bitwise or of <b> and <c> */
        case 13:
            ld() = cast(ushort)(rd() | rd()) % 0x8000;
            break;
        /* not: 14 a b */
        /*   stores 15-bit bitwise inverse of <b> in <a> */
        case 14:
            ld() = cast(ushort)((~rd()) & 0x8000 - 1);
            break;
        /* rmem: 15 a b */
        /*   read memory at address <b> and write it to <a> */
        case 15:
            ld() = RAM[rd()];
            break;
        /* wmem: 16 a b */
        /*   write the value from <b> into memory at address <a> */
        case 16:
            RAM[ld()] = rd();
            break;
        /* call: 17 a */
        /*   write the address of the next instruction to the stack and jump to <a> */
        case 17:
            stack ~= cast(ushort)(PC + 1);
            PC = rd();
            break;
        /* ret: 18 */
        /*   remove the top element from the stack and jump to it; empty stack = halt */
        case 18:
            PC = stack[$-1];--stack.length;
            break;
        /* out: 19 a */
        /*   write the character represented by ascii code <a> to the terminal */
        case 19:
            write(cast(char) rd());
            break;
        /* in: 20 a */
        case 20:
            if(stdin_buf.length == 0) {
                stdin_buf = stdin.readln();
            }
            ld() = cast(ushort)(stdin_buf[0]);
            stdin_buf = stdin_buf[1..$];
            break;
        /* noop: 21 */
        /* no operation */
        case 21:
            break;
    }
    return true;
}


void main(string[] args)
{
    
    if (args.length > 1)
    {
        auto bytes = cast(ushort[]) read(args[1]);
        RAM[0..bytes.length] = bytes;
        while(exec()) {}
    }
}