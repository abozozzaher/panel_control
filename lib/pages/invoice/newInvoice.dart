import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/invoice.dart';
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
  _InvoiceNewAddState createState() => _InvoiceNewAddState();
}

class _InvoiceNewAddState extends State<InvoiceNewAdd> {
  String? invoiceCode;
  List<String> selectedDocuments = [];
  List<String> scannedData = [];

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
    return Scaffold(
      appBar: AppBar(
        title: Text('New Invoice', textAlign: TextAlign.center),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // عرض كود الفاتورة
            Text('Invoice Code: $invoiceCode',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            SizedBox(height: 16),

            // منسدلة اختيار التاجر
            Text('Select Trader', style: TextStyle(fontSize: 16)),
            TraderDropdown(),

            SizedBox(height: 16),

            // منسدلة اختيار المستندات
            Text('Select Documents', style: TextStyle(fontSize: 16)),
            DocumentDropdown(),

            SizedBox(height: 16),

            // عرض البيانات المستخرجة من المستندات المختارة
            Text('Scanned Data', style: TextStyle(fontSize: 16)),
            //  Expanded(child: ScannedDataList(scannedData)),

            SizedBox(height: 16),

            // زر حفظ الفاتورة
            ElevatedButton(
              onPressed: () {
                // جلب التاجر المحدد
                final traderProvider =
                    Provider.of<TraderProvider>(context, listen: false);

                // التحقق من وجود التاجر والمستندات
                if (traderProvider.trader!.codeIdClien.isEmpty ||
                    selectedDocuments.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Please select trader and documents')));
                  return;
                }

                // إنشاء الفاتورة
                final invoice = Invoice(
                  invoiceCode: invoiceCode!,
                  traderCode: traderProvider.trader!.codeIdClien,
                  documentCodes: selectedDocuments,
                  scannedData: scannedData,
                );

                // قم بحفظ الفاتورة في Firebase أو أي تخزين آخر
                saveInvoice(invoice);

                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Invoice Saved')));
              },
              child: Text('Save Invoice'),
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
