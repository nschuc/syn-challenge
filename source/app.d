import std.stdio;
import std.file : read;
import std.getopt;
import vm : start_vm;
import dis : disas;

void main(string[] args)
{
    string disas_file;
    string bin_file;
    bool verbose;
    auto helpInformation = getopt(
            args,
            "disas_file|d",  &disas_file,
            std.getopt.config.required,
            "bin_file|b",    &bin_file,
            "verbose", &verbose
            ); 

    if (helpInformation.helpWanted)
    {
        defaultGetoptPrinter("how do I make it do the thing",
                helpInformation.options);
    }


    auto bytes = cast(ushort[]) read(bin_file);

    if (disas_file.length)
        disas(disas_file, bytes);

    start_vm(bytes);
}
