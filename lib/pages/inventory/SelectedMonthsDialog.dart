import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

Future<List<String>> showMultiSelectDialog(BuildContext context,
    List<String> options, List<String> selectedValues) async {
  List<String> selectedItems =
      List.from(selectedValues); // Copy the selected items

  final result = await showDialog<List<String>>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(S().select_months, textAlign: TextAlign.center),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Button to select all items
              TextButton(
                onPressed: () {
                  selectedItems = List.from(options); // Select all options
                  (context as Element).markNeedsBuild(); // Refresh the dialog
                },
                child: Text(S().select_all),
              ),
              // List of options with checkboxes
              Column(
                children: options.map((String option) {
                  return CheckboxListTile(
                    title: Text(option),
                    value: selectedItems.contains(option),
                    onChanged: (bool? selected) {
                      if (selected != null) {
                        if (selected) {
                          selectedItems.add(option);
                        } else {
                          selectedItems.remove(option);
                        }
                        (context as Element)
                            .markNeedsBuild(); // Refresh the dialog
                      }
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(S().cancel),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(selectedItems);
                },
                child: Text(S().ok),
              ),
            ],
          ),
        ],
      );
    },
  );

  // Ensure a non-null list is returned
  return result ?? [];
}
