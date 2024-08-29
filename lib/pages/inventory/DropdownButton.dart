import 'package:flutter/material.dart';

Widget buildDropdownButton({
  required String hint,
  required String? selectedValue,
  required List<List<String>> items,
  required ValueChanged<String?> onChanged,
}) {
  return Container(
    width: 150,
    alignment: Alignment.center,
    child: DropdownButton(
      alignment: Alignment.center,
      hint: Text(hint, textAlign: TextAlign.center),
      value: selectedValue,
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem(
          alignment: Alignment.center,
          value: item[0],
          child: Text(item[1], textAlign: TextAlign.center),
        );
      }).toList(),
    ),
  );
}
