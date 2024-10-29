import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../generated/l10n.dart';
import '../../model/clien.dart';
import '../../provider/invoice_provider.dart';
import '../../provider/trader_provider.dart';
import '../../service/invoice_service.dart';
import '../clien/addClien.dart';
import '../clien/traderDropdownForInvoice.dart';
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
            icon: const Icon(Icons.home))
      ]),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${S().invoice_code}: $invoiceCode'),
            // بيانات التاجر منسدلة اختيار التاجر
            const SizedBox(height: 20),
            const TraderDropdownForInvoice(),
            const SizedBox(height: 20),
            // الجدول الذي يعرض بيانات الكود التي تم اختيارة من الخيار السابق
            trader == null
                ? // زر إضافة عميل
                Center(
                    child: ElevatedButton(
                        onPressed: () {
                          // الانتقال إلى صفحة ClientEntryPage
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ClienEntryPage(
                                  toggleTheme: widget.toggleTheme,
                                  toggleLocale: widget.toggleTheme),
                            ),
                          );
                          // هنا تضيف الكود الذي سيتم تنفيذه عند الضغط على الزر
                        },
                        child:
                            Text(S().add_clien, textAlign: TextAlign.center)),
                  )
                : DataTabelFetcherForProInv(invoiceCode),
          ],
        ),
      ),
    );
  }
}
