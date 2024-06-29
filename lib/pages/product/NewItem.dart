import 'dart:io';
import 'dart:typed_data';

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
import 'package:file_picker/file_picker.dart';

import '../../generated/l10n.dart';

class AddNewItemScreen extends StatefulWidget {
  @override
  _AddNewItemScreenState createState() => _AddNewItemScreenState();
}

class _AddNewItemScreenState extends State<AddNewItemScreen> {
  String? selectedType;
  String? selectedWidth;
  String? selectedWeight;
  String? selectedColor;
  String? selectedYarnNumber;
  String? selectedShift;
  XFile? selectedImage;
  Uint8List? _webImage;

  List<String> types = [];
  List<String> widths = [];
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
    widths = await fetchData('widths', 'values');
    weights = await fetchData('weights', 'values');
    colors = await fetchData('colors', 'values');
    yarnNumbers = await fetchData('yarn_numbers', 'values');
    shift = await fetchData('shift', 'values');
    setState(() {
      //  selectedType = types.isNotEmpty ? types[0] : null;
      selectedType = types.isNotEmpty ? null : null;
      selectedWidth = widths.isNotEmpty ? widths[3] : null;
      selectedWeight = weights.isNotEmpty ? weights[0] : null;
      selectedColor = colors.isNotEmpty ? colors[0] : null;
      selectedYarnNumber = yarnNumbers.isNotEmpty ? yarnNumbers[1] : null;
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

    // Check if selectedType is null
    if (selectedType == null) {
      // Show error message and return if selectedType is null
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(S().error),
            content: Text(S().please_select_a_type),
            actions: <Widget>[
              TextButton(
                child: Text(S().ok),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    // Show dialog to confirm added item details
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S().confirm + S().item + S().details),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('ID: $product_id'),
              Text('Type: $selectedType'),
              Text('Width: $selectedWidth'),
              Text('Weight: $selectedWeight'),
              Text('Color: $selectedColor'),
              Text('Yarn Number: $selectedYarnNumber'),
              Text('Shift: $selectedShift'),
              if (selectedImage != null || _webImage != null)
                kIsWeb
                    ? Image.memory(_webImage!, width: 100, height: 100)
                    : Image.file(File(selectedImage!.path),
                        width: 100, height: 100),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(S().confirm),
              onPressed: () async {
                // Upload image to storage if selected
                if (selectedImage != null || _webImage != null) {
                  try {
                    imageUrl = await uploadImageToStorage(selectedImage);
                    // Show snackbar if image upload succeeds
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(S().image_uploaded_successfully)),
                    );
                  } catch (e) {
                    // Display error message to the user if image upload fails
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('${S().failed_to_upload_image} : $e')),
                    );
                    return;
                  }
                }

                String yearMonth =
                    '${DateTime.now().year}-${DateTime.now().month}';
                String documentPath =
                    'productsForAllMonths/$yearMonth/$product_id';

                // Save data to Firestore
                await FirebaseFirestore.instance
                    .collection('products')
                    .doc(documentPath)
                    .set({
                  'type': selectedType,
                  'width': selectedWidth,
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
                      content: Text(
                          '${S().item + S().saved_successfully_with} ID: $product_id')),
                );

                // Reset fields and generate new product ID
                setState(() {
                  //  selectedType = types.isNotEmpty ? types[0] : null;
                  selectedType = types.isNotEmpty ? null : null;
                  selectedWidth = widths.isNotEmpty ? widths[3] : null;
                  selectedWeight = weights.isNotEmpty ? weights[0] : null;
                  selectedColor = colors.isNotEmpty ? colors[0] : null;
                  selectedYarnNumber =
                      yarnNumbers.isNotEmpty ? yarnNumbers[1] : null;
                  selectedShift = shift.isNotEmpty ? shift[0] : null;
                  selectedImage = null;
                  _webImage = null;
                  product_id = generateCode();
                });

                Navigator.of(context).pop(); // Close dialog
              },
            ),
            TextButton(
              child: Text(S().cancel),
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<String> uploadImageToStorage(XFile? image) async {
    String yearMonth = '${DateTime.now().year}-${DateTime.now().month}';
    String day = '${DateTime.now().month}-${DateTime.now().day}';
    Reference storageReference = FirebaseStorage.instance.ref().child(
        'products/$yearMonth/$day/${image != null ? path.basename(image.path) : '$product_id.jpg'}');

    UploadTask uploadTask;
    if (image != null) {
      uploadTask = storageReference.putFile(File(image.path));
    } else {
      uploadTask = storageReference.putData(_webImage!);
    }

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
              pw.Text('Width: $selectedWidth'),
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
    if (kIsWeb) {
      // Pick image from web
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          _webImage = result.files.first.bytes;
        });
      }
    } else {
      // Pick image from mobile (directly from camera)
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      setState(() {
        selectedImage = image;
      });
    }
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
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('Product ID: $product_id'),
                      SizedBox(height: 10),
                      if (selectedImage != null || _webImage != null)
                        kIsWeb
                            ? Image.memory(_webImage!, width: 200, height: 200)
                            : Image.file(File(selectedImage!.path),
                                width: 200, height: 200),
                      SizedBox(height: 10),
                      ElevatedButton(
                        child: Text(S().pick_image),
                        onPressed: pickImage,
                      ),
                      SizedBox(height: 10),
                      buildDropdown(
                          '${S().select} ${S().type}', selectedType, types,
                          (value) {
                        setState(() {
                          selectedType = value;
                        });
                      }, '${S().select} ${S().type}'),
                      buildDropdown(
                          '${S().select} ${S().width}', selectedWidth, widths,
                          (value) {
                        setState(() {
                          selectedWidth = value;
                        });
                      }, '${S().select} ${S().width}'),
                      buildDropdown('${S().select} ${S().weight}',
                          selectedWeight, weights, (value) {
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
                        onPressed: addItem,
                        child: Text('${S().add} ${S().item}'),
                      ),
                    ],
                  ),
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
