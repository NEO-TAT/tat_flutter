import 'package:flutter/material.dart';

class AnsiParser {
  static const ansiText = 0, ansiBracket = 1, ansiCode = 2;

  final bool dark;

  AnsiParser(this.dark);

  Color? foreground;
  Color? background;
  List<TextSpan>? spans;

  void parse(String s) {
    spans = [];
    int state = ansiText;
    StringBuffer buffer = StringBuffer();
    StringBuffer text = StringBuffer();
    int code = 0;
    final List<int> codes = [];

    for (int i = 0, n = s.length; i < n; i++) {
      final c = s[i];

      switch (state) {
        case ansiText:
          if (c == '\u001b') {
            state = ansiBracket;
            buffer = StringBuffer(c);
            code = 0;
            codes.clear();
          } else {
            text.write(c);
          }
          break;

        case ansiBracket:
          buffer.write(c);
          if (c == '[') {
            state = ansiCode;
          } else {
            state = ansiText;
            text.write(buffer);
          }
          break;

        case ansiCode:
          buffer.write(c);
          final codeUnit = c.codeUnitAt(0);
          if (codeUnit >= 48 && codeUnit <= 57) {
            code = code * 10 + codeUnit - 48;
            continue;
          } else if (c == ';') {
            codes.add(code);
            code = 0;
            continue;
          } else {
            if (text.isNotEmpty) {
              spans?.add(createSpan(text.toString()));
              text.clear();
            }
            state = ansiText;
            if (c == 'm') {
              codes.add(code);
              handleCodes(codes);
            } else {
              text.write(buffer);
            }
          }

          break;
      }
    }

    spans?.add(createSpan(text.toString()));
  }

  void handleCodes(List<int> codes) {
    if (codes.isEmpty) {
      codes.add(0);
    }

    switch (codes[0]) {
      case 0:
        foreground = getColor(0, true);
        background = getColor(0, false);
        break;
      case 38:
        foreground = getColor(codes[2], true);
        break;
      case 39:
        foreground = getColor(0, true);
        break;
      case 48:
        background = getColor(codes[2], false);
        break;
      case 49:
        background = getColor(0, false);
    }
  }

  Color? getColor(int colorCode, bool foreground) {
    switch (colorCode) {
      case 0:
        return foreground ? Colors.black : Colors.transparent;
      case 12:
        return dark ? Colors.lightBlue[300] : Colors.indigo[700];
      case 208:
        return dark ? Colors.orange[300] : Colors.orange[700];
      case 196:
        return dark ? Colors.red[300] : Colors.red[700];
      case 199:
        return dark ? Colors.pink[300] : Colors.pink[700];
    }

    return Colors.transparent;
  }

  TextSpan createSpan(String text) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: foreground,
        backgroundColor: background,
      ),
    );
  }
}
