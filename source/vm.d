module vm;

import std.sumtype;
import std.string;
import std.stdio;
import std.conv;
import stack;
import table;
import scan;

final class VM {
  private int[1024] jmp;
  private int jmpCount;
  private int beginWord = -1, endWord = -1;
  private int loc;
  private immutable string name;
  private string tok;
  private string[] toks;
  private Stack ds, rs;
  private Table variables;
  private int[2][string] words;
  private int[1024] topLim, botLim;
  private int level = 0;

  this(immutable string src) {
    this.jmpCount = 0;
    this.loc = 0;
    this.toks = scanner(src);
    this.tok = this.toks[this.loc];
    this.name = "VM";
  }
  this(immutable string name, immutable string src) {
    this.jmpCount = 0;
    this.loc = 0;
    this.toks = scanner(src);
    this.tok = this.toks[this.loc];
    this.name = name;
  }

  private void adv() {
    ++loc;
    if (loc >= toks.length) {
      return;
    }
    tok = toks[loc];
  }

  // The run function.
  void run() {
    while (loc < toks.length) {
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
        case "del": del(); break;
        case "and": and(); break;
        case "or": or(); break;
        case "xor": xor(); break;
        case "invert": invert(); break;
        case "2drop": drop2(); break;
        case "swap": swap(); break;
        case "nip": nip(); break;
        case "dup": dup(); break;
        case "rot": rot(); break;
        case "over": over(); break;
        case "2dup": dup2(); break;
        case "2>r": toR2(); break;
        case "2r>": rFrom2(); break;
        case "r@": rFetch(); break;
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
          push("[]ivif");
          del();
          break;
        case "do": cdo(); break;
        case "?do": qmdo(); break;
        case "loop": loop(); break;
        case ":": colon(); break;
        case ";": semicolon(); break;
        // Misc.
        case "space": space(); break;
        case "\0": return;
        // End misc.
        default:
          int[2]* ptr = tok in words;
          if (tryMatchDouble(tok)) {
            push(to!double(tok));
          }
          else if (tok[$ - 1] == 's' &&
              tok[$ - 2] == ':') {
            push(tok[0..($ - 2)]);
            break;
          }
          else if (ptr !is null) {
            ++jmpCount;
            jmp[jmpCount - 1] = loc;
            jump(words[tok][0] - 1);
            break;
          }
          else {
            push(tok);
            break;
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

  private void jump(int location) {
    if (location >= toks.length) {
      loc = location;
      return;
    }
    loc = location;
    tok = toks[loc];
  }

  // Helpers to make things easier.
  private void push(Value value) {
    ds.push(value);
  }
  private void push(double value) {
    ds.push(value);
  }
  private void push(string value) {
    ds.push(value);
  }

  private Value pop() {
    return ds.pop();
  }

  private double getD() {
    return pop().match!(
      (double d) => d,
      (string s) => 0
    );
  }

  private string getS() {
    return pop().match!(
      (double d) => to!string(d),
      (string s) => s
    );
  }

  private static bool tryMatchDouble(string tok) {
    try {
      to!double(tok);
      return true;
    }
    catch (ConvException e) {
      return false;
    }
  }
  // End helpers.

  private void colon() {
    string wname = getS();
    beginWord = loc + 1;
    while (toks[loc] != ";") {
      adv();
    }
    endWord = loc;
    words[wname] = [beginWord, endWord];
  }

  private void semicolon() {
    jump(jmp[jmpCount - 1]);
    --jmpCount;
  }

  private void add() {
    double a = getD();
    double b = getD();
    push(b + a);
  }

  private void sub() {
    double a = getD();
    double b = getD();
    push(b - a);
  }

  private void mul() {
    double a = getD();
    double b = getD();
    push(b * a);
  }

  private void div() {
    double a = getD();
    double b = getD();
    push(b / a);
  }

  private void mod() {
    double a = getD();
    double b = getD();
    push(b % a);
  }

  private void concat() {
    string a = getS();
    string b = getS();
    push(b ~ a);
  }

  private void equals() {
    push(
      pop() == pop() ? 1 : 0
    );
  }

  private void gt() {
    push(
      getD() < getD() ? 1 : 0
    );
  }

  private void lt() {
    push(
      getD() > getD() ? 1 : 0
    );
  }

  private void abs() {
    int x = cast(int)getD();
    push(
      x < 0 ? -x : x
    );
  }

  private void lShift() {
    double u = getD();
    double x = getD();
    push((cast(int)x) <<
         (cast(int)u));
  }

  private void rShift() {
    double u = getD();
    double x = getD();
    push ((cast(int)x) >>
          (cast(int)u));
  }

  private void and() {
    double a = getD();
    double b = getD();
    push((cast(int)b) &
         (cast(int)a));
  }

  private void or() {
    double a = getD();
    double b = getD();
    push((cast(int)b) |
         (cast(int)a));
  }

  private void xor() {
    double a = getD();
    double b = getD();
    push((cast(int)b) ^
         (cast(int)a));
  }

  private void invert() {
    push(~(cast(int)getD()));
  }

  // Easier to understand.
  private void drop() {
    pop();
  }

  private void drop2() {
    drop();
    drop();
  }

  private void swap() {
    Value a = pop();
    Value b = pop();
    push(a);
    push(b);
  }

  private void nip() {
    swap();
    drop();
  }

  private void dup() {
    Value a = pop();
    push(a);
    push(a);
  }

  private void rot() {
    toR();
    swap();
    rFrom();
    swap();
  }

  private void over() {
    toR();
    dup();
    rFrom();
    swap();
  }

  private void dup2() {
    over();
    over();
  }

  private void toR2() {
    toR();
    toR();
  }

  private void rFrom2() {
    rFrom();
    rFrom();
  }

  private void rFetch() {
    rFrom();
    dup();
    toR();
  }

  private void variable() {
    // X VARIABLE
    variables.set(getS());
  }

  private void store() {
    // 12 X !
    variables.set(getS(), pop());
  }

  private void fetch() {
    // X @
    push(variables.get(getS()));
  }

  private void cif() {
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
    if (getD() == 1) {
      jump(jmp[jmpCount - 3]);
    }
    else if (jmp[jmpCount - 2] > -1) {
      jump(jmp[jmpCount - 2]);
    }
    else {
      jump(jmp[jmpCount - 1] - 1);
    }
  }

  private void celse() {
    push("[]ivif");
    fetch();
    if (getD() == 1) {
      jump(jmp[jmpCount - 1] - 1);
    }
    else {
      pop();
      push("[]ivif");
      del();
    }
  }

  private void loop() {
    if (topLim[level - 1] - 1 > botLim[level - 1]) {
      ++botLim[level - 1];
      jump(jmp[jmpCount - 1]);
      return;
    }
    --level;
    --jmpCount;
  }

  private void cdo() {
    ++level;
    ++jmpCount;
    topLim[level - 1] = cast(int)getD();
    botLim[level - 1] = 0;
    jmp[jmpCount - 1] = loc;
  }

  private void qmdo() {
    ++level;
    ++jmpCount;
    botLim[level - 1] = cast(int)getD();
    topLim[level - 1] = cast(int)getD();
    jmp[jmpCount - 1] = loc;
  }

  // Non-standard
  private void del() {
    variables.del(getS());
  }

  // Return stack operations.
  private void toR() {
    rs.push(ds.pop());
  }

  private void rFrom() {
    ds.push(rs.pop());
  }

  private void printReturnStack() {
    writeln("RET: ", rs.stack);
  }
  // End return stack operations.

  // Misc.
  private void space() {
    write(" ");
  }
  // End misc.

  private void popPrint() {
    write(getS());
  }

  private void popPrintLn() {
    writeln(getS());
  }

  private void printStack() {
    writeln("NOR: ", ds.stack);
  }
}