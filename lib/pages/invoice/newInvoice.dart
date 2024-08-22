import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:panel_control/pages/invoice/invoiceTablo.dart';
import 'package:provider/provider.dart';
import '../../data/dataBase.dart';
import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../model/invoice.dart';
import '../../provider/invoice_provider.dart';
import '../../provider/scan_item_provider.dart';
import '../../provider/trader_provider.dart';
import '../scan/Scanned_data_table_widgets.dart';
import 'TraderDropdown.dart';
import 'docDropdown.dart';
import 'scannedData.dart';

class InvoiceNewAdd extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const InvoiceNewAdd(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  State<InvoiceNewAdd> createState() => _InvoiceNewAddState();
}

class _InvoiceNewAddState extends State<InvoiceNewAdd> {
  List<String> selectedItems = [];

  String? invoiceCode;
//  List<String> selectedDocuments = [];
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
    Provider.of<DocumentProvider>(context, listen: false).setSelectedDocuments(
        items.map((item) => item.value).toList(), documents);
// عرض البيانات في وحدة التحكم للتأكد
    print(
        "Selected Document IDs: ${Provider.of<DocumentProvider>(context, listen: false).selectedDocumentIds}");

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
    final codeDetailes = provider.codeDetails;
    final List<Map<String, dynamic>> data = [];
    for (String documentId in scannedData) {
      final monthFolder =
          '${documentId.substring(0, 4)}-${documentId.substring(4, 6)}';
      final documentSnapshot = await FirebaseFirestore.instance
          .doc('/products/productsForAllMonths/$monthFolder/$documentId')
          .get();
      final dataData = documentSnapshot.data() as Map<String, dynamic>;
      data.add(dataData);
      print('Before adding data: ${provider.codeDetails[documentId]}');

      provider.codeDetails[documentId] = dataData;
      print('After adding data: ${provider.codeDetails[documentId]}');

      provider.addCodeDetails(documentId);
      print('After addCodeDetails: ${provider.codeDetails[documentId]}');

      provider.saveCodeDetails(documentId, dataData);
      print('After saveCodeDetails: ${provider.codeDetails[documentId]}');

      print('object0 $scannedData');

      print('object $documentId');
      print('object2 $data');
      print('object3 $dataData');
      print('2323vdssfdsf');
    }
    return data;
  }

  final InvoiceTablo invoiceTablo = InvoiceTablo();

  @override
  Widget build(BuildContext context) {
    final documentsProvider = Provider.of<DocumentProvider>(context);

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
              // عرض كود الفاتورة
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
                  onConfirm: (List<String> selected) async {
                    setState(() {
                      selectedItems = selected;
                    });
                  },
                  listType: MultiSelectListType.LIST,
                ),
              ),

              ListView.builder(
                shrinkWrap: true,
                itemCount: selectedItems.length,
                itemBuilder: (context, index) {
                  final documentId = selectedItems[index];
                  final document = documentsProvider.selectedDocuments
                      .firstWhere((document) => document.id == documentId);
                  final codeSales = document['codeSales'] ?? 'No Code Sales';
                  final scannedData = document['scannedData'] ?? [];
                  return FutureBuilder(
                    future: _fetchDocumentData(scannedData),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        print('23232 $documentId');
                        if (snapshot.hasData) {
                          final data =
                              snapshot.data as List<Map<String, dynamic>>;
                          print('232323333 ${data}');
                          return invoiceTablo
                              .scrollViewScannedDataTableWidget(context);
                          /*
                          return DataTable(
                            columns: data.first.keys.map((key) {
                              return DataColumn(
                                label: Text(key),
                              );
                            }).toList(),
                            rows: data.map((map) {
                              return DataRow(
                                cells: map.keys.map((key) {
                                  return DataCell(
                                    Text(map[key].toString()),
                                  );
                                }).toList(),
                              );
                            }).toList(),
                          );
                          */
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return Text('No data found for this code');
                        }
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  );
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
}
