import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../generated/l10n.dart';
import '../../provider/user_provider.dart';
import '../../service/app_drawer.dart';

class AddNewItemScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const AddNewItemScreen(
      {super.key, required this.toggleTheme, required this.toggleLocale});
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
  String? selectedQuantity;
  String? selectedLength;

  XFile? selectedImage;
  Uint8List? _webImage;

  List<String> types = [];
  List<String> widths = [];
  List<String> weights = [];
  List<String> colors = [];
  List<String> yarnNumbers = [];
  List<String> shift = [];
  List<String> quantity = [];
  List<String> length = [];
  late String image;

//  bool isLoading = false;
  String firstName = '';
  String lastName = '';
  // String userId = '';
  String productId = '';

  @override
  void initState() {
    super.initState();
    loadDefaults(); // Load default values and data from Firestore
  }

  Future<void> loadDefaults() async {
    // Load default values
    await loadDefaultValues();
/*
    // Load data from Firestore
    try {
      //   await loadData();
    } catch (e) {
      print('Error loading data: $e');
      // Display error message to the user
    }
    */
  }

  Future<void> loadDefaultValues() async {
    // Set default values from Firestore or local defaults if Firestore is empty
    types = await fetchData('product_types', 'types');
    widths = await fetchData('widths', 'values');
    weights = await fetchData('weights', 'values');
    colors = await fetchData('colors', 'values');
    yarnNumbers = await fetchData('yarn_numbers', 'values');
    shift = await fetchData('shift', 'values');
    quantity = await fetchData('quantity', 'values');
    length = await fetchData('length', 'values');

    setState(() {
      selectedType = types.isNotEmpty ? types[0] : null; // null : null;
      selectedWidth = widths.isNotEmpty ? widths[6] : null;
      selectedWeight = weights.isNotEmpty ? weights[0] : null;
      selectedColor = colors.isNotEmpty ? colors[0] : null;
      selectedYarnNumber = yarnNumbers.isNotEmpty ? yarnNumbers[1] : null;
      selectedShift = shift.isNotEmpty ? shift[0] : null;
      selectedQuantity = quantity.isNotEmpty ? quantity[0] : null;
      selectedLength = length.isNotEmpty ? length[2] : null;
      productId = generateCode();
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

/*
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
*/
  Future<void> addItem() async {
    // final userProvider = Provider.of<UserProvider>(context);
    //  final userData = userProvider.user;
    String? imageUrl;
    bool isUploading = false;
    String englishProductId = productId.replaceAllMapped(RegExp(r'[٠-٩]'),
        (match) => (match.group(0)!.codeUnitAt(0) - 1632).toString());

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
          title: Text(
            '${S().confirm} ${S().details} ${S().item}',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(S().product_id),
              Text(
                englishProductId,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('${S().type} : $selectedType'),
              Text('${S().width} : $selectedWidth' 'mm'),
              Text('${S().weight} : $selectedWeight' 'g'),
              Text('${S().color} : $selectedColor'),
              Text('${S().yarn_number} : $selectedYarnNumber' 'D'),
              Text('${S().shift} : $selectedShift'),
              Text('${S().quantity} : $selectedQuantity' 'Pcs'),
              Text('${S().length} : $selectedLength' 'Mt'),
              if (selectedImage != null || _webImage != null)
                kIsWeb
                    ? Image.memory(_webImage!, width: 100, height: 100)
                    : Image.file(File(selectedImage!.path),
                        width: 100, height: 100),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.greenAccent),
                    onPressed: () async {
                      if (isUploading) {
                        return; // Exit the function if the upload is already in progress
                      }

                      setState(() {
                        isUploading = true; // Set the uploading flag to true
                      });

                      // Upload image to storage if selected
                      if (selectedImage != null || _webImage != null) {
                        try {
                          imageUrl = await uploadImageToStorage(selectedImage);

                          // تأخير لمدة 2 ثانية قبل إظهار Snackbar
                          //     await Future.delayed(Duration(seconds: 2));

                          // Show snackbar if image upload succeeds
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Center(
                                    child:
                                        Text(S().image_uploaded_successfully))),
                          );
                        } catch (e) {
                          // Display error message to the user if image upload fails
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Center(
                                    child: Text(
                                        '${S().failed_to_upload_image} : $e'))),
                          );
                          setState(() {
                            isUploading =
                                false; // Reset the uploading flag if the upload fails
                          });
                          return;
                        }
                      }

                      // String yearMonth ='${DateTime.now().year}-${DateTime.now().month}';
                      String yearMonth =
                          DateFormat('yyyy-MM').format(DateTime.now());
                      String englishYearMonth = yearMonth.replaceAllMapped(
                          RegExp(r'[٠-٩]'),
                          (match) => String.fromCharCode(
                              match.group(0)!.codeUnitAt(0) - 1632 + 48));
                      String documentPath =
                          'productsForAllMonths/$englishYearMonth/$englishProductId';

                      ///      int weight = int.tryParse(selectedWeight ?? '0') ?? 0;
                      //   int quantity = int.tryParse(selectedQuantity ?? '0') ?? 0;

                      // Save data to Firestore
                      await FirebaseFirestore.instance
                          .collection('products')
                          .doc(documentPath)
                          .set({
                        'type': selectedType,
                        'width': selectedWidth,
                        'weight': selectedWeight,
                        'total_weight':
                            (double.parse(selectedWeight.toString()) *
                                    double.parse(selectedQuantity.toString())) /
                                1000,
                        'color': selectedColor,
                        'yarn_number': selectedYarnNumber,
                        'productId': englishProductId,
                        'date': DateTime.now(),
                        'shift': selectedShift,
                        'quantity': selectedQuantity,
                        'length': selectedLength,
                        //      'created_by': userData!.id,
                        'saleـstatus': false,
                        if (imageUrl != null) 'image_url': imageUrl,
                        //444
                        if (imageUrl == null) 'image_url': '',
                      });

                      // Generate and print PDF
                      await generateAndPrintPDF(
                          englishProductId, imageUrl, englishYearMonth);

                      // تأخير لمدة 2 ثانية قبل إظهار Snackbar
                      //    await Future.delayed(Duration(seconds: 2));

                      // Show a snackbar with the new product ID
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Center(
                        child: Text(
                            '${S().saved_successfully_with} $englishProductId'),
                      )));

                      // Reset fields and generate new product ID
                      setState(() {
                        selectedType =
                            types.isNotEmpty ? types[0] : null; //  null : null;
                        selectedWidth = widths.isNotEmpty ? widths[6] : null;
                        selectedWeight = weights.isNotEmpty ? weights[0] : null;
                        selectedColor = colors.isNotEmpty ? colors[0] : null;
                        selectedYarnNumber =
                            yarnNumbers.isNotEmpty ? yarnNumbers[1] : null;
                        selectedShift = shift.isNotEmpty ? shift[0] : null;
                        selectedQuantity =
                            quantity.isNotEmpty ? quantity[0] : null;
                        selectedLength = length.isNotEmpty ? length[2] : null;

                        selectedImage = null;
                        _webImage = null;
                        productId = generateCode();
                        isUploading =
                            false; // Reset the uploading flag after the upload is complete
                      });

                      Navigator.of(context).pop(); // Close dialog
                    },
                    child: Text(
                      S().confirm,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 5, width: 5),
                Expanded(
                  child: TextButton(
                    style:
                        TextButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                    child: Text(
                      S().cancel,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<String> uploadImageToStorage(XFile? image) async {
    String yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
    String englishYearMonth = yearMonth.replaceAllMapped(
        RegExp(r'[٠-٩]'),
        (match) =>
            String.fromCharCode(match.group(0)!.codeUnitAt(0) - 1632 + 48));
    String englishProductId = productId.replaceAllMapped(RegExp(r'[٠-٩]'),
        (match) => (match.group(0)!.codeUnitAt(0) - 1632).toString());

    String day = '${DateTime.now().day}';

    Reference storageReference = FirebaseStorage.instance.ref().child(
        'products/$englishYearMonth/$day/${image != null ? path.basename(image.path) : '$englishProductId.jpg'}');
    SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

    UploadTask uploadTask;
    if (image != null) {
      uploadTask = storageReference.putFile(File(image.path), metadata);
    } else {
      uploadTask = storageReference.putData(_webImage!, metadata);
    }

    await uploadTask;
    return await storageReference.getDownloadURL();
  }

  String generateCode() {
    DateTime now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssssssss');
    String date = formatter.format(now);
    return date; // Dynamic serial number should be updated
  }

  Future<void> generateAndPrintPDF(
      //   String productId,
      String englishProductId,
      String? imageUrl,
      String? englishYearMonth) async {
    //  String englishProductId = productId.replaceAllMapped(RegExp(r'[٠-٩]'), (match) => (match.group(0)!.codeUnitAt(0) - 1632).toString());
    final pdf = pw.Document();
    String productUrl =
        "https://panel-control-company-zaher.web.app/$englishYearMonth/$englishProductId"; // Replace with your product URL

    final ttfTr = await rootBundle.load("assets/fonts/Beiruti.ttf");
    final fontBe = pw.Font.ttf(ttfTr);
    final fontRo = await PdfGoogleFonts.tajawalBold();

    DateTime now = DateTime.now();

    //   String dataTime = DateFormat('  yyyy - MM - dd  ').format(now);
    String englishDataTime = now.year.toString() +
        ' - ' +
        now.month.toString().padLeft(2, '0') +
        ' - ' +
        now.day.toString().padLeft(2, '0');
    final profileImage = pw.MemoryImage(
      (await rootBundle.load('assets/img/logo.png')).buffer.asUint8List(),
    );
    // Generate QR code image
    final qrCodeImage = await generateQRCodeImage(productUrl);
    double heighPdf = 80;
    double widthPdf = heighPdf * 3;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a6.copyWith(
          marginBottom: 5.0,
          marginLeft: 5.0,
          marginTop: 5.0,
          marginRight: 5.0,
        ),
        build: (pw.Context context) {
          return pw.Column(
            //    crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      alignment: pw.Alignment.topLeft,
                      margin: const pw.EdgeInsets.all(
                          5.0), // 5mm margin around image
                      child: pw.Image(profileImage),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      height: 50,
                      alignment: pw.Alignment.center,
                      child: pw.Column(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Blue textiles',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.SizedBox(height: 4), // إضافة مساحة بين النصين
                          pw.Text(
                            'المنسوجات الزرقاء',
                            textDirection: pw.TextDirection.rtl,
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.normal,
                              font: fontBe,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Container(
                      alignment: pw.Alignment.topRight,
                      margin: const pw.EdgeInsets.all(
                          5.0), // 5mm margin around image
                      child: pw.Image(pw.MemoryImage(qrCodeImage)),
                    ),
                  ),
                ],
              ),
              pw.Divider(thickness: 0.1),
              pw.Padding(
                padding: const pw.EdgeInsets.all(5.0), // 5mm margin around text
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  mainAxisSize: pw.MainAxisSize.max,
                  children: [
                    pw.SizedBox(height: 5),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'Ürün Bilgisi',
                          style: pw.TextStyle(
                              font: fontBe,
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          textDirection: pw.TextDirection.rtl,
                          'معلومات المنتج :',
                          style: pw.TextStyle(
                              font: fontBe,
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('ID Kodu : ',
                            style: pw.TextStyle(font: fontBe)),
                        pw.Text(
                          englishProductId,
                          textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(
                              font: fontRo, fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text(
                          textDirection: pw.TextDirection.rtl,
                          'كود المنتج :',
                          style: pw.TextStyle(font: fontBe),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Tip : ', style: pw.TextStyle(font: fontBe)),
                        pw.Text(
                          '$selectedType',
                          textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(font: fontRo),
                        ),
                        pw.Text(
                          textDirection: pw.TextDirection.rtl,
                          'النوع :',
                          style: pw.TextStyle(font: fontBe),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Genişlik : ',
                            style: pw.TextStyle(font: fontBe)),
                        pw.Text(
                          '$selectedWidth' 'mm',
                          textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(font: fontRo),
                        ),
                        pw.Text(
                          textDirection: pw.TextDirection.rtl,
                          'العرض :',
                          style: pw.TextStyle(font: fontBe),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Ağırlık : ',
                            style: pw.TextStyle(font: fontBe)),
                        pw.Text(
                          '$selectedWeight'
                          'g'
                          '/'
                          '${(double.parse(selectedWeight.toString()) * double.parse(selectedQuantity.toString())) / 1000}'
                          'Kg',
                          //  textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(font: fontRo),
                        ),
                        pw.Text(
                          textDirection: pw.TextDirection.rtl,
                          'الوزن :',
                          style: pw.TextStyle(font: fontBe),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Renk : ', style: pw.TextStyle(font: fontBe)),
                        pw.Text(
                          '$selectedColor',
                          textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(font: fontRo),
                        ),
                        pw.Text(
                          textDirection: pw.TextDirection.rtl,
                          'اللون :',
                          style: pw.TextStyle(font: fontBe),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('İplik Density : ',
                            style: pw.TextStyle(font: fontBe)),
                        pw.Text(
                          '$selectedYarnNumber'
                          'D',
                          //   textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(font: fontRo),
                        ),
                        pw.Text(
                          textDirection: pw.TextDirection.rtl,
                          'نمرة الخيط :',
                          style: pw.TextStyle(font: fontBe),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Uzunluk : ',
                            style: pw.TextStyle(font: fontBe)),
                        pw.Text(
                          '$selectedLength'
                          'MT',
                          //  textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(font: fontRo),
                        ),
                        pw.Text(
                          textDirection: pw.TextDirection.rtl,
                          'الطول :',
                          style: pw.TextStyle(font: fontBe),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Adet : ', style: pw.TextStyle(font: fontBe)),
                        pw.Text(
                          '$selectedQuantity'
                          'Pcs',
                          //    textDirection: pw.TextDirection.rtl,
                          style: pw.TextStyle(font: fontRo),
                        ),
                        pw.Text(
                          textDirection: pw.TextDirection.rtl,
                          'العدد :',
                          style: pw.TextStyle(font: fontBe),
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text('Tarih : ', style: pw.TextStyle(font: fontBe)),
                        pw.Text(englishDataTime,
                            textDirection: pw.TextDirection.rtl,
                            style: pw.TextStyle(font: fontRo)),
                        pw.Text(
                          textDirection: pw.TextDirection.rtl,
                          'التاريخ :',
                          style: pw.TextStyle(font: fontBe),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 3),
                    pw.Center(
                      child: pw.Container(
                        margin: const pw.EdgeInsets.all(2),
                        child: pw.BarcodeWidget(
                          barcode: pw.Barcode.pdf417(),
                          data: productUrl,
                          width: widthPdf,
                          height: heighPdf,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Divider(thickness: 0.2),
              pw.Center(
                child: pw.Text(
                  S().company_name,
                  style: pw.TextStyle(
                      font: fontBe,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  S().addres,
                  style: pw.TextStyle(
                    fontSize: 6,
                    font: fontBe,
                    fontWeight: pw.FontWeight.normal,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<Uint8List> generateQRCodeImage(String data, {int size = 400}) async {
    final qrValidationResult = QrValidator.validate(
      data: data,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    if (qrValidationResult.status == QrValidationStatus.valid) {
      final qrCode = qrValidationResult.qrCode;
      final painter = QrPainter.withQr(
        qr: qrCode!,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
      );

      // Create an image with the specified size (default is 400)
      final ui.Image image = await painter.toImage(size.toDouble());
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } else {
      throw Exception('Could not generate QR code');
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          _webImage = result.files.first.bytes;
        });
      }
    } else {
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      setState(() {
        selectedImage = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    //  final userData = userProvider.id;
    //  print(userData);
    bool isMobile = MediaQuery.of(context).size.width < 600;
    String englishProductId = productId.replaceAllMapped(RegExp(r'[٠-٩]'),
        (match) => (match.group(0)!.codeUnitAt(0) - 1632).toString());

    return Scaffold(
      appBar: AppBar(
        title: Text('${S().add} ${S().item} ${S().new1}'),
        centerTitle: true,
        leading: isMobile
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.go('/');
                },
              )
            : null,
      ),
      drawer: AppDrawer(
        toggleTheme: widget.toggleTheme,
        toggleLocale: widget.toggleLocale,
      ),
      body: //isLoading  ? const Center(child: CircularProgressIndicator())   :

          SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('${S().product_id}  :  $englishProductId',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textDirection: ui.TextDirection.rtl),
                const SizedBox(height: 10),
                if (selectedImage != null || _webImage != null)
                  kIsWeb
                      ? Image.memory(_webImage!, width: 200, height: 200)
                      : Image.file(File(selectedImage!.path),
                          width: 200, height: 200),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt_outlined),
                  onPressed: pickImage,
                  label: Text(S().pick_image),
                ),
                const SizedBox(height: 10),
                buildDropdown('${S().select} ${S().type}', selectedType, types,
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
                  },
                  '${S().select} ${S().width}',
                  suffixText: 'mm', // يمكنك إضافة النص الذي تريده هنا
                ),
                buildDropdown(
                  '${S().select} ${S().weight}',
                  selectedWeight,
                  weights,
                  (value) {
                    setState(() {
                      selectedWeight = value;
                    });
                  },
                  '${S().select} ${S().weight}',
                  suffixText: 'g', // يمكنك إضافة النص الذي تريده هنا
                ),
                buildDropdown(
                    '${S().select} ${S().color}', selectedColor, colors,
                    (value) {
                  setState(() {
                    selectedColor = value;
                  });
                }, '${S().select} ${S().color}'),
                buildDropdown(
                  '${S().select} ${S().yarn_number}',
                  selectedYarnNumber,
                  yarnNumbers,
                  (value) {
                    setState(() {
                      selectedYarnNumber = value;
                    });
                  },
                  '${S().select} ${S().yarn_number}',
                  suffixText: 'D', // يمكنك إضافة النص الذي تريده هنا
                ),
                buildDropdown(
                    '${S().select} ${S().shift}', selectedShift, shift,
                    (value) {
                  setState(() {
                    selectedShift = value;
                  });
                }, '${S().select} ${S().shift}'),
                buildDropdown(
                  '${S().select} ${S().length}', selectedLength, length,
                  (value) {
                    setState(() {
                      selectedLength = value;
                    });
                  },
                  '${S().select} ${S().length}',
                  suffixText: 'Mt', // يمكنك إضافة النص الذي تريده هنا
                ),
                buildDropdown(
                  '${S().select} ${S().quantity}',
                  selectedQuantity,
                  quantity,
                  (value) {
                    setState(() {
                      selectedQuantity = value;
                    });
                  },
                  '${S().select} ${S().quantity}',
                  suffixText: 'Pcs', // يمكنك إضافة النص الذي تريده هنا
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_as_outlined),
                  onPressed: () async {
                    await addItem();
                  },
                  label: Text('${S().add} ${S().item}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDropdown(String hint, String? selectedValue, List<String> items,
      ValueChanged<String?> onChanged, String hintText,
      {String suffixText = ''}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(hintText, style: const TextStyle(color: Colors.grey)),
        DropdownButton<String>(
          hint: Text(hint),
          value: selectedValue,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Center(
                child: Text('$item $suffixText',
                    textDirection: ui.TextDirection.ltr),
              ), // إضافة النص الإضافي هنا
            );
          }).toList(),
        ),
      ],
    );
  }
}
