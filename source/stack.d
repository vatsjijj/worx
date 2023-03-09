module stack;

import std.sumtype;

alias Value = SumType!(double, string);

struct Stack {
  Value[] stack = null;

  void push(Value value) {
    stack ~= value;
  }
  void push(double value) {
    stack ~= Value(value);
  }
  void push(string value) {
    stack ~= Value(value);
  }

  Value pop() {
    import core.exception : ArrayIndexError;
    import core.stdc.stdlib : exit;
    import std.stdio;
    Value top;
    try {
      top = stack[$ - 1];
      --stack.length;
      return top;
    }
    catch (ArrayIndexError e) {
      stderr.writeln("Stack underflow.");
      exit(2);
    }
  }
}