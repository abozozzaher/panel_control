import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:panel_control/pages/invoice/TraderDropdown.dart';
import 'package:panel_control/pages/invoice/dataTabelFetcher.dart';
import 'package:provider/provider.dart';
import '../../data/dataBase.dart';
import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../provider/invoice_provider.dart';
import '../../provider/trader_provider.dart';
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
  final DialogInvoice dialogInvoice = DialogInvoice();
  final DatabaseHelper _dbHelper = DatabaseHelper();

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
    final invoiceProvider =
        Provider.of<InvoiceProvider>(context, listen: false);
    invoiceProvider.loadSelectedItems();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceProvider = Provider.of<InvoiceProvider>(context);
    final InvoiceService invoiceService =
        InvoiceService(context, invoiceProvider);
    final trader = Provider.of<TraderProvider>(context).trader;

    invoiceCode = invoiceService.generateInvoiceCode();

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
              Text('${S().invoice_code}: $invoiceCode'),
              // بيانات التاجر منسدلة اختيار التاجر
              SizedBox(height: 20),
              TraderDropdown(),
              SizedBox(height: 20),
              // مندسلة الطلبات التي تم مسحها من قبل العامل
              trader == null

                  /// 454545
                  ? Center(child: Text('No trader selected'))
                  : ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => DialogInvoice(),
                        );
                      },
                      icon: Icon(Icons.list),
                      label: Text(S().select_items)),
              SizedBox(height: 20),
              // الجدول الذي يعرض بيانات الكود التي تم اختيارة من الخيار السابق
              DataTabelFetcher(),
            ],
          ),
        ),
      ),
    );
  }
}
