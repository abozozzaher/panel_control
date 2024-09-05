import 'package:flutter/services.dart';

class UpperCaseFirstLetterFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isNotEmpty) {
      final firstChar = newValue.text[0].toUpperCase();
      final restOfString = newValue.text.substring(1);
      return TextEditingValue(
        text: '$firstChar$restOfString',
        selection: newValue.selection,
      );
    }
    return newValue;
  }
}
