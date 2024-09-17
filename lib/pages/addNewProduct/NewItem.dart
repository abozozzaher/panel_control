import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:panel_control/service/toasts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../generated/l10n.dart';
import '../../provider/user_provider.dart';
import '../../service/app_drawer.dart';
import '../../data/data_lists.dart';
import '../../service/dropdownWidget.dart';

class AddNewItemScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const AddNewItemScreen(
      {super.key, required this.toggleTheme, required this.toggleLocale});
  @override
  _AddNewItemScreenState createState() => _AddNewItemScreenState();
}

class _AddNewItemScreenState extends State<AddNewItemScreen> {
  String? selectedKey;
  final DataLists dataLists = DataLists();

//  final AddNewItemService addNewItemService = AddNewItemService();
  String? selectedType;
  String? selectedColor;
  String? selectedWidth;
  String? selectedWeight;
  String? selectedYarnNumber;
  String? selectedShift;
  String? selectedQuantity;
  String? selectedLength;

  XFile? selectedImage;
  Uint8List? webImage;

  List<List<String>>? types;
  List<List<String>>? colors;
  List<List<String>>? widths;
  List<List<String>>? weights;
  List<List<String>>? yarnNumbers;
  List<List<String>>? shift;
  List<List<String>>? quantity;
  List<List<String>>? length;
  late String image;
  String productId = '';
  String yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
  @override
  void initState() {
    super.initState();
    loadDefaults();
  }

  Future<void> loadDefaults() async {
    await loadDefaultValues();
  }

  Future<void> loadDefaultValues() async {
    // Set default values from Firestore or local defaults if Firestore is empty
    // Load default values from data_lists.dart
    types = dataLists.types;
    colors = dataLists.colors;
    widths = dataLists.widths;
    weights = dataLists.weights;
    yarnNumbers = dataLists.yarnNumbers;
    shift = dataLists.shift;
    quantity = dataLists.quantity;
    length = dataLists.length;
    setState(() {
      selectedType = types!.isNotEmpty ? types![0][0] : null;
      selectedColor = colors!.isNotEmpty ? null : null;
      selectedWidth = widths!.isNotEmpty ? widths![6][0] : null;
      selectedWeight = weights!.isNotEmpty ? weights![0][0] : null;
      selectedYarnNumber = yarnNumbers!.isNotEmpty ? yarnNumbers![1][0] : null;
      selectedShift = shift!.isNotEmpty ? shift![0][0] : null;
      selectedLength = length!.isNotEmpty ? length![2][0] : null;
      selectedQuantity = quantity!.isNotEmpty ? quantity![2][0] : null;

      productId = generateCode();
    });
  }

  /// تحويل الأرقام العربية إلى أرقام إنجليزية
  String convertArabicToEnglish(String text) {
    return text.replaceAllMapped(
      RegExp(r'[٠-٩]'),
      (match) => (match.group(0)!.codeUnitAt(0) - 1632).toString(),
    );
  }

  ///  تحويل الأرقام العربية إلى أرقام إنجليزية للشهر
  String convertArabicToEnglishForMonth(String text) {
    return text.replaceAllMapped(
        RegExp(r'[٠-٩]'),
        (match) =>
            String.fromCharCode(match.group(0)!.codeUnitAt(0) - 1632 + 48));
  }

  Future<void> addItem() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = userProvider.user;
    String? imageUrl;
    bool isUploading = false;
    // Check if selectedType is null
    String englishProductId = convertArabicToEnglish(productId);
    if (selectedType == null ||
        selectedColor == null ||
        selectedWidth == null ||
        selectedWeight == null ||
        selectedYarnNumber == null ||
        selectedShift == null ||
        selectedQuantity == null ||
        selectedLength == null) {
      // Show error message and return if selectedType is null
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(S().error),
            content: Text(selectedColor == null
                ? S().please_select_a_color
                : S().please_fill_all_fields),
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
              Text(
                  '${S().type} : ${types!.firstWhere((element) => element[0] == selectedType)[1]}'),
              Text(
                  '${S().color} : ${colors!.firstWhere((element) => element[0] == selectedColor)[1]}'),
              Text(
                  '${S().width} : ${widths!.firstWhere((element) => element[0] == selectedWidth)[1]}'
                  'mm'),
              Text(
                  '${S().weight} : ${weights!.firstWhere((element) => element[0] == selectedWeight)[1]}'
                  'g'),
              Text(
                  '${S().yarn_number} : ${yarnNumbers!.firstWhere((element) => element[0] == selectedYarnNumber)[1]}'
                  'D'),
              Text(
                  '${S().shift} : ${shift!.firstWhere((element) => element[0] == selectedShift)[1]}'),
              Text(
                  '${S().quantity} : ${quantity!.firstWhere((element) => element[0] == selectedQuantity)[1]} ${S().pcs}'),
              Text(
                  '${S().length} : ${length!.firstWhere((element) => element[0] == selectedLength)[1]}'
                  'Mt'),
              if (selectedImage != null || webImage != null)
                kIsWeb
                    ? Image.memory(webImage!, width: 100, height: 100)
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
                      if (selectedImage != null || webImage != null) {
                        try {
                          imageUrl = await uploadImageToStorage(selectedImage);

                          // تأخير لمدة 2 ثانية قبل إظهار Snackbar
                          //     await Future.delayed(Duration(seconds: 2));

                          showToast(S().image_uploaded_successfully);
                        } catch (e) {
                          // Display error message to the user if image upload fails

                          showToast('${S().failed_to_upload_image} : $e');
                          setState(() {
                            isUploading = false;
                          });
                          return;
                        }
                      }

                      String englishYearMonth =
                          convertArabicToEnglishForMonth(yearMonth);

                      String documentPath =
                          'productsForAllMonths/$englishYearMonth/$englishProductId';

                      // Save data to Firestore
                      await FirebaseFirestore.instance
                          .collection('products')
                          .doc(documentPath)
                          .set({
                        'type': selectedType,
                        'color': selectedColor,
                        'width': selectedWidth,
                        'weight': selectedWeight,
                        'total_weight':
                            (double.parse(selectedWeight.toString()) *
                                    double.parse(selectedQuantity.toString())) /
                                1000,
                        'yarn_number': selectedYarnNumber,
                        'productId': englishProductId,
                        'createdAt': DateFormat('yyyy-MM-dd HH:mm:ss', 'en')
                            .format(DateTime.now()),
                        'shift': selectedShift,
                        'quantity': selectedQuantity,
                        'length': selectedLength,
                        'created_by': userData!.id,
                        'sale_status': false,
                        if (imageUrl != null) 'image_url': imageUrl,
                      });
                      // التحقق من حالة الشبكة
                      bool isOnline = await isNetworkAvailable();
                      if (!isOnline) {
                        showToast(S()
                            .data_will_be_recorded_when_internet_connection_is_restored);
                      }
                      // Generate and print PDF
                      await generateAndPrintPDF(
                          englishProductId, imageUrl, englishYearMonth);

                      showToast(
                          '${S().saved_successfully_with} $englishProductId');
                      setState(() {
                        selectedType = types!.isNotEmpty ? types![0][0] : null;
                        selectedColor = colors!.isNotEmpty ? null : null;
                        selectedWidth =
                            widths!.isNotEmpty ? widths![6][0] : null;
                        selectedWeight =
                            weights!.isNotEmpty ? weights![0][0] : null;
                        selectedYarnNumber =
                            yarnNumbers!.isNotEmpty ? yarnNumbers![1][0] : null;
                        selectedShift = shift!.isNotEmpty ? shift![0][0] : null;
                        selectedQuantity =
                            quantity!.isNotEmpty ? quantity![2][0] : null;
                        selectedLength =
                            length!.isNotEmpty ? length![2][0] : null;
                        selectedImage = null;
                        webImage = null;
                        productId = generateCode();
                        isUploading = false;
                      });
                      Navigator.of(context).pop();
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
                    child: Text(
                      S().cancel,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    style:
                        TextButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  String generateCode() {
    DateTime now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmmssssssss');
    String date = formatter.format(now);
    return date; // Dynamic serial number should be updated
  }

  Future<String> uploadImageToStorage(XFile? image) async {
    String englishYearMonth = convertArabicToEnglishForMonth(yearMonth);
    String englishProductId = convertArabicToEnglish(productId);
    String day = '${DateTime.now().day}';

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('products/$englishYearMonth/$day/${englishProductId}.jpg');
    SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

    UploadTask uploadTask;

    if (image != null) {
      // قراءة الصورة كـ Uint8List لتتمكن من ضغطها
      Uint8List imageBytes = await image.readAsBytes();

      // تصغير الصورة
      Uint8List? compressedImageBytes =
          await FlutterImageCompress.compressWithList(
        imageBytes,
        minHeight: 800,
        minWidth: 800,
        quality: 85,
      );

      // رفع الصورة المصغرة
      uploadTask = storageReference.putData(compressedImageBytes, metadata);
    } else {
      uploadTask = storageReference.putData(webImage!, metadata);
    }

    await uploadTask;
    return await storageReference.getDownloadURL();
  }

  Future<void> generateAndPrintPDF(
      String productId, String? imageUrl, String? englishYearMonth) async {
    String englishProductId = convertArabicToEnglish(productId);
    final pdf = pw.Document();
    String productUrl =
        "https://admin.bluedukkan.com/$englishYearMonth/$englishProductId"; // Replace with your product URL

    final ttfTr = await rootBundle.load("assets/fonts/Beiruti.ttf");
    final fontBe = pw.Font.ttf(ttfTr);
    final fontRo = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Tajawal/Tajawal-Bold.ttf'));

    DateTime now = DateTime.now();

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
                      margin: const pw.EdgeInsets.all(5.0),
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
                      margin: const pw.EdgeInsets.all(5.0),
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
                          DataLists().translateType('$selectedType'.toString()),
                          textDirection: pw.TextDirection.rtl,
                          textAlign: pw.TextAlign.center,
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
                        pw.Text('Renk : ', style: pw.TextStyle(font: fontBe)),
                        pw.Text(
                          DataLists()
                              .translateType('$selectedColor'.toString()),
                          textDirection: pw.TextDirection.rtl,
                          textAlign: pw.TextAlign.center,
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
                  'ZAHİR LOJİSTİK TEKSTİL SANAYİ VE TİCARET LİMİTED ŞİRKETİ',
                  style: pw.TextStyle(
                      font: fontBe,
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Türkiye Gaziantep Sanayi MAH. 60092',
                  style: pw.TextStyle(
                    fontSize: 6,
                    font: fontBe,
                    fontWeight: pw.FontWeight.normal,
                  ),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'Made in Türkiye',
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
          webImage = result.files.first.bytes;
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
    bool isMobile = MediaQuery.of(context).size.width < 600;
    String englishProductId = convertArabicToEnglish(productId);

    return Scaffold(
      appBar: AppBar(
          title: Text('${S().add} ${S().item} ${S().new1}'),
          centerTitle: true,
          leading: isMobile
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.go('/');
                  },
                )),
      drawer: AppDrawer(
          toggleTheme: widget.toggleTheme, toggleLocale: widget.toggleLocale),
      body: SingleChildScrollView(
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
                if (selectedImage != null || webImage != null)
                  kIsWeb
                      ? Image.memory(webImage!, width: 200, height: 200)
                      : Image.file(File(selectedImage!.path),
                          width: 200, height: 200),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.camera_alt_outlined),
                  onPressed: pickImage,
                  label: Text(S().pick_image),
                ),
                const SizedBox(height: 10),
                buildDropdown(
                  context,
                  '${S().select} ${S().type}',
                  selectedType,
                  types!,
                  (value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                  '${S().select} ${S().type}',
                  isNumeric: false,
                  allowAddNew: true,
                ),
                buildDropdown(
                  context,
                  '${S().select} ${S().color}',
                  selectedColor,
                  colors!,
                  (value) {
                    setState(() {
                      selectedColor = value;
                    });
                  },
                  '${S().select} ${S().color}',
                  //     isNumeric: false,
                  allowAddNew: true, // enable "Add new item" option
                ),
                buildDropdown(
                  context,
                  '${S().select} ${S().width}',
                  selectedWidth,
                  widths!,
                  (value) {
                    setState(() {
                      selectedWidth = value;
                    });
                  },
                  '${S().select} ${S().width}',
                  suffixText: 'mm',
                  isNumeric: true,
                  allowAddNew: true,
                ),
                buildDropdown(
                  context,
                  '${S().select} ${S().weight}',
                  selectedWeight,
                  weights!,
                  (value) {
                    setState(() {
                      selectedWeight = value;
                    });
                  },
                  '${S().select} ${S().weight}',
                  suffixText: 'g', // يمكنك إضافة النص الذي تريده هنا
                  isNumeric: true,
                  allowAddNew: true, // enable "Add new item" option
                ),
                buildDropdown(
                  context,
                  '${S().select} ${S().yarn_number}',
                  selectedYarnNumber,
                  yarnNumbers!,
                  (value) {
                    setState(() {
                      selectedYarnNumber = value;
                    });
                  },
                  '${S().select} ${S().yarn_number}',
                  suffixText: 'D', // يمكنك إضافة النص الذي تريده هنا

                  //   allowAddNew: false, // enable "Add new item" option
                ),
                buildDropdown(
                  context, '${S().select} ${S().shift}',
                  selectedShift,
                  shift!,
                  (value) {
                    setState(() {
                      selectedShift = value;
                    });
                  },
                  '${S().select} ${S().shift}',
                  //   allowAddNew: false, // enable "Add new item" option
                ),
                buildDropdown(
                  context,
                  '${S().select} ${S().length}',
                  selectedLength, length!,
                  (value) {
                    setState(() {
                      selectedLength = value;
                    });
                  },
                  '${S().select} ${S().length}',
                  suffixText: 'Mt', // يمكنك إضافة النص الذي تريده هنا
                  isNumeric: true,
                  allowAddNew: true, // enable "Add new item" option
                ),
                buildDropdown(
                  context,
                  '${S().select} ${S().quantity}',
                  selectedQuantity,
                  quantity!,
                  (value) {
                    setState(() {
                      selectedQuantity = value;
                    });
                  },
                  '${S().select} ${S().quantity}',
                  suffixText: S().pcs, // يمكنك إضافة النص الذي تريده هنا
                  isNumeric: true,
                  allowAddNew: true, // enable "Add new item" option
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save_as_outlined),
                  onPressed: addItem,
                  label: Text('${S().add} ${S().item}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
