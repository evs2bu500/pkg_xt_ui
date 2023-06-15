import 'package:flutter/material.dart';

bool isNumeric(String input) {
  if (input == null || input.isEmpty) {
    return false;
  }

  final intVal = int.tryParse(input);
  if (intVal != null) {
    return true;
  }

  final doubleVal = double.tryParse(input);
  if (doubleVal != null) {
    return true;
  }

  return false;
}

bool isAlphaNumeric(String input) {
  if (input == null || input.isEmpty) {
    return false;
  }

  final RegExp alphaNumeric = RegExp(r'^[a-zA-Z0-9]+$');
  return alphaNumeric.hasMatch(input);
}

// int getDisplayLength(double width) {
//   int displayLength = (width / 8).floor() - 3;
//   if (displayLength < 3) {
//     displayLength = 3;
//   }
//   return displayLength;
// }
// int getDisplayLength(double width, double fontSize) {
//   int displayLength = (width / fontSize).floor();
//   if (displayLength < 3) {
//     displayLength = 3;
//   }
//   return displayLength;
// }

Size getStringDisplaySize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

int getDisplayLength(double width, TextStyle style) {
  int displayLength = (width / getStringDisplaySize('a', style).width).floor();
  if (displayLength < 3) {
    displayLength = 3;
  }
  return displayLength;
}

String lengthyString(String input, int length) {
  if (input.isEmpty) {
    return '';
  }

  if (input.length <= length) {
    return input;
  }

  return '${input.substring(0, length)}...';
}

String convertToDisplayString(
    String input, double containerWidth, TextStyle style) {
  if (input.isEmpty) {
    return '';
  }
  double displayWidth = getStringDisplaySize(input, style).width;

  if (displayWidth <= containerWidth) {
    return input;
  }

  int length = (input.length * containerWidth / displayWidth).floor() - 5;

  return '${input.substring(0, length)}...';
}

int decideDisplayDecimal(double value) {
  if (value == 0) {
    return 0;
  }
  if (value < 0.01) {
    return 3;
  }
  if (value < 0.1) {
    return 2;
  }
  if (value < 1) {
    return 2;
  }
  if (value < 10) {
    return 1;
  }
  if (value < 100) {
    return 1;
  }
  if (value < 1000) {
    return 1;
  }
  return 0;
}

int getLevelValue(String level) {
  int levelValue = 0;
  levelValue = isNumeric(level)
      ? int.parse(level)
      : level == 'B5'
          ? -5
          : level == 'B4'
              ? -4
              : level == 'B3'
                  ? -3
                  : level == 'B2'
                      ? -2
                      : level == 'B1'
                          ? -1
                          : 0;
  return levelValue;
}
