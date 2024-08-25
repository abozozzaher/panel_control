import 'package:flutter/material.dart';

class DataTableExample extends StatelessWidget {
  final Map<String, Map<String, dynamic>> aggregatedData;

  DataTableExample({required this.aggregatedData});

  List<DataRow> _buildRows() {
    return aggregatedData.entries.map((entry) {
      var data = entry.value;
      return DataRow(cells: [
        DataCell(Center(
            child: Text(data['type'].toString(),
                style: const TextStyle(color: Colors.black)))),
        DataCell(Center(
            child: Text(data['color'].toString(),
                style: const TextStyle(color: Colors.black)))),
        DataCell(Center(
            child: Text('${data['width']} mm',
                style: const TextStyle(color: Colors.black)))),
        DataCell(Center(
            child: Text('${data['yarn_number']} D',
                style: const TextStyle(color: Colors.black)))),
        DataCell(Center(
            child: Text('${data['quantity']} Pcs',
                style: const TextStyle(color: Colors.black)))),
        DataCell(Center(
            child: Text('${data['length']} Mt',
                style: const TextStyle(color: Colors.black)))),
        DataCell(Center(
            child: Text('${data['total_weight']} Kg',
                style: const TextStyle(color: Colors.black)))),
        DataCell(Center(
            child: Text(data['scanned_data'].toString(),
                style: const TextStyle(color: Colors.black)))),
      ]);
    }).toList();
  }

  List<DataColumn> _buildColumns() {
    return [
      DataColumn(
          label: Text('Type', style: TextStyle(color: Colors.greenAccent))),
      DataColumn(
          label: Text('Color', style: TextStyle(color: Colors.greenAccent))),
      DataColumn(
          label: Text('Width', style: TextStyle(color: Colors.greenAccent))),
      DataColumn(
          label:
              Text('Yarn Number', style: TextStyle(color: Colors.greenAccent))),
      DataColumn(
          label: Text('Quantity', style: TextStyle(color: Colors.greenAccent))),
      DataColumn(
          label: Text('Length', style: TextStyle(color: Colors.greenAccent))),
      DataColumn(
          label: Text('Weight', style: TextStyle(color: Colors.greenAccent))),
      DataColumn(
          label: Text('Scanned Data',
              style: TextStyle(color: Colors.greenAccent))),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Data Table Example')),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: _buildColumns(),
          rows: _buildRows(),
        ),
      ),
    );
  }
}


/*

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

import '../../data/dataBase.dart';
import '../../provider/invoice_provider.dart';
import '../../service/invoice_service.dart'; // استيراد مزود البيانات

class DocumentDropdown extends StatefulWidget {
  final void Function(dynamic itemSelected) onItemSelected;

  const DocumentDropdown({super.key, required this.onItemSelected});

  @override
  _DocumentDropdownState createState() => _DocumentDropdownState();
}

class _DocumentDropdownState extends State<DocumentDropdown> {
  List<MultiSelectItem<String>> _items = [];
  final InvoiceNewAddService _invoiceService = InvoiceNewAddService();

  @override
  void initState() {
    super.initState();
    fetchDocuments();
  }

  // جلب البيانات من الفايربيس

  Future<void> fetchDocuments() async {
    // جلب البيانات من فايربيس
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('seles')
        .where('not_attached_to_client', isEqualTo: false)
        .get();

    List<MultiSelectItem<String>> items = [];
    List<DocumentSnapshot> documents = [];

    // إنشاء قائمة العناصر والمستندات
    for (var doc in querySnapshot.docs) {
      String documentName = doc.id;
      items.add(MultiSelectItem<String>(documentName, documentName));
      documents.add(doc); // إضافة المستند إلى القائمة

      // تحويل بيانات المستند إلى JSON
      String jsonData = jsonEncode(doc.data());

      // إدراج البيانات في قاعدة البيانات المحلية SQLite
      DatabaseHelper().insertCodeDetails(documentName, jsonData);
      DatabaseHelper().insertScannedData(documentName);
      print('Inserted into SQLite - Code: $documentName, Data: $jsonData');
    }

    // حفظ البيانات في DocumentProvider
    // Provider.of<InvoiceProvider>(context, listen: false).setSelectedDocuments(   items.map((item) => item.value).toList(), documents);
// عرض البيانات في وحدة التحكم للتأكد
    print(
        "Selected Document IDs: ${Provider.of<InvoiceProvider>(context, listen: false).selectedDocumentIds}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data saved to provider!')),
    );
    // تحديث حالة العناصر في واجهة المستخدم
    setState(() {
      _items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    return Column(
      children: [
        Container(
          height: 100,
          child: MultiSelectDialogField(
            items: _items,
            title: Text("Select Scanned Data"),
            buttonText: Text("Select Items"),
            onConfirm: (List<String> selected) async {
              List<Map<String, dynamic>> selectedDocuments = [];
/*
              for (var documentId in selected) {
                try {
                  // جلب بيانات المستند من Provider
                  List<DocumentSnapshot<Object?>> documents =
                      documentProvider.selectedDocuments;
                  for (var document in documents) {
                    if (document.id == documentId) {
                      Map<String, dynamic> documentData =
                          document.data() as Map<String, dynamic>;
                      selectedDocuments.add(documentData);
                    }
                  }
                } catch (e) {
                  print('Error: $e');
                }
              }


              for (var documentId in selected) {
                try {
                  // جلب بيانات المستند من SQLite بدلاً من Firebase
                  Map<String, dynamic>? documentData =
                      await DatabaseHelper().getCodeDetails(documentId);
                  if (documentData != null) {
                    selectedDocuments.add(documentData);
                    widget.onItemSelected(selectedDocuments);
                  } else {
                    print(
                        'Error: documentData is null for documentId $documentId');
                  }
                } catch (e) {
                  print('Error: $e');
                }
              }
              */
              // طباعة البيانات للتحقق
              //     print('Selected Documents from SQLite: $documentData');

              print('Selected Documents from SQLite: $selectedDocuments');
              widget.onItemSelected(selectedDocuments);
            },
            listType: MultiSelectListType.LIST,
          ),
        ),
      ],
    );
  }
}


*/