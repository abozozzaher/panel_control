import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProInvoicePage extends StatelessWidget {
  final String? invoiceId;

  const ProInvoicePage({Key? key, required this.invoiceId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تحقق من صحة معرف الفاتورة
    if (invoiceId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Invalid Invoice')),
        body: Center(child: Text('No Invoice ID provided')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Invoice Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('pro-invoices')
            .doc(invoiceId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return Center(child: Text('Failed to load invoice details'));
          }

          // استرجاع البيانات من المستند
          var data = snapshot.data!.data() as Map<String, dynamic>;
// اصلاح شكلها لعرضها كشكل جدول واضافة زر شير
// 000000
          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Text('Invoice Code: ${data['invoiceCode']}'),
              Text('Trader: ${data['codeIdClien']}'),
              Text('Final Total: \$${data['finalTotal']}'),
              Text('Total Prices: \$${data['totalPrices']}'),
              Text('Tax With Price: \$${data['taxWthiPrice']}'),
              Text('Tax: \$${data['tax']}'),
              Text('Dues: \$${data['dues']}'),
              Text('Shipping Fees: \$${data['shippingFees']}'),
              Text('Download PDF: ${data['downloadUrlPdf']}'),
              SizedBox(height: 20),
              Text('Products:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...data['products'].map<Widget>((product) {
                return ListTile(
                  title: Text('${product['type']} - ${product['color']}'),
                  subtitle: Text(
                      'Yarn: ${product['yarnNumber']}, Length: ${product['totalLength']}, Weight: ${product['totalWeight']}, Units: ${product['totalUnit']}, Quantity: ${product['allQuantity']}, Price: ${product['price']}, Total: ${product['totalPrice']}'),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}
