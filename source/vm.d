module vm;

import std.algorithm.mutation : remove;
import core.stdc.stdlib : exit;
import std.variant;
import std.string;
import std.stdio;
import std.conv;
import stack;
import table;
import scan;

class VM {
  private int[1024] jmp;
  private int jmpCount;
  private int beginWord = -1, endWord = -1;
  private int loc;
  private string name, tok;
  private string[] toks;
  private Stack ds, rs;
  private Table variables;
  private int[2][string] words;
  private int[1024] topLim, botLim;
  private int level = 0;

  this(string src) {
    this.jmpCount = 0;
    this.loc = 0;
    this.toks = scanner(src);
    this.tok = this.toks[this.loc];
    this.name = "VM";
  }
  this(string name, string src) {
    this.jmpCount = 0;
    this.loc = 0;
    this.toks = scanner(src);
    this.tok = this.toks[this.loc];
    this.name = name;
  }

  void adv() {
    ++loc;
    if (loc >= signed(toks.length)) {
      return;
    }
    tok = toks[loc];
  }

  // The run function.
  void run() {
    while (loc < signed(toks.length)) {
      switch (tok.toLower()) {
        case "+": add(); break;
        case "-": sub(); break;
        case "*": mul(); break;
        case "/": div(); break;
        case "%": mod(); break;
        case "<>": concat(); break;
        case "=": equals(); break;
        case ">": gt(); break;
        case "<": lt(); break;
        case "abs": abs(); break;
        case ".": popPrint(); break;
        case ".nl": popPrintLn(); break;
        case "drop": drop(); break;
        case ".stack": printStack(); break;
        case "lshift": lShift(); break;
        case "rshift": rShift(); break;
        case "variable": variable(); break;
        case "!": store(); break;
        case "@": fetch(); break;
        case "del": del(); break; // Non-standard behavior.
        case "and": and(); break;
        case "or": or(); break;
        case "xor": xor(); break;
        case "invert": invert(); break;
        // Return stack.
        case "i": rs.push(botLim[level - 1]); break;
        case ".retstack": printReturnStack(); break;
        case ">r": toR(); break;
        case "r>": rFrom(); break;
        // End return stack.
        case "true": push(1); break;
        case "false": push(0); break;
        case "if": cif(); break;
        case "else": celse(); break;
        case "then":
          --jmpCount;
          --jmpCount;
          --jmpCount;
          break;
        case "do": cdo(); break;
        case "?do": qmdo(); break;
        case "loop":
          if (topLim[level - 1] - 1 > botLim[level - 1]) {
            ++botLim[level - 1];
            jump(jmp[jmpCount - 1]);
            break;
          }
          --level;
          --jmpCount;
          break;
        case ":": colon(); break;
        case ";": semicolon(); break;
        // Misc.
        case "space": space(); break;
        case "min-num": push(double.min_normal); break;
        case "max-num": push(double.max_exp); break;
        case "exit": jump(jmp[jmpCount - 1] + 1); break;
        case "\0": return;
        // End misc.
        default:
          try {
            push(to!double(tok));
          }
          catch (ConvException e) {
            if (tok[$ - 1] == 's' &&
                tok[$ - 2] == ':') {
              push(tok[0..($ - 2)]);
            }
            else {
              int[2]* ptr = tok in words;
              if (ptr !is null) {
                ++jmpCount;
                jmp[jmpCount - 1] = loc;
                jump(words[tok][0] - 1);
                break;
              }
              push(tok);
            }
          }
          break;
      }
      adv();
    }
  }

  string getName() {
    return name;
  }

  Stack getStack() {
    return ds;
  }

  Table getTable() {
    return variables;
  }

  void jump(int location) {
    if (location >= toks.length) {
      loc = location;
      return;
    }
    loc = location;
    tok = toks[loc];
  }

  // Helpers to make things easier.
  void push(Variant value) {
    ds.push(value);
  }
  void push(double value) {
    ds.push(value);
  }
  void push(string value) {
    ds.push(value);
  }

  Variant pop() {
    return ds.pop();
  }
  // End helpers.

  void colon() {
    string wname = pop().get!string;
    beginWord = loc + 1;
    while (toks[loc] != ";") {
      adv();
    }
    endWord = loc;
    words[wname] = [beginWord, endWord];
  }

  void semicolon() {
    jump(jmp[jmpCount - 1]);
    --jmpCount;
  }

  void add() {
    Variant a = pop();
    Variant b = pop();
    try {
      push(b + a);
    }
    catch (VariantException e) {
      push(0);
    }
  }

  void sub() {
    Variant a = pop();
    Variant b = pop();
    try {
      push(b - a);
    }
    catch (VariantException e) {
      push(0);
    }
  }

  void mul() {
    Variant a = pop();
    Variant b = pop();
    try {
      push(b * a);
    }
    catch (VariantException e) {
      push(0);
    }
  }

  void div() {
    Variant a = pop();
    Variant b = pop();
    try {
      push(b / a);
    }
    catch (VariantException e) {
      push(0);
    }
  }

  void mod() {
    Variant a = pop();
    Variant b = pop();
    try {
      push (b.get!double % a.get!double);
    }
    catch (VariantException e) {
      push(-1);
    }
  }

  void concat() {
    Variant a = pop();
    Variant b = pop();
    try {
      push(b ~ to!string(a));
    }
    catch (VariantException e) {
      push(0);
    }
  }

  void equals() {
    push(
      pop() == pop() ? 1 : 0
    );
  }

  void gt() {
    push(
      pop() < pop() ? 1 : 0
    );
  }

  void lt() {
    push(
      pop() > pop() ? 1 : 0
    );
  }

  void abs() {
    int x = cast(int)pop().get!double;
    push(
      x < 0 ? -x : x
    );
  }

  void lShift() {
    Variant u = pop();
    Variant x = pop();
    push((cast(int)x.get!double) <<
         (cast(int)u.get!double));
  }

  void rShift() {
    Variant u = pop();
    Variant x = pop();
    push ((cast(int)x.get!double) >>
          (cast(int)u.get!double));
  }

  void and() {
    Variant a = pop();
    Variant b = pop();
    push((cast(int)b.get!double) &
         (cast(int)a.get!double));
  }

  void or() {
    Variant a = pop();
    Variant b = pop();
    push((cast(int)b.get!double) |
         (cast(int)a.get!double));
  }

  void xor() {
    Variant a = pop();
    Variant b = pop();
    push((cast(int)b.get!double) ^
         (cast(int)a.get!double));
  }

  void invert() {
    push(~(cast(int)pop().get!double));
  }

  // Easier to understand.
  void drop() {
    pop();
  }

  void variable() {
    // X VARIABLE
    variables.set(to!string(pop()));
  }

  void store() {
    // 12 X !
    variables.set(to!string(pop()), pop());
  }

  void fetch() {
    // X @
    push(variables.get(to!string(pop())));
  }

  void cif() {
    ++jmpCount;
    ++jmpCount;
    ++jmpCount;
    jmp[jmpCount - 1] = -1;
    jmp[jmpCount - 2] = -1;
    jmp[jmpCount - 3] = loc;
    while (toks[loc] != "else") {
      if (toks[loc] == "then") {
        jmp[jmpCount - 2] = -1;
        jmp[jmpCount - 1] = loc;
        break;
      }
      adv();
    }
    if (jmp[jmpCount - 1] == -1) {
      jmp[jmpCount - 2] = loc;
    }
    while (jmp[jmpCount - 2] != -1 && toks[loc] != "then") {
      adv();
    }
    if (jmp[jmpCount - 2] != -1) {
      jmp[jmpCount - 1] = loc;
    }
    push("[]ivif");
    store();
    push("[]ivif");
    fetch();
    if (pop() == 1) {
      jump(jmp[jmpCount - 3]);
    }
    else if (jmp[jmpCount - 2] > -1) {
      jump(jmp[jmpCount - 2]);
    }
    else {
      jump(jmp[jmpCount - 1] - 1);
    }
  }

  void celse() {
    push("[]ivif");
    fetch();
    if (pop() == 1) {
      jump(jmp[jmpCount - 1] - 1);
    }
    else {
      pop();
      push("[]ivif");
      del();
    }
  }

  void cdo() {
    ++level;
    ++jmpCount;
    topLim[level - 1] = cast(int)pop().get!double;
    botLim[level - 1] = 0;
    jmp[jmpCount - 1] = loc;
  }

  void qmdo() {
    ++level;
    ++jmpCount;
    botLim[level - 1] = cast(int)pop().get!double;
    topLim[level - 1] = cast(int)pop().get!double;
    jmp[jmpCount - 1] = loc;
  }

  // Non-standard
  void del() {
    variables.del(to!string(pop()));
  }

  // Return stack operations.
  void toR() {
    rs.push(ds.pop());
  }

  void rFrom() {
    ds.push(rs.pop());
  }

  void printReturnStack() {
    writeln("RET: ", rs.stack);
  }
  // End return stack operations.

  // Misc.
  void space() {
    write(" ");
  }
  // End misc.

  void popPrint() {
    write(pop());
  }

  void popPrintLn() {
    writeln(pop());
  }

  void printStack() {
    writeln("NOR: ", ds.stack);
  }
}