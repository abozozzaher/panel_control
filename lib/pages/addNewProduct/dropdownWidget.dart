import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:path/path.dart';

Widget buildDropdown(
  BuildContext context, // تأكد من تمرير BuildContext

  String hint,
  String? selectedValue,
  List<String> items,
  ValueChanged<String?> onChanged,
  String hintText, {
  String suffixText = '',
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    mainAxisSize: MainAxisSize.max,
    children: [
      Text(hintText, style: const TextStyle(color: Colors.grey)),
      DropdownButton<String>(
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
            });
          } else {
            onChanged(value);
          }
        },
        items: [
          ...items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$item $suffixText',
                      textDirection: ui.TextDirection.ltr),
                ],
              ),
            );
          }).toList(),
          DropdownMenuItem(
            value: 'add_new',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add new item'),
              ],
            ),
          ),
        ],
      ),
    ],
  );
}

void showAddNewDialog(BuildContext context, Function(String) onItemAdded) {
  final TextEditingController _controller = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Add New Item'),
        content: TextField(
          controller: _controller,
          decoration: InputDecoration(hintText: 'Enter new item'),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Add'),
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
