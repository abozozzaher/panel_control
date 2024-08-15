import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../../generated/l10n.dart';

Widget buildDropdown(
  BuildContext context, // تأكد من تمرير BuildContext
  String hint,
  String? selectedValue,
  List<String> items,
  ValueChanged<String?> onChanged,
  String hintText, {
  String suffixText = '',
  bool allowAddNew = false,
  bool isNumeric = false,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    mainAxisSize: MainAxisSize.max,
    children: [
      Text(hintText, style: const TextStyle(color: Colors.grey)),
      allowAddNew == true
          ? DropdownButton<String>(
              alignment: Alignment.center,
              hint: Text(hint),
              value: selectedValue,
              onChanged: (value) {
                if (value == 'add_new') {
                  showAddNewDialog(context, (newItem) {
                    // Add the new item to the list and update the dropdown
                    if (newItem.isNotEmpty && !items.contains(newItem)) {
                      items.add(newItem);
                      onChanged(newItem);
                    }
                  }, isNumeric);
                } else {
                  onChanged(value);
                }
              },
              items: [
                ...items.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Center(
                      child: Text(
                        '$item $suffixText',
                        textDirection: ui.TextDirection.ltr,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }).toList(),
                DropdownMenuItem(
                  value: 'add_new',
                  child: Center(child: Text('Add new item')),
                ),
              ],
            )
          : DropdownButton<String>(
              alignment: Alignment.center,
              hint: Text(hint),
              value: selectedValue,
              onChanged: onChanged,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Center(
                    child: Text(
                      '$item $suffixText',
                      textDirection: ui.TextDirection.ltr,
                      textAlign: TextAlign.center,
                    ),
                  ), // إضافة النص الإضافي هنا
                );
              }).toList(),
            ),
    ],
  );
}

void showAddNewDialog(
  BuildContext context,
  Function(String) onItemAdded,
  isNumeric,
) {
  final TextEditingController _controller = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add New Item'),
        content: TextField(
          controller: _controller,
          keyboardType: isNumeric
              ? TextInputType.number
              : TextInputType.text, // فتح لوحة الأرقام أو لوحة النصوص

          decoration: InputDecoration(hintText: 'Enter new item'),
        ),
        actions: [
          TextButton(
            child: Text(S().cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text(S().add),
            onPressed: () {
              final newItem = _controller.text.trim();
              if (newItem.isNotEmpty) {
                onItemAdded(newItem);
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}
