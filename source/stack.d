module stack;

import std.algorithm.mutation : remove;
import core.stdc.stdlib : exit;
import std.conv : signed;
import std.sumtype;
import std.stdio;

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
    if (stack.length < 1) {
      stderr.writeln("Stack underflow.");
      exit(2);
    }
    Value top = stack[$ - 1];
    --stack.length;
    return top;
  }
}