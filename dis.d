import std.stdio;
import std.file;
import std.conv : to;

string[] op_names = [
    "halt", "set", "push", "pop", "eq", "gt", "jmp", "jt", "jf", "add", "mult", "mod", "and", "or", "not", "rmem", "wmem", "call", "ret", "out", "in", "nop" 
]; 

string rov(T)(T val)
{
    if(val >= 32768 && val <= 32775)
    {
        return "%" ~ to!char('a' + (val - 32768));
    }
    else
        return to!string(val);
}

auto num_params(ushort op) {
    switch(op) {
        case 0:
        case 18:
        case 21:
            return 0;
        case 2:
        case 3:
        case 6:
        case 17:
        case 19:
        case 20:
            return 1;
        case 1:
        case 7:
        case 8:
        case 14: .. case 16:
            return 2;
        case 4: .. case 5:
        case 9: .. case 13:
            return 3;
        default: 
            return -1;
    } 
}

void disas(string name, ref ushort[] code) {
    char[] buf;
    for(int i = 0; i < code.length;++i) {
        string line;
        if(code[i] > 21) {
            line = "garbage" ~ to!string(code[i]);
        }
        else {
            auto p = num_params(code[i]);
            line ~= op_names[code[i]];
            foreach(j; 0 .. p) line ~= " " ~ rov(code[i + j + 1]);
            i += p;
            writeln(line);
        }
        buf ~= line ~ "\n";
    }
    std.file.write(name, buf);
}

void main(string[] args)
{
    if (args.length > 1)
    {
        auto code = cast(ushort[]) read(args[1]);
        disas(args[2], code);
    }
}

