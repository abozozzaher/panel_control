import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:panel_control/pages/invoice/dataTabelFetcher.dart';
import 'package:panel_control/pages/invoice/invoiceTablo.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../provider/invoice_provider.dart';
import '../../service/invoice_service.dart';
import 'dialos.dart';

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
  final InvoiceService invoiceService = InvoiceService();
  final DialogInvoice dialogInvoice = DialogInvoice();
  String? invoiceCode;
  List<String> scannedData = [];
  List<DocumentSnapshot> documentSnapshots = [];
  // bool _traderSelected = false; // new flag
  // bool _itemSelected = false;
  // List<MultiSelectItem<String>> items = [];

  List<ClienData> clients = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    invoiceCode = invoiceService.generateInvoiceCode();
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    // invoiceProvider.loadSelectedItemData();
    invoiceProvider.loadSelectedItems();
  }

  Future<Map<String, Map<String, dynamic>>> _mergeDataFromSelectedItems(
      Set<String> selectedItems) async {
    print('selectedItems1 $selectedItems');
    Map<String, Map<String, dynamic>> aggregatedData = {};
    final documentsProvider = Provider.of<InvoiceProvider>(context);
    print('selectedDocumentIds2 ${documentsProvider.selectedDocumentIds}');
    print('selectedItemData3 ${documentsProvider.selectedItemData}');
    for (var documentId in selectedItems) {
      final document = documentsProvider.selectedItemData.values
          .firstWhere((doc) => doc['codeSales'] == documentId);

      final scannedData = document['scannedData'];
      print('333333');
      //  final scannedData = document['scannedData'] ?? [];
      print('selectedItems $selectedItems');
      print('aggregatedData $aggregatedData');
      print('document ${document}');
      print('scannedData1 $scannedData');

      // Fetch document data
      final data = await _fetchDocumentData(scannedData);
      //final data = await _fetchDocumentData(documentId);
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

  Future<List<Map<String, dynamic>>> _fetchDocumentData(
      List<dynamic> scannedData) async {
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    final List<Map<String, dynamic>> data = [];

    print(scannedData);

    // تحديد المستندات التي يجب تحميلها من Firebase
    final documentsToFetch = scannedData
        .where((documentId) =>
            invoiceProvider.selectedItemData[documentId] == null)
        .toList();

    // متغير للتحقق من وجود مكررات
    bool hasDuplicate = false;

    // تحميل البيانات من Firebase
    for (String documentId in documentsToFetch) {
      final monthFolder =
          '${documentId.substring(0, 4)}-${documentId.substring(4, 6)}';
      final documentSnapshot = await FirebaseFirestore.instance
          .doc('/products/productsForAllMonths/$monthFolder/$documentId')
          .get();

      if (documentSnapshot.exists) {
        final dataData = documentSnapshot.data() as Map<String, dynamic>;

        // التحقق من وجود بيانات مكررة في invoiceProvider
        if (invoiceProvider.selectedDocumentIds.contains(documentId)) {
          hasDuplicate = true;
          // عرض رسالة Snackbar للتنبيه بوجود كود مكرر
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Duplicate code found: $documentId'),
            ),
          );
        } else {
          // إضافة البيانات إلى القائمة
          data.add(dataData);

          // تحديث invoiceProvider
          invoiceProvider.selectedItemData[documentId] = dataData;
          invoiceProvider.addDocumentData(documentId, dataData);
        }
      } else {
        print('Document with ID $documentId does not exist.');
      }
    }

    // التحقق من وجود مكررات
    if (!hasDuplicate) {
      // إذا لم يكن هناك مكررات، يتم تحديث invoiceProvider
      for (String documentId in documentsToFetch) {
        if (invoiceProvider.selectedItemData[documentId] != null) {
          // تنفيذ تحديث للبروفايدر هنا إذا كان ذلك ضروريًا
          invoiceProvider.updateDocumentData(
              documentId, invoiceProvider.selectedItemData[documentId]!);
        }
      }
    }
    setState(() {});
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
            onPressed: () {
              context.go('/');
            },
            icon: Icon(Icons.home))
      ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Invoice Code: $invoiceCode'),
              ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => DialogInvoice(),
                    );
                  },
                  icon: Icon(Icons.list),
                  label: Text('Select Items')),
              SizedBox(height: 20),
              DataTabelFetcher(),
              SizedBox(height: 20),
              ElevatedButton.icon(
                  onPressed: () {
                    invoiceProvider.deleteData();
                  },
                  label: Text('ssss'))
            ],
          ),
        ),
      ),
    );
  }
}
