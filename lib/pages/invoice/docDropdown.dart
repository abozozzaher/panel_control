import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class DocumentDropdown extends StatefulWidget {
  @override
  _DocumentDropdownState createState() => _DocumentDropdownState();
}

class _DocumentDropdownState extends State<DocumentDropdown> {
  List<MultiSelectItem<String>> _items = [];
  List<String> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  // جلب البيانات من الفايربيس
  Future<void> _fetchDocuments() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('seles')
        .where('not_attached_to_client', isEqualTo: false)
        .get();

    List<MultiSelectItem<String>> items = [];
    for (var doc in querySnapshot.docs) {
      String documentName = doc.id; // or doc['name'] if you have a name field
      //  String documentDetails = doc['scannedDataLength'];
      // items.add(MultiSelectItem<String>(documentName, documentDetails));
      items.add(MultiSelectItem<String>(documentName, documentName));
    }

    setState(() {
      _items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 200,
          child: MultiSelectDialogField(
            items: _items,
            title: Text("Select Scanned Data"),
            buttonText: Text("Select Items"),
            onConfirm: (List<String> selected) {
              setState(() {
                _selectedItems = selected;
              });
            },
            listType: MultiSelectListType.LIST,
          ),
        ),
      ],
    );
  }
}
