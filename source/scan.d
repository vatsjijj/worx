module scan;

import std.uni;

private int location = 0;

private bool inBounds(string src) {
  return location < (src.length) - 1;
}

private void comment(string src) {
  ++location;
  while (src[location] != ')' && inBounds(src)) {
    ++location;
  }
  ++location;
}

private void whitespace(string src) {
  while (isWhite(src[location]) && inBounds(src)) {
    ++location;
  }
}

private string word(string src) {
  string res;
  while (!isWhite(src[location]) && inBounds(src)) {
    res ~= src[location];
    ++location;
  }

  return res;
}

private string str(string src) {
  string res;
  ++location;
  while (src[location] != '"' && inBounds(src)) {
    res ~= src[location];
    ++location;
  }
  ++location;
  return res ~ ":s";
}

static string[] scanner(string src) {
  src = src ~ " \0 \0";
  // src = FULL ~ src;

  string[] res = [];

  while (inBounds(src)) {
    if (src[location] == '(') {
      comment(src);
    }
    else if (src[location] == '"') {
      res ~= str(src);
    }
    else if (!isWhite(src[location])) {
      res ~= word(src);
    }
    else {
      whitespace(src);
    }
  }

  location = 0;

  return res;
}