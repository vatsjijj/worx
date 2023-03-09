module table;

import std.variant;

struct Table {
  Variant[string] table = null;

  Variant get(string index) {
    return table[index];
  }

  void set(string index) {
    table[index] = null;
  }
  void set(string index, Variant value) {
    table[index] = value;
  }
  void set(string index, double value) {
    table[index] = Variant(value);
  }
  void set(string index, string value) {
    table[index] = Variant(value);
  }

  void del(string index) {
    table.remove(index);
  }
}