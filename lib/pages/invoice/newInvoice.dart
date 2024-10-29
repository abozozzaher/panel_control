import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../provider/invoice_provider.dart';
import '../../provider/trader_provider.dart';
import '../../service/invoice_service.dart';
import '../clien/traderDropdownForInvoice.dart';
import 'dataTabelFetcher.dart';
import 'dialosForCodeScannSalers.dart';

class InvoiceNewAdd extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const InvoiceNewAdd(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  State<InvoiceNewAdd> createState() => _InvoiceNewAddState();
}

class _InvoiceNewAddState extends State<InvoiceNewAdd> {
  final DialogInvoice dialogInvoice = const DialogInvoice();
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
            icon: const Icon(Icons.home))
      ]),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('${S().invoice_code}: $invoiceCode'),
              // بيانات التاجر منسدلة اختيار التاجر
              const SizedBox(height: 20),
              const TraderDropdownForInvoice(),
              const SizedBox(height: 20),
              // مندسلة الطلبات التي تم مسحها من قبل العامل
              trader == null
                  ? Center(child: Text(S().no_trader_selected))
                  : ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const DialogInvoice(),
                        );
                      },
                      icon: const Icon(Icons.list),
                      label: Text(S().select_items)),
              const SizedBox(height: 20),
              // الجدول الذي يعرض بيانات الكود التي تم اختيارة من الخيار السابق
              DataTabelFetcher(invoiceCode),
            ],
          ),
        ),
      ),
    );
  }
}
