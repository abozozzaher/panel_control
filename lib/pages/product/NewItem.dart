import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../generated/l10n.dart';

class AddNewItemScreen extends StatefulWidget {
  @override
  _AddNewItemScreenState createState() => _AddNewItemScreenState();
}

class _AddNewItemScreenState extends State<AddNewItemScreen> {
  String? selectedType;
  String? selectedOffer;
  String? selectedWeight;
  String? selectedColor;
  String? selectedYarnNumber;
  String? selectedShift;
  XFile? selectedImage;

  List<String> types = [];
  List<String> offers = [];
  List<String> weights = [];
  List<String> colors = [];
  List<String> yarnNumbers = [];
  List<String> shift = [];
  late String image;

  bool isLoading = true;
  String firstName = '';
  String lastName = '';
  String userId = '';
  String product_id = '';

  @override
  void initState() {
    super.initState();
    loadDefaults(); // Load default values and data from Firestore
  }

  Future<void> loadDefaults() async {
    // Load default values
    await loadDefaultValues();

    // Load data from Firestore
    try {
      await loadData();
    } catch (e) {
      print('Error loading data: $e');
      // Display error message to the user
    }
  }

  Future<void> loadDefaultValues() async {
    // Set default values from Firestore or local defaults if Firestore is empty
    types = await fetchData('product_types', 'types');
    offers = await fetchData('offers', 'values');
    weights = await fetchData('weights', 'values');
    colors = await fetchData('colors', 'values');
    yarnNumbers = await fetchData('yarn_numbers', 'values');
    shift = await fetchData('shift', 'values');
    setState(() {
      selectedType = types.isNotEmpty ? types[0] : null;
      selectedOffer = offers.isNotEmpty ? offers[0] : null;
      selectedWeight = weights.isNotEmpty ? weights[0] : null;
      selectedColor = colors.isNotEmpty ? colors[0] : null;
      selectedYarnNumber = yarnNumbers.isNotEmpty ? yarnNumbers[0] : null;
      selectedShift = shift.isNotEmpty ? shift[0] : null;
      product_id = generateCode();
    });
  }

  Future<List<String>> fetchData(String docName, String fieldName) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('products_info')
        .doc(docName)
        .get();
    if (doc.exists) {
      Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey(fieldName)) {
        return List<String>.from(data[fieldName]);
      }
    }
    return [];
  }

  Future<void> loadData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        if (data != null) {
          firstName = data['firstName'] ?? '';
          lastName = data['lastName'] ?? '';
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> addItem() async {
    String? imageUrl;

    // Upload image to storage if selected
    if (selectedImage != null) {
      try {
        imageUrl = await uploadImageToStorage(selectedImage!);
        // Show snackbar if image upload succeeds
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Image uploaded successfully')),
        );
      } catch (e) {
        // Display error message to the user if image upload fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
        return;
      }
    }

    // Show dialog to confirm added item details
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Item Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('ID: $product_id'),
              Text('Type: $selectedType'),
              Text('Offer: $selectedOffer'),
              Text('Weight: $selectedWeight'),
              Text('Color: $selectedColor'),
              Text('Yarn Number: $selectedYarnNumber'),
              Text('Shift: $selectedShift'),
              if (imageUrl != null) Text('Image URL: $imageUrl'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                String yearMonth =
                    '${DateTime.now().year}-${DateTime.now().month}';
                String documentPath =
                    'productsForAllMonthe/$yearMonth/$product_id';
                // Save data to Firestore
                await FirebaseFirestore.instance
                    .collection('products')
                    .doc(documentPath)
                    // .doc(product_id)
                    .set({
                  'type': selectedType,
                  'offer': selectedOffer,
                  'weight': selectedWeight,
                  'color': selectedColor,
                  'yarn_number': selectedYarnNumber,
                  'product_id': product_id,
                  'date': DateTime.now(),
                  'user': '$firstName $lastName',
                  'user_id': userId,
                  'shift': selectedShift,
                  'created_by': userId,
                  if (imageUrl != null) 'image_url': imageUrl,
                });

                // Generate and print PDF
                await generateAndPrintPDF(product_id);

                // Show a snackbar with the new product ID
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Item saved successfully with ID: $product_id')),
                );

                // Reset fields and generate new product ID
                setState(() {
                  selectedType = types.isNotEmpty ? types[0] : null;
                  selectedOffer = offers.isNotEmpty ? offers[0] : null;
                  selectedWeight = weights.isNotEmpty ? weights[0] : null;
                  selectedColor = colors.isNotEmpty ? colors[0] : null;
                  selectedYarnNumber =
                      yarnNumbers.isNotEmpty ? yarnNumbers[0] : null;
                  selectedShift = shift.isNotEmpty ? shift[0] : null;
                  selectedImage = null;
                  product_id = generateCode();
                });

                Navigator.of(context).pop(); // Close dialog
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> uploadImageToStorage(XFile image) async {
    String yearMonth = '${DateTime.now().year}-${DateTime.now().month}';
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('products/$yearMonth/${path.basename(image.path)}');

    UploadTask uploadTask = storageReference.putFile(File(image.path));
    await uploadTask;
    return await storageReference.getDownloadURL();
  }

  String generateCode() {
    String date = DateTime.now().toString().replaceAll(RegExp(r'[^0-9]'), '');
    return 'BLLTTLT${date}0001'; // Dynamic serial number should be updated
  }

  Future<void> generateAndPrintPDF(String product_id) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Product Information'),
              pw.Text('Product ID: $product_id'),
              pw.SizedBox(height: 10),
              pw.Text('Type: $selectedType'),
              pw.Text('Offer: $selectedOffer'),
              pw.Text('Weight: $selectedWeight'),
              pw.Text('Color: $selectedColor'),
              pw.Text('Yarn Number: $selectedYarnNumber'),
              pw.Text('Created by: $firstName $lastName'),
              pw.Text('User ID: $userId'),
              pw.Text('Shift: $selectedShift'),
            ],
          );
        },
      ),
    );

    // Layout PDF based on platform type
    if (!kIsWeb && Platform.isMacOS) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } else {
      // Handle non-macOS platforms or web
      // You can show an error message or fallback mechanism here
      print('PDF printing is not supported on this platform.');
      // Optionally, you can provide a different behavior or inform the user
    }
  }

  Future<void> pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${S().add} ${S().new1} ${S().item}'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Product ID: $product_id'),
                    SizedBox(height: 10),
                    buildDropdown(
                        '${S().select} ${S().type}', selectedType, types,
                        (value) {
                      setState(() {
                        selectedType = value;
                      });
                    }, '${S().select} ${S().type}'),
                    buildDropdown(
                        '${S().select} ${S().offer}', selectedOffer, offers,
                        (value) {
                      setState(() {
                        selectedOffer = value;
                      });
                    }, '${S().select} ${S().offer}'),
                    buildDropdown(
                        '${S().select} ${S().weight}', selectedWeight, weights,
                        (value) {
                      setState(() {
                        selectedWeight = value;
                      });
                    }, '${S().select} ${S().weight}'),
                    buildDropdown(
                        '${S().select} ${S().color}', selectedColor, colors,
                        (value) {
                      setState(() {
                        selectedColor = value;
                      });
                    }, '${S().select} ${S().color}'),
                    buildDropdown('${S().select} ${S().yarn_number}',
                        selectedYarnNumber, yarnNumbers, (value) {
                      setState(() {
                        selectedYarnNumber = value;
                      });
                    }, '${S().select} ${S().yarn_number}'),
                    buildDropdown(
                        '${S().select} ${S().shift}', selectedShift, shift,
                        (value) {
                      setState(() {
                        selectedShift = value;
                      });
                    }, '${S().select} ${S().shift}'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      child: Text(S().pick_image),
                      onPressed: pickImage,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: addItem,
                      child: Text('${S().add} ${S().item}'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget buildDropdown(String hint, String? selectedValue, List<String> items,
      ValueChanged<String?> onChanged, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(hintText, style: TextStyle(color: Colors.grey)),
        DropdownButton<String>(
          hint: Text(hint),
          value: selectedValue,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem(
              child: Text(item),
              value: item,
            );
          }).toList(),
        ),
      ],
    );
  }
}
