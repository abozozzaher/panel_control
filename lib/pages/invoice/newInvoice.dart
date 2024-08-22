import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';
import '../../data/dataBase.dart';
import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../model/invoice.dart';
import '../../provider/invoice_provider.dart';
import '../../provider/trader_provider.dart';
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
    final List<Map<String, dynamic>> data = [];
    for (String documentId in scannedData) {
      final documentSnapshot = await FirebaseFirestore.instance
          .doc('/products/productsForAllMonths/2024-08/$documentId')
          .get();
      data.add(documentSnapshot.data() as Map<String, dynamic>);
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final documentProvider =
        Provider.of<DocumentProvider>(context, listen: false);
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
                            _selectedCode =
                                selectedCode; // Update the selected code
                          });

                          print(
                              'Selected Code: $selectedCode'); // للتحقق من الكود المحدد

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

                          if (selectedClient != null) {
                            print(
                                'Client found: ${selectedClient.fullNameEnglish}'); // التحقق من العثور على العميل

                            // حفظ بيانات العميل في Provider
                            provider.setTrader(selectedClient);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Client saved successfully')),
                            );
                          } else {
                            print(
                                'Client not found'); // في حالة عدم العثور على العميل
                          }
                        }
                      });
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

                  ///
                  /// وصلت هنا يجب حفظ البيانات في قاعدة البيانات
                  return FutureBuilder(
                    future: _fetchDocumentData(scannedData),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data =
                            snapshot.data as List<Map<String, dynamic>>;
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
                      } else {
                        return Text(S().no_data_found_for_this_code,
                            textAlign: TextAlign.center);
                      }
                    },
                  );
                },
              ),

/*
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

                  print(scannedData);
                  return FutureBuilder(
                    future: _fetchDocumentData(scannedData),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final data =
                            snapshot.data as List<Map<String, dynamic>>;
                        print('$data 3456765');
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ListTile(
                              title: Text(codeSales.toString()),

                              //     subtitle: Text(data.map((e) => e['color']).join(', ')),
                            ),
                            ...data.map((map) {
                              return ListTile(
                                title: Text(map.keys.join(': ')),
                                subtitle: Text(map.values.join(', ')),
                              );
                            }).toList(),
                          ],
                        );
                      } else {
                        return ListTile(
                          title: Text(codeSales.toString()),
                          subtitle: Text('Loading...'),
                        );
                      }
                    },
                  );
                },
              ),
*/
              ElevatedButton(
                  onPressed: () {}, child: const Text('Save Invoice')),
            ],
          ),
        ),
      ),
    );
  }
}

/*

// بعدسن اعمل فيه لاعادة تصنيف الصفحات

class InvoiceNewAdd extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const InvoiceNewAdd(
      {super.key, required this.toggleTheme, required this.toggleLocale});
  @override
  _InvoiceNewAddState createState() => _InvoiceNewAddState();
}

class _InvoiceNewAddState extends State<InvoiceNewAdd> {
  String? invoiceCode;
//  List<String> selectedDocuments = [];
  List<String> scannedData = [];
  List<DocumentSnapshot> documentSnapshots = [];
  bool _traderSelected = false; // new flag
  bool _itemSelected = false;
  @override
  void initState() {
    super.initState();
    invoiceCode = generateInvoiceCode();
  }

  String generateInvoiceCode() {
    final DateTime now = DateTime.now();
    final String formattedDate =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour}';
    return 'INV-$formattedDate';
  }

  @override
  Widget build(BuildContext context) {
    print('sss1sss');

    // print(selectedDocuments);
    print(scannedData);
    print(documentSnapshots);
    print('ssssss');
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Invoice', textAlign: TextAlign.center),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // عرض كود الفاتورة
            Text('Invoice Code: $invoiceCode',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            const SizedBox(height: 16),

            // منسدلة اختيار التاجر
            const Text('Select Trader', style: TextStyle(fontSize: 16)),
            TraderDropdown(
              onTraderSelected: (trader) {
                setState(() {
                  _traderSelected = true;
                });
              },
            ),

            const SizedBox(height: 16),

            // منسدلة اختيار المستندات
            //    Text('Select Documents', style: TextStyle(fontSize: 16)),
            _traderSelected
                ? const Text('Select Documents', style: TextStyle(fontSize: 16))
                : const Text('Please select a trader first',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
            _traderSelected
                ? DocumentDropdown(
                    onItemSelected: (itemSelected) {
                      setState(() {
                        _itemSelected = true;
                      });
                    },
                  )
                : Container(),

            const SizedBox(height: 16),

            const Text('Scanned Data', style: TextStyle(fontSize: 16)),
            _itemSelected
                ? Expanded(child: ScannedDataList())
                : const Text('no data'),

            const SizedBox(height: 16),

            // زر حفظ الفاتورة
            ElevatedButton(
              onPressed: () {
                print('$scannedData هنا الداتا بعد النقر على الزر');
                // جلب التاجر المحدد
                final traderProvider =
                    Provider.of<TraderProvider>(context, listen: false);
                print(
                    '${traderProvider.trader!.address}  هنا الداتا بعد النقر على الزر تظهر معلومات التاجر');

                // التحقق من وجود التاجر والمستندات
                if (traderProvider.trader!.codeIdClien.isEmpty ||
                    scannedData.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please select trader and documents')));
                  return;
                }

                // إنشاء الفاتورة
                final invoice = Invoice(
                  invoiceCode: invoiceCode!,
                  traderCode: traderProvider.trader!.codeIdClien,
                  documentCodes: scannedData,
                  scannedData: scannedData,
                );

                // قم بحفظ الفاتورة في Firebase أو أي تخزين آخر
                saveInvoice(invoice);

                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invoice Saved')));
              },
              child: const Text('Save Invoice'),
            ),
          ],
        ),
      ),
    );
  }

  // دالة حفظ الفاتورة
  void saveInvoice(Invoice invoice) {
    // أضف الكود هنا لحفظ الفاتورة في قاعدة البيانات (Firebase مثلاً)
  }
}


*/
