import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:panel_control/generated/l10n.dart';
import 'package:provider/provider.dart';

import '../../data/dataBase.dart';
import '../../provider/invoice_provider.dart';

class DialogInvoice extends StatefulWidget {
  @override
  _DialogInvoiceState createState() => _DialogInvoiceState();
}

class _DialogInvoiceState extends State<DialogInvoice> {
  final DatabaseHelper databaseHelper = DatabaseHelper();

  List<Map<String, dynamic>> items = [];
  Map<String, bool> selectionState = {};
  Map<String, Map<String, dynamic>> itemsData = {};
  @override
  void initState() {
    super.initState();
    _fetchItems();
  }

  Future<void> _fetchItems() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('seles')
          .where('not_attached_to_client', isEqualTo: false)
          .get();

      final List<Map<String, dynamic>> fetchedItems = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      setState(() {
        items = fetchedItems;

        final invoiceProvider =
            Provider.of<InvoiceProvider>(context, listen: false);

        selectionState = {
          for (var item in items)
            item['codeSales'] as String:
                invoiceProvider.selectionState[item['codeSales'] as String] ??
                    false
        };
        itemsData = {for (var item in items) item['codeSales'] as String: item};
      });
    } catch (e) {
      print('Error fetching items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    return AlertDialog(
      title: Text(S().select_items, textAlign: TextAlign.center),
      content: items.isEmpty
          ? Center(
              child: Column(
              children: [
                CircularProgressIndicator.adaptive(),
                Text(S().no_data_found)
              ],
            ))
          : Container(
              width: 300, // adjust the width to your needs
              height: 200,
              child: SingleChildScrollView(
                child: ListView(
                  shrinkWrap: true,
                  children: items.map((item) {
                    final itemId = item['codeSales'] as String;
                    return CheckboxListTile(
                      title: Text(item['codeSales']),
                      value: selectionState[itemId] ?? false,
                      onChanged: (isChecked) {
                        setState(() {
                          selectionState[itemId] = isChecked ?? false;
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
      actions: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S().cancel),
            ),
            TextButton(
              onPressed: () {
                // حفظ التحديد في البروفيدر
                invoiceProvider.setSelectionState(selectionState, itemsData);
                print(selectionState);
                print(itemsData);
                Navigator.of(context).pop();
              },
              child: Text(S().save_and_send_data),
            ),
          ],
        ),
      ],
    );
  }
}