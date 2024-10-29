import 'dart:io';
import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../generated/l10n.dart';
import '../../service/app_drawer.dart';
import '../../data/data_lists.dart';
import '../../service/dropdownWidget.dart';
import '../../service/toasts.dart';
import 'generate_and_print_pdf.dart';
import 'helper.dart';

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
  // String yearMonth = DateFormat('yyyy-MM').format(DateTime.now());
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

  Future<void> addItem() async {
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
                      // التحقق من حالة الشبكة
                      bool isOnline = await isNetworkAvailable();
                      if (!isOnline) {
                        showToast(S()
                            .data_will_be_recorded_when_internet_connection_is_restored);
                      }
                      setState(() {
                        isUploading = true; // Set the uploading flag to true
                      });

                      if (selectedImage != null || webImage != null) {
                        try {
                          imageUrl = await uploadImageToStorage(
                              selectedImage, productId, webImage);

                          showToast(S().image_uploaded_successfully);
                        } catch (e) {
                          showToast('${S().failed_to_upload_image} : $e');
                          setState(() {
                            isUploading = false;
                          });
                          return;
                        }
                      }

                      String englishYearMonth =
                          convertArabicToEnglishForMonth(yearMonth);

                      // Generate and print PDF
                      await generateAndPrintPDF(
                          context,
                          convertArabicToEnglish,
                          generateQRCodeImage,
                          englishProductId,
                          imageUrl,
                          englishYearMonth,
                          selectedType,
                          selectedColor,
                          selectedWidth,
                          selectedWeight,
                          selectedYarnNumber,
                          selectedShift,
                          selectedQuantity,
                          selectedLength);

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
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textDirection: ui.TextDirection.rtl),
                const SizedBox(height: 10),
                if (selectedImage != null || webImage != null)
                  kIsWeb
                      ? Image.memory(webImage!, width: 200, height: 200)
                      : Image.file(File(selectedImage!.path),
                          width: 200, height: 200),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined),
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
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.replay_sharp),
                  label: Text(S().reprint_item),
                  onPressed: () async {
                    // استرجاع رابط الـ PDF المحفوظ
                    String? lastSavedUrl = await getFileUrl();

                    if (lastSavedUrl != null) {
                      await openPdf(lastSavedUrl); // فتح رابط الـ PDF

                      // قم باستخدام الرابط حسب حاجتك، مثلاً فتحه في المتصفح أو إعادة طباعته
                      showToast('${S().last_saved_pdf}: $lastSavedUrl');
                      print('${S().last_saved_pdf}: $lastSavedUrl');
                      // يمكنك إضافة كود لطباعة الرابط هنا
                    } else {
                      showToast(S().no_pdf_url_found);
                      print(S().no_pdf_url_found);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
