import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductPage extends StatelessWidget {
  final String productId;

  ProductPage({required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .get(),
        builder: (context, snapshot) {
          print(productId);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Product not found'));
          } else {
            var productData = snapshot.data!.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
              ),
            );
          }
        },
      ),
    );
  }
}
