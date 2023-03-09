module table;

import stack : Value;

struct Table {
  Value[string] table = null;

  Value get(string index) {
    return table[index];
  }

  void set(string index) {
    table[index] = null;
  }
  void set(string index, Value value) {
    table[index] = value;
  }
  void set(string index, double value) {
    table[index] = Value(value);
  }
  void set(string index, string value) {
    table[index] = Value(value);
  }

  void del(string index) {
    table.remove(index);
  }
}