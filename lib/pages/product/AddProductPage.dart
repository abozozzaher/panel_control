import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  String? selectedType;
  String? selectedOffer;
  String? selectedWeight;
  String? selectedColor;
  String? selectedThreadNumber;

  List<String> types = [];
  List<String> offers = [];
  List<String> weights = [];
  List<String> colors = [];
  List<String> threadNumbers = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Load product types
      DocumentSnapshot typesDoc = await firestore
          .collection('products_info')
          .doc('product_types')
          .get();
      if (typesDoc.exists) {
        Map<String, dynamic>? data = typesDoc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('types')) {
          types = List<String>.from(data['types']);
        } else {
          print('No types found');
        }
      }

      // Load offers
      DocumentSnapshot offersDoc =
          await firestore.collection('products_info').doc('offers').get();
      if (offersDoc.exists) {
        Map<String, dynamic>? data = offersDoc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('values')) {
          offers = List<String>.from(data['values']);
        } else {
          print('No offers found');
        }
      }

      // Load weights
      DocumentSnapshot weightsDoc =
          await firestore.collection('products_info').doc('weights').get();
      if (weightsDoc.exists) {
        Map<String, dynamic>? data = weightsDoc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('values')) {
          weights = List<String>.from(data['values']);
        } else {
          print('No weights found');
        }
      }

      // Load colors
      DocumentSnapshot colorsDoc =
          await firestore.collection('products_info').doc('colors').get();
      if (colorsDoc.exists) {
        Map<String, dynamic>? data = colorsDoc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('values')) {
          colors = List<String>.from(data['values']);
        } else {
          print('No colors found');
        }
      }

      // Load thread numbers
      DocumentSnapshot threadNumbersDoc = await firestore
          .collection('products_info')
          .doc('thread_numbers')
          .get();
      if (threadNumbersDoc.exists) {
        Map<String, dynamic>? data =
            threadNumbersDoc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('values')) {
          threadNumbers = List<String>.from(data['values']);
        } else {
          print('No thread numbers found');
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      // يمكنك عرض رسالة خطأ للمستخدم هنا
    }
  }

/*
  Future<void> loadData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot typesDoc = await firestore
          .collection('products_info')
          .doc('product_types')
          .get();
      DocumentSnapshot offersDoc =
          await firestore.collection('products_info').doc('offers').get();
      DocumentSnapshot weightsDoc =
          await firestore.collection('products_info').doc('weights').get();
      DocumentSnapshot colorsDoc =
          await firestore.collection('products_info').doc('colors').get();
      DocumentSnapshot threadNumbersDoc = 
          await firestore.collection('products_info').doc('thread_numbers').get();

      setState(() {
        types = List<String>.from(typesDoc['types']);
        offers = List<String>.from(offersDoc['values']);
        weights = List<String>.from(weightsDoc['values']);
        colors = List<String>.from(colorsDoc['values']);
        threadNumbers = List<String>.from(threadNumbersDoc['values']);
        isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      // يمكنك عرض رسالة خطأ للمستخدم هنا
    }
  }

*/
  void addItem() {
    String code = generateCode();
    FirebaseFirestore.instance.collection('products').add({
      'type': selectedType,
      'offer': selectedOffer,
      'weight': selectedWeight,
      'color': selectedColor,
      'thread_number': selectedThreadNumber,
      'code': code,
      'date': DateTime.now(),
      'user': 'user.uid', // يجب تحديث هذا باسم المستخدم الفعلي
      'shift': 1, // أو 2 أو 3 بناءً على التغيير الحالي
    });
  }

  String generateCode() {
    String date = DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '');
    return 'BLLTTLT${date}0001'; // يجب أن يتم تحديث الرقم التسلسلي بشكل ديناميكي
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Item'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  DropdownButton<String>(
                    hint: Text('Select Type'),
                    value: selectedType,
                    onChanged: (newValue) {
                      setState(() {
                        selectedType = newValue;
                      });
                    },
                    items: types.map((type) {
                      return DropdownMenuItem(
                        child: Text(type),
                        value: type,
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    hint: Text('Select Offer'),
                    value: selectedOffer,
                    onChanged: (newValue) {
                      setState(() {
                        selectedOffer = newValue;
                      });
                    },
                    items: offers.map((offer) {
                      return DropdownMenuItem(
                        child: Text(offer),
                        value: offer,
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    hint: Text('Select Weight'),
                    value: selectedWeight,
                    onChanged: (newValue) {
                      setState(() {
                        selectedWeight = newValue;
                      });
                    },
                    items: weights.map((weight) {
                      return DropdownMenuItem(
                        child: Text(weight),
                        value: weight,
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    hint: Text('Select Color'),
                    value: selectedColor,
                    onChanged: (newValue) {
                      setState(() {
                        selectedColor = newValue;
                      });
                    },
                    items: colors.map((color) {
                      return DropdownMenuItem(
                        child: Text(color),
                        value: color,
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    hint: Text('Select Thread Number'),
                    value: selectedThreadNumber,
                    onChanged: (newValue) {
                      setState(() {
                        selectedThreadNumber = newValue;
                      });
                    },
                    items: threadNumbers.map((thread) {
                      return DropdownMenuItem(
                        child: Text(thread),
                        value: thread,
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    child: Text('Add Item'),
                    onPressed: addItem,
                  ),
                ],
              ),
            ),
    );
  }
}
