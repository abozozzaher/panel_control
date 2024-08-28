import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:panel_control/pages/invoice/dataTabelFetcher.dart';
import 'package:provider/provider.dart';
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
  final InvoiceService invoiceService = InvoiceService();
  final DialogInvoice dialogInvoice = DialogInvoice();
  String? invoiceCode;
  List<String> scannedData = [];
  List<DocumentSnapshot> documentSnapshots = [];
  // bool _traderSelected = false; // new flag
  // bool _itemSelected = false;

  List<ClienData> clients = [];
//  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    invoiceCode = invoiceService.generateInvoiceCode();
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    invoiceProvider.loadSelectedItems();
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
