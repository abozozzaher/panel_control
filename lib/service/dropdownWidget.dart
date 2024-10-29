import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import '../generated/l10n.dart';

Widget buildDropdown(
  BuildContext context, // تأكد من تمرير BuildContext
  String hint,
  String? selectedValue,
  List<List<String>> items,
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
      Text(hintText),
      allowAddNew == true
          ? DropdownButton<String>(
              alignment: Alignment.center,
              hint: Text(hint),
              value: selectedValue,
              onChanged: (value) {
                if (value == 'add_new') {
                  showAddNewDialog(context, (newItem) {
                    if (newItem.isNotEmpty && !items.contains(newItem)) {
                      items.add([newItem, newItem]);
                      onChanged(newItem);
                    }
                  }, isNumeric);
                } else {
                  onChanged(value);
                }
              },
              items: [
                ...items.map((item) {
                  String displayText =
                      Localizations.localeOf(context).languageCode == 'ar'
                          ? item[1]
                          : item[0];
                  return DropdownMenuItem(
                    value: item[0],
                    child: Center(
                      child: Text(
                        '$displayText $suffixText', //   '$item $suffixText',
                        textDirection: ui.TextDirection.ltr,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
                DropdownMenuItem(
                  value: 'add_new',
                  child: Center(child: Text(S().add_new_item)),
                ),
              ],
            )
          : DropdownButton<String>(
              alignment: Alignment.center,
              hint: Text(hint),
              value: selectedValue,
              onChanged: onChanged,
              items: items.map((item) {
                String displayText =
                    Localizations.localeOf(context).languageCode == 'ar'
                        ? item[1]
                        : item[0];

                return DropdownMenuItem(
                  value: item[0], // القيمة الأساسية باللغة الإنجليزية
                  child: Center(
                    child: Text(
                      '$displayText $suffixText',
                      textDirection: ui.TextDirection.ltr,
                      textAlign: TextAlign.center,
                    ),
                  ),
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
  final TextEditingController controller = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(S().add_new_item, textAlign: TextAlign.center),
        content: TextField(
          controller: controller,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
          keyboardType: isNumeric
              ? TextInputType.number
              : TextInputType.text, // فتح لوحة الأرقام أو لوحة النصوص

          decoration: InputDecoration(hintText: S().enter_new_item),
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
              final newItem = controller.text.trim();
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
