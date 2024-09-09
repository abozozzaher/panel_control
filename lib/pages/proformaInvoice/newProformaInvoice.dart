import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:panel_control/pages/clien/traderDropdownForInvoice.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../provider/invoice_provider.dart';
import '../../provider/trader_provider.dart';
import '../../service/invoice_service.dart';
import 'dataTabelFetcherForProInv.dart';

class NewProformaInvoiceAdd extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const NewProformaInvoiceAdd(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  State<NewProformaInvoiceAdd> createState() => _NewProformaInvoiceAddState();
}

class _NewProformaInvoiceAddState extends State<NewProformaInvoiceAdd> {
//  final DatabaseHelper _dbHelper = DatabaseHelper();

  String? invoiceCode;
  List<String> scannedData = [];
  List<DocumentSnapshot> documentSnapshots = [];

  List<ClienData> clients = [];
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
              TraderDropdownForInvoice(),
              SizedBox(height: 20),
              // الجدول الذي يعرض بيانات الكود التي تم اختيارة من الخيار السابق
              //   trader == null                  ? Center(child: Text(S().no_trader_selected))                  :
              DataTabelFetcherForProInv(invoiceCode),
            ],
          ),
        ),
      ),
    );
  }
}
