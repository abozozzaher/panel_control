import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? selectedType;
  String? selectedWidth;
  String? selectedWeight;
  String? selectedColor;
  String? selectedThreadNumber;

  List<String> types = [];
  List<String> widths = [];
  List<String> weights = [];
  List<String> colors = [];
  List<String> threadNumbers = [];

  @override
  void initState() {
    super.initState();
    _fetchProductInfo();
  }

  Future<void> _fetchProductInfo() async {
    final productInfo = await _firestore.collection('products_info').get();
    final data = productInfo.docs.map((doc) => doc.data()).toList();

    setState(() {
      types = data.map((e) => e['type'] as String).toList();
      widths = data.map((e) => e['width'] as String).toList();
      weights = data.map((e) => e['weight'] as String).toList();
      colors = data.map((e) => e['color'] as String).toList();
      threadNumbers = data.map((e) => e['thread_number'] as String).toList();
    });
  }

  Future<void> _addProduct() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final now = DateTime.now();
    final formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final productId = 'BLLTTLT$formattedDate';
    final timestamp = now;

    await _firestore.collection('products').doc(productId).set({
      'type': selectedType ?? '',
      'width': selectedWidth ?? '',
      'weight': selectedWeight ?? '',
      'color': selectedColor ?? '',
      'thread_number': selectedThreadNumber ?? '',
      'created_by': user.uid,
      'shift': 1, // تغيير الوردية حسب الحاجة
      'product_id': productId,
      'timestamp': timestamp,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: selectedType,
              items: types.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
              decoration: InputDecoration(labelText: 'Type'),
            ),
            DropdownButtonFormField<String>(
              value: selectedWidth,
              items: widths.map((width) {
                return DropdownMenuItem(
                  value: width,
                  child: Text(width),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedWidth = value;
                });
              },
              decoration: InputDecoration(labelText: 'Width'),
            ),
            DropdownButtonFormField<String>(
              value: selectedWeight,
              items: weights.map((weight) {
                return DropdownMenuItem(
                  value: weight,
                  child: Text(weight),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedWeight = value;
                });
              },
              decoration: InputDecoration(labelText: 'Weight'),
            ),
            DropdownButtonFormField<String>(
              value: selectedColor,
              items: colors.map((color) {
                return DropdownMenuItem(
                  value: color,
                  child: Text(color),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedColor = value;
                });
              },
              decoration: InputDecoration(labelText: 'Color'),
            ),
            DropdownButtonFormField<String>(
              value: selectedThreadNumber,
              items: threadNumbers.map((threadNumber) {
                return DropdownMenuItem(
                  value: threadNumber,
                  child: Text(threadNumber),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedThreadNumber = value;
                });
              },
              decoration: InputDecoration(labelText: 'Thread Number'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProduct,
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
