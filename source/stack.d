module stack;

import std.algorithm.mutation : remove;
import core.stdc.stdlib : exit;
import std.conv : signed;
import std.variant;
import std.stdio;

struct Stack {
  Variant[] stack = null;

  void push(Variant value) {
    stack ~= value;
  }
  void push(double value) {
    stack ~= Variant(value);
  }
  void push(string value) {
    stack ~= Variant(value);
  }

  Variant pop() {
    if (stack.length < 1) {
      stderr.writeln("Stack underflow.");
      exit(2);
    }
    Variant top = stack[$ - 1];
    --stack.length;
    return top;
  }
}