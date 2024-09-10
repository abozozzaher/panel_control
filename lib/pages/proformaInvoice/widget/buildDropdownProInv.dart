import 'package:flutter/material.dart';

import '../../../data/data_lists.dart';
import '../../../generated/l10n.dart';

DataLists dataLists = DataLists();

/// دالة لإنشاء DropdownButton مع إمكانية إضافة عنصر جديد
Widget buildDropdownProInv(
    BuildContext context, void Function(VoidCallback fn) setState,
    // تأكد من تمرير BuildContext
    {required String hint,
    required String? selectedValue,
    required List<List<String>> itemsList,
    required ValueChanged<String?> onChanged}) {
  return DropdownButton<String>(
    hint: Text(hint, textAlign: TextAlign.center),
    value: selectedValue,
    onChanged: (String? newValue) async {
      if (newValue == "Add New") {
        String? newItem = await _showAddItemDialog(context);
        if (newItem != null && newItem.isNotEmpty) {
          setState(() {
            itemsList.add([newItem, newItem]);
            onChanged(newItem);
          });
        }
      } else {
        setState(() {
          onChanged(newValue);
        });
      }
    },
    items: [
      ...itemsList.map((item) {
        return DropdownMenuItem<String>(
          alignment: Alignment.center,
          value: item[0],
          child: Text(item[1]),
        );
      }).toList(),
      DropdownMenuItem<String>(
        value: "Add New",
        child:
            Center(child: Text(S().add_new_item, textAlign: TextAlign.center)),
      ),
    ],
  );
}

/// دالة لعرض مربع حوار لإدخال عنصر جديد
Future<String?> _showAddItemDialog(BuildContext context) async {
  String? newItem;
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        alignment: Alignment.center,
        title: Text(S().add_new_item, textAlign: TextAlign.center),
        content: TextField(
          onChanged: (value) {
            newItem = value;
          },
          decoration: InputDecoration(hintText: S().enter_new_item),
        ),

        //00000
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                  child: TextButton(
                      child: Text(S().cancel,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.redAccent),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })),
              const SizedBox(height: 5, width: 5),
              Expanded(
                child: TextButton(
                  child: Text(S().add,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                  style:
                      TextButton.styleFrom(backgroundColor: Colors.greenAccent),
                  onPressed: () {
                    Navigator.of(context).pop(newItem);
                  },
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
