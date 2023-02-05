import startup;

void main(string[] args) {
    try {
        setupApplication(args);
        /*foreach (ft; ["VeraBd", "VeraBi", "VeraIt"]) {
            extractFontHex(ft);
        }*/
    }
    catch (Exception e) {
        import std.file : write;

        string crashLog;

        crashLog ~= "Error: " ~ e.msg ~ "\n";
        foreach (trace; e.info) {
            crashLog ~= "at: " ~ trace ~ "\n";
        }

        write("crash.txt", crashLog);
    }
}
/*
void extractFontHex(string ft) {
    import std.file, std.format;

    auto a = cast(ubyte[]) read(ft ~ ".ttf");
    string r;
    int l;
    foreach (i; a) {
        if (i == 0)
            r ~= "0x00, ";
        else
            r ~= format("%#0.2x, ", i);
        l++;
        if (l > 16) {
            r ~= "\n";
            l = 0;
        }
    }
    write(ft ~ ".txt", r);
}*/
