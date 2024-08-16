import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'generated/l10n.dart';
import 'service/app_drawer.dart';

class TestPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;
  const TestPage(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String? selectedOption;
  TextEditingController customController = TextEditingController();
  List<String> options = ['Option 1', 'Option 2', 'Option 3'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S().test_page),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Material(
              child: DropdownButton<String>(
                value: selectedOption,
                hint: Text(S().select_an_option),
                onChanged: (String? newValue) {
                  if (newValue == 'Custom') {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(S().enter_custom_value),
                          content: TextField(
                            controller: customController,
                            decoration:
                                InputDecoration(hintText: "Enter your value"),
                          ),
                          actions: [
                            TextButton(
                              child: Text(S().ok),
                              onPressed: () {
                                setState(() {
                                  selectedOption = customController.text;
                                  options.add(customController.text);
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    setState(() {
                      selectedOption = newValue;
                    });
                  }
                },
                items: [
                  ...options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    );
                  }).toList(),
                  DropdownMenuItem<String>(
                    value: 'Custom',
                    child: Text(S().custom),
                  ),
                ],
              ),
            ),
            if (selectedOption != null)
              Text('Selected option: $selectedOption'),
          ],
        ),
      ),
    );
  }
}
