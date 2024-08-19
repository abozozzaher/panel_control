import 'package:flutter/material.dart';

class ScannedDataList extends StatelessWidget {
  final List<String> _selectedItems;

  ScannedDataList(this._selectedItems);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _selectedItems.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_selectedItems[index]),
        );
      },
    );
  }
}
