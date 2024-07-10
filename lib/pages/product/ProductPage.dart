import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductPage extends StatelessWidget {
  final String? documentId;
  final String? monthFolder;

  const ProductPage(
      {Key? key, required this.documentId, required this.monthFolder})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('products') // اسم المجموعة في Firestore
                .doc(
                    'productsForAllMonths') // اسم المجلد الذي يحتوي على جميع الشهور
                .collection(monthFolder!) // اسم المجلد الشهر
                .doc(documentId) // معرف المستند الذي نريد عرضه
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Text('No data found.');
              }

              var productData = snapshot.data!.data() as Map<String, dynamic>;
              print(monthFolder);
              print(documentId);

              // استخدام البيانات المستردة لعرضها
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Product ID: ${productData['productId']}'),
                  // يمكنك استخدام مزيد من الحقول هنا لعرض المعلومات الأخرى

                  Text('Type: ${productData['type']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Width: ${productData['width']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Weight: ${productData['weight']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Color: ${productData['color']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Yarn Number: ${productData['yarn_number']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Product ID: ${productData['productId']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Date: ${productData['date'].toDate()}',
                      style: const TextStyle(fontSize: 18)),
                  Text('User: ${productData['user']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('User ID: ${productData['user_id']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Shift: ${productData['shift']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('Created By: ${productData['created_by']}',
                      style: const TextStyle(fontSize: 18)),
                  Text(
                      'Sale Status: ${productData['saleـstatus'] ? 'Sold' : 'Available'}',
                      style: const TextStyle(fontSize: 18)),
                  if (productData['image_url'] != '')
                    Image.network(productData['image_url']),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
