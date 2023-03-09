import core.exception : ArrayIndexError;
import std.stdio;
import std.file;
import scan;
import vm;

void main(string[] args) {
  string src;
  VM runtime;

  try {
    src = readText(args[1]);
    runtime = new VM("RT", src);
  }
  catch (ArrayIndexError e) {
    stderr.writeln("Expected an argument.");
    return;
  }

  runtime.run();
}
