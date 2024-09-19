import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/data_lists.dart';
import '../../generated/l10n.dart';
import '../../service/toasts.dart';

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
          onPressed: () async {
            final Uri url = Uri.parse('https://textile.bluedukkan.com');
            if (await canLaunchUrl(url)) {
              await launchUrl(url);
            } else {
              showToast('${S().could_not_launch_url} #203 $url');
              throw 'Could not launch $url';
            }
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
                return const CircularProgressIndicator.adaptive();
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
// تزبيط شكل عرض صفحة المنتج بشكل افضل والفاتورة فورم
              // استخدام البيانات المستردة لعرضها
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('${S().product_id} : ${productData['productId'] ?? ''}'),
                  Text(
                      '${S().type} : ${DataLists().translateType(productData['type'].toString())}'),
                  Text('${S().width} : ${productData['width']}'),
                  Text('${S().weight} : ${productData['weight']}'),
                  Text(
                      '${S().color} : ${DataLists().translateType(productData['color'].toString())}'),
                  Text('${S().yarn_number} : ${productData['yarn_number']}D'),
                  Text(
                      '${S().sale_status} : ${productData['sale_status'] ? S().sold : S().available}'),
                  //  Image.network(productData['image_url'] == ''  ? 'assets/img/user.png': productData['image_url']),

                  CachedNetworkImage(
                    imageUrl: productData['image_url'] ?? '',
                    placeholder: (context, url) =>
                        Image.asset('assets/img/user.png'),
                    errorWidget: (context, url, error) =>
                        Image.asset('assets/img/user.png'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
