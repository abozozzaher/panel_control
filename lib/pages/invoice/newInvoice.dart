import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:panel_control/pages/invoice/invoiceTablo.dart';
import 'package:provider/provider.dart';
import '../../data/dataBase.dart';
import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../provider/invoice_provider.dart';
import '../../provider/scan_item_provider.dart';
import '../../provider/trader_provider.dart';

class InvoiceNewAdd extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const InvoiceNewAdd(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  State<InvoiceNewAdd> createState() => _InvoiceNewAddState();
}

class _InvoiceNewAddState extends State<InvoiceNewAdd> {
  final InvoiceTablo invoiceTablo = InvoiceTablo();
  final InvoiceProvider invoiceService = InvoiceProvider();
  List<String> selectedItems = [];

  String? invoiceCode;
  List<String> scannedData = [];
  List<DocumentSnapshot> documentSnapshots = [];
  // bool _traderSelected = false; // new flag
  // bool _itemSelected = false;
  List<MultiSelectItem<String>> _items = [];

  List<ClienData> clients = [];
  bool isLoading = true;
  String? _selectedCode;
  @override
  void initState() {
    super.initState();
    invoiceCode = generateInvoiceCode();
    fetchClientsFromFirebase();
    fetchDocuments();
    _loadSelectedItems();
  }

  Future<void> _loadSelectedItems() async {
    final items = await invoiceService.loadSelectedItems();
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);

    invoiceProvider.setSelectedItems(items);
    // invoiceProvider.loadSelectedItems();
  }

  String generateInvoiceCode() {
    final DateTime now = DateTime.now();
    final String formattedDate =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour}';
    return 'INV-$formattedDate';
  }

  Future<void> fetchClientsFromFirebase() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('cliens').get();
      setState(() {
        clients = snapshot.docs.map((doc) {
          return ClienData.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching clients: $e');
      setState(() {
        isLoading = false;
      });
    }
  }
  // جلب البيانات من الفايربيس

  Future<void> fetchDocuments() async {
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
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
    invoiceProvider.setSelectedDocuments(
        items.map((item) => item.value).toList(), documents);
// عرض البيانات في وحدة التحكم للتأكد
    print("Selected Document IDs: ${invoiceProvider.selectedDocumentIds}");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Data saved to provider!')),
    );

    // تحديث حالة العناصر في واجهة المستخدم
    setState(() {
      _items = items;
    });
  }

  Future<List<Map<String, dynamic>>> _fetchDocumentData(
      List<dynamic> scannedData) async {
    final provider = Provider.of<ScanItemProvider>(context, listen: false);
    final List<Map<String, dynamic>> data = [];
    print(scannedData);
    // تحديد المستندات التي يجب تحميلها من Firebase
    final documentsToFetch = scannedData
        .where((documentId) => provider.codeDetails[documentId] == null)
        .toList();

    // تحميل البيانات من Firebase
    for (String documentId in documentsToFetch) {
      final monthFolder =
          '${documentId.substring(0, 4)}-${documentId.substring(4, 6)}';
      final documentSnapshot = await FirebaseFirestore.instance
          .doc('/products/productsForAllMonths/$monthFolder/$documentId')
          .get();

      if (documentSnapshot.exists) {
        final dataData = documentSnapshot.data() as Map<String, dynamic>;

        // إضافة البيانات إلى القائمة
        data.add(dataData);

        // تحديث provider
        provider.codeDetails[documentId] = dataData;
        provider.addScannedData(documentId);
        provider.addCodeDetails(documentId);
        provider.saveCodeDetails(documentId, dataData);
      } else {
        print('Document with ID $documentId does not exist.');
      }
    }

    // التحقق من القيم الجديدة أو التي تمت إزالتها
    final existingDocumentIds = provider.codeDetails.keys.toSet();
    final scannedDocumentIds = scannedData.toSet();

    // العثور على القيم الجديدة
    final newDocumentIds = scannedDocumentIds.difference(existingDocumentIds);
    if (newDocumentIds.isNotEmpty) {
      print('New document IDs: $newDocumentIds');
      // هنا يمكنك تنفيذ أي عملية إضافية للقيم الجديدة إذا لزم الأمر
    }

    // العثور على القيم القديمة التي تمت إزالتها
    final removedDocumentIds =
        existingDocumentIds.difference(scannedDocumentIds);
    if (removedDocumentIds.isNotEmpty) {
      print('Removed document IDs: $removedDocumentIds');
      // إزالة القيم القديمة من provider
      for (String removedId in removedDocumentIds) {
        provider.codeDetails.remove(removedId);
        // قم بإزالة أي معلومات ذات صلة من provider إذا لزم الأمر
      }
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final providerScanItem = Provider.of<ScanItemProvider>(context);
    final codeDetails = providerScanItem.codeDetails;
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Invoice', textAlign: TextAlign.center),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Invoice Code: $invoiceCode',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Select Trader', style: TextStyle(fontSize: 16)),
              Consumer<TraderProvider>(
                builder: (context, provider, child) {
                  if (isLoading) {
                    return CircularProgressIndicator();
                  }

                  return DropdownButton<String>(
                    hint: Text('Select Client'),
                    isExpanded: true,
                    value: _selectedCode,
                    items: clients.map((client) {
                      return DropdownMenuItem<String>(
                        value: client.codeIdClien,
                        child: Text(client.fullNameEnglish),
                      );
                    }).toList(),
                    onChanged: (String? selectedCode) async {
                      if (selectedCode != null) {
                        setState(() {
                          _selectedCode = selectedCode;
                        });

                        print('Selected Code: $selectedCode');

                        final selectedClient = clients.firstWhere(
                          (client) => client.codeIdClien == selectedCode,
                          orElse: () => ClienData(
                            fullNameArabic: '',
                            fullNameEnglish: '',
                            address: '',
                            phoneNumber: '',
                            createdAt: DateTime.now(),
                            codeIdClien: '',
                          ),
                        );

                        print(
                            'Client found: ${selectedClient.fullNameEnglish}');

                        provider.setTrader(selectedClient);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Client saved successfully')),
                        );
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('Select Documents', style: TextStyle(fontSize: 16)),
              Container(
                height: 100,
                child: MultiSelectDialogField(
                  items: _items,
                  title: Text("Select Scanned Data"),
                  buttonText: Text("Select Items"),
                  initialValue: invoiceProvider.selectedDocumentIds,
                  onConfirm: (List<String> selected) async {
                    setState(() {
                      selectedItems = selected;
                      invoiceProvider.setSelectedItems(selected);
                      invoiceProvider.saveSelectedItems(selected);
                    });
                  },
                  listType: MultiSelectListType.LIST,
                ),
              ),
              FutureBuilder<Map<String, Map<String, dynamic>>>(
                future: _mergeDataFromSelectedItems(
                    invoiceProvider.selectedDocumentIds),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No data found'));
                  } else {
                    final aggregatedData = snapshot.data!;

                    return Container(
                      color: Colors.grey[200],
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: _buildColumns(),
                            rows: _buildRows(aggregatedData),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
              ElevatedButton(
                  onPressed: () {}, child: const Text('Save Invoice')),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, Map<String, dynamic>>> _mergeDataFromSelectedItems(
      List<String> selectedItems) async {
    Map<String, Map<String, dynamic>> aggregatedData = {};
    final documentsProvider = Provider.of<InvoiceProvider>(context);

    for (var documentId in selectedItems) {
      final document = documentsProvider.selectedDocuments
          .firstWhere((doc) => doc.id == documentId);
      final scannedData = document['scannedData'] ?? [];

      // Fetch document data
      final data = await _fetchDocumentData(scannedData);
      final codeDetails = data as List<Map<String, dynamic>>;

      // Merge data
      for (var entry in codeDetails) {
        String key =
            '${entry['yarn_number']}-${entry['type']}-${entry['color']}-${entry['width']}';

        if (!aggregatedData.containsKey(key)) {
          aggregatedData[key] = {
            'yarn_number': entry['yarn_number'],
            'type': entry['type'],
            'color': entry['color'],
            'width': entry['width'],
            'total_weight': 0,
            'quantity': 0,
            'length': 0,
            'scanned_data': 0,
          };
        }
        aggregatedData[key]!['total_weight'] += entry['total_weight'] is int
            ? entry['total_weight']
            : int.tryParse(entry['total_weight'].toString()) ?? 0;
        aggregatedData[key]!['quantity'] += entry['quantity'] is int
            ? entry['quantity']
            : int.tryParse(entry['quantity'].toString()) ?? 0;
        aggregatedData[key]!['length'] += entry['length'] is int
            ? entry['length']
            : int.tryParse(entry['length'].toString()) ?? 0;
        aggregatedData[key]!['scanned_data'] =
            (aggregatedData[key]!['scanned_data'] ?? 0) + 1;
      }
    }

    return aggregatedData;
  }

  List<DataRow> _buildRows(Map<String, Map<String, dynamic>> aggregatedData) {
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
          label: Text(S().type, style: TextStyle(color: Colors.greenAccent))),
      DataColumn(
          label: Text(S().color, style: TextStyle(color: Colors.greenAccent))),
      DataColumn(
          label: Text(S().width, style: TextStyle(color: Colors.greenAccent))),
      DataColumn(
          label: Text(S().yarn_number,
              style: TextStyle(color: Colors.greenAccent))),
      DataColumn(
          label:
              Text(S().quantity, style: TextStyle(color: Colors.greenAccent))),
      DataColumn(
          label: Text(S().length, style: TextStyle(color: Colors.greenAccent))),
      DataColumn(
          label: Text('${S().weight} ${S().total}',
              style: TextStyle(color: Colors.greenAccent))),
      DataColumn(
          label:
              Text(S().scanned, style: TextStyle(color: Colors.greenAccent))),
    ];
  }
}
