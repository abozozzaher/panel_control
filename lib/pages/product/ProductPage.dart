import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';

class ProductPage extends StatelessWidget {
  final String? productId;
  final String? monthFolder;

  const ProductPage(
      {super.key, required this.productId, required this.monthFolder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S().product_details),
        centerTitle: true, // توسيط العنوان
        leading: IconButton(
          // زر في الطرف الأيسر
          icon: const Icon(Icons.web),
          onPressed: () {
            _launchURL('https://textile.bluedukkan.com'); // تحديد الرابط هنا
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('products') // اسم المجموعة في Firestore
                .doc(
                    'productsForAllMonths') // اسم المجلد الذي يحتوي على جميع الشهور
                .collection(monthFolder!) // اسم المجلد الشهر
                .doc(productId) // معرف المستند الذي نريد عرضه
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('${S().error} : ${snapshot.error}');
              }
              if (!snapshot.hasData || snapshot.data == null) {
                return Text(S().no_data_found);
              }

              var productData = snapshot.data!.data() as Map<String, dynamic>;
              print(monthFolder);
              print(productId);

              // استخدام البيانات المستردة لعرضها
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('${S().product_id} : ${productData['productId'] ?? ''}'),
                  Text('${S().type} : ${productData['type'] ?? ''}',
                      style: const TextStyle(fontSize: 18)),
                  Text('${S().width} : ${productData['width']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('${S().weight} : ${productData['weight']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('${S().color} : ${productData['color']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('${S().yarn_number} : ${productData['yarn_number']}',
                      style: const TextStyle(fontSize: 18)),
                  Text('${S().data} : ${productData['date'].toDate()}',
                      style: const TextStyle(fontSize: 18)),
                  Text('${S().shift} : ${productData['shift']}',
                      style: const TextStyle(fontSize: 18)),
                  Text(
                      '${S().sale_status} : ${productData['saleـstatus'] ? S().sold : S().available}',
                      style: const TextStyle(fontSize: 18)),
                  //    if (productData['image_url'] != '') Image.network(productData['image_url']),
                  // productData['image_url'] != ''   ? Image.network(productData['image_url'])  : Image.asset('/assets/img/loading.gif'),
                  Image.network(
                      productData['image_url'] ?? 'assets/img/loading.gif'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // دالة لفتح رابط الويب
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
