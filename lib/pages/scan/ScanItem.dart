import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panel_control/model/user.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../generated/l10n.dart';
import '../../provider/scan_item_provider.dart';
import '../../provider/user_provider.dart';
import '../../service/app_drawer.dart';
import '../../service/scan_item_service.dart';
import 'Dialogs.dart';
import 'Scanned_data_table_widgets.dart';

class ScanItemQr extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const ScanItemQr(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  State<StatefulWidget> createState() => _ScanItemQrState();
}

class _ScanItemQrState extends State<ScanItemQr> {
  final ScanItemService scanItemService = ScanItemService();
  final ScanDataTableWidgets scanDataTableWidgets = ScanDataTableWidgets();
  final ScanItemDialogs scanItemDialogs = ScanItemDialogs();

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? controller;
  List<String> scannedData = [];
  Map<String, Map<String, dynamic>> codeDetails = {}; // لتخزين تفاصيل كل كود
  bool _isProcessing = false;
  @override
  void initState() {
    super.initState();
    scanItemService.requestCameraPermission();
  }

  Future<void> showAddCodeDialog() async {
    TextEditingController codeController = TextEditingController();
    final provider = Provider.of<ScanItemProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S().enter_code, textAlign: TextAlign.center),
          content: TextField(
              controller: codeController,
              decoration: InputDecoration(hintText: S().enter_code_here),
              keyboardType: TextInputType.number),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S().cancel),
            ),
            ValueListenableBuilder(
                valueListenable: codeController,
                builder: (context, value, child) {
                  return TextButton(
                    onPressed: codeController.text.length == 20 &&
                            codeController.text.isNotEmpty
                        ? () {
                            String baseUrl =
                                'https://panel-control-company-zaher.web.app/';
                            String code =
                                '$baseUrl${codeController.text.substring(0, 4)}-${codeController.text.substring(4, 6)}/${codeController.text}';

                            scanItemService
                                .fetchDataFromFirebase(code)
                                .then((data) {
                              if (data != null) {
                                if (provider.scannedData.contains(code)) {
                                  scanItemDialogs.showDuplicateDialog(
                                      context, codeController.text);
                                } else {
                                  setState(() {
                                    provider.addScannedData(
                                        code); // حفظ الكود في قائمة الكودات الممسوحة

                                    provider.addCodeDetails(code);
                                  });
                                  setState(() {
                                    provider.codeDetails[code] = data;
                                  });
                                  provider.saveCodeDetails(
                                      code, data); // Save data to the database

                                  scanItemService
                                      .playSound('assets/sound/beep.mp3');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '${S().add} ${S().the_code} ${codeController.text}'),
                                        backgroundColor: Colors.green),
                                  );
                                  Navigator.of(context).pop();
                                }
                              } else {
                                scanItemDialogs.showErorrDialog(
                                    context, codeController.text);
                              }
                            });
                          }
                        : null,
                    child: Text(S().add),
                  );
                }),
          ],
        );
      },
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      if (_isProcessing) return;

      setState(() {
        _isProcessing = true;
      });

      final String code = scanData.code!;
      final provider = Provider.of<ScanItemProvider>(context, listen: false);
      if (!provider.scannedData.contains(code)) {
        if (code.contains('https://panel-control-company-zaher.web.app/')) {
          //  setState(() {});
          provider.addScannedData(code); // حفظ الكود في قائمة الكودات الممسوحة
          provider.addCodeDetails(code);
          scanItemService.playSound('assets/sound/beep.mp3');

          scanItemService.fetchDataFromFirebase(code).then((data) {
            if (data != null) {
              setState(() {
                provider.codeDetails[code] = data;
              });
              provider.saveCodeDetails(code, data); // Save data to the database

              // لعرض الكود مختصر بدون الرابط والشهر
              var urlLength =
                  'https://panel-control-company-zaher.web.app/'.length;
              final displayCode = code.length > urlLength + 8
                  ? code.substring(urlLength + 8)
                  : code;
              // هذه نهاية الامر السابق لعرض الرابط مختصر
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${S().scanned} $displayCode'),
                  backgroundColor: scanData.format == BarcodeFormat.qrcode
                      ? Colors.green
                      : Colors.blue,
                ),
              );
            }
          });
        } else {
          scanItemDialogs.showErorrDialog(context, code);
        }
      } else {
        scanItemDialogs.showDuplicateDialog(context, code);
      }
      setState(() {
        _isProcessing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ScanItemProvider>(context);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userData = userProvider.user;

    int totalQuantity = 0;
    int totalLength = 0;
    double totalWeight = 0.0;
    // int totalWeight = 0;

// حساب إجمالي الكميات
    for (var data in provider.codeDetails.values) {
      if (data.containsKey('quantity')) {
        var quantity = data['quantity'];
        if (quantity is int) {
          totalQuantity += quantity;
        } else if (quantity is String) {
          totalQuantity += int.tryParse(quantity) ?? 0;
        }
      }
    }
    // حساب إجمالي الامتار
    for (var data in provider.codeDetails.values) {
      if (data.containsKey('length')) {
        var length = data['length'];
        if (length is int) {
          totalLength += length;
        } else if (length is String) {
          totalLength += int.tryParse(length) ?? 0;
        }
      }
    }

    // حساب إجمالي الوزن
    for (var data in provider.codeDetails.values) {
      if (data.containsKey('total_weight')) {
        var weight = data['total_weight'];
        if (weight is num) {
          // Check if weight is a number (int or double)
          totalWeight += weight.toDouble(); // Convert to double
        } else if (weight is String) {
          totalWeight += double.tryParse(weight) ?? 0.0; // Parse to double
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${S().scan} ${S().new1} ${S().item}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: showAddCodeDialog,
          ),
        ],
      ),
      drawer: AppDrawer(
          toggleTheme: widget.toggleTheme, toggleLocale: widget.toggleLocale),
      body: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              kIsWeb
                  ? Container()
                  : SizedBox(
                      height: 300,
                      child: QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                      ),
                    ),
              Container(
                color: Colors.red,
                height: 100, // لتحديد ارتفاع ثابت
                child: Column(
                  children: [
                    Row(
                      children: [
                        //ا القسم الأول لعدد والكمية
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  '${S().total_codes_scanned} : ${provider.scannedData.length} ${S().unit}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                              Text(
                                  '${S().total_quantity} : $totalQuantity ${S().pcs}',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                        // ا  القسم الثاني لامتار و الوزن
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${S().total_length} : $totalLength MT',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                              Text('${S().total_weight} :  $totalWeight Kg',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // القسم الثالث رسالة التاكيد
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Center(
                                        child: Text(S()
                                            .long_press_to_activate_the_button)),
                                    duration: const Duration(seconds: 2)));
                              },
                              onLongPress: provider.scannedData.isNotEmpty &&
                                      userData!.work == true
                                  ? () {
                                      showConfirmDialog(userData);
                                    }
                                  : () {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Center(
                                              child: Text(S().no_data_to_send)),
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    },
                              child: Text(S().save_and_send_data),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 150,
                color: Colors.green,
                child: SingleChildScrollView(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.scannedData.length,
                    itemBuilder: (context, index) {
                      final code = provider.scannedData[index];

                      var urlLength =
                          'https://panel-control-company-zaher.web.app/'.length;
                      final displayCode = code.length > urlLength + 8
                          ? code.substring(urlLength + 8)
                          : code;

                      return ListTile(
                        title: Text(displayCode),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              provider.removeData(code);
                            });
                          },
                        ),
                        onTap: () async {
                          // طلب البيانات اولا من قاعدة البيانات
                          final data = provider.codeDetails[code];
                          scanItemDialogs.showDetailsDialog(
                              context, code, data);
                        },
                      );
                    },
                  ),
                ),
              ),
              scanDataTableWidgets.scrollViewScannedDataTableWidget(context),
            ],
          ),
        ),
      ),
    );
  }

// هذا دايلوك ارسال البيانات الى الفاير بيس وانتهاء العملية البيع
  Future<void> showConfirmDialog(UserData? userData) async {
    final provider = Provider.of<ScanItemProvider>(context, listen: false);

    String codeSales = scanItemService.generateCodeSales();

    List<String> formattedScannedData = [];

    final int totalQuantity = provider.codeDetails.values
        .map((data) => data['quantity'] is int
            ? data['quantity']
            : ((int.tryParse(data['quantity'].toString()) ?? 0) as int))
        .fold(0, (sum, item) => sum + (item as int));

    final int totalLength = provider.codeDetails.values
        .map((data) => data['length'] is int
            ? data['length']
            : ((int.tryParse(data['length'].toString()) ?? 0) as int))
        .fold(0, (sum, item) => sum + (item as int));

    final double totalWeight = provider.codeDetails.values
        .map((data) => double.tryParse(data['total_weight'].toString()) ?? 0.0)
        .fold(0, (sum, item) => sum + (item as double));

    for (var code in provider.scannedData) {
      if (code.startsWith('https://panel-control-company-zaher.web.app/')) {
        String formattedCode = code.replaceFirst(
            'https://panel-control-company-zaher.web.app/', '');
        formattedCode =
            formattedCode.substring(8); // remove the first 7 characters
        formattedScannedData.add(formattedCode);
      }
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S().confirm_data, textAlign: TextAlign.center),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${S().total_weight} : $totalWeight Kg'),
              Text('${S().total_length} : $totalLength MT'),
              Text('${S().total_quantity} : $totalQuantity ${S().pcs}'),
              Text(
                  '${S().scanned_data_length} : ${formattedScannedData.length}'),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                    child: TextButton(
                  style:
                      TextButton.styleFrom(backgroundColor: Colors.greenAccent),
                  onPressed: () async {
                    var salesStatusFalseDocs = provider.codeDetails;
                    bool allStatusFalse = true;
                    List<String> invalidDocuments = [];

                    // تحقق من حالة sale_status لكل مستند
                    salesStatusFalseDocs.forEach((key, value) {
                      //555
                      //    if (value is Map<String, dynamic> &&
                      if (
                          //
                          value.containsKey('sale_status')) {
                        bool saleStatus = value['sale_status'];
                        if (saleStatus != false) {
                          allStatusFalse = false;
                          invalidDocuments
                              .add(key); // أضف المستند غير المطابق إلى القائمة
                        }
                      } else {
                        allStatusFalse = false;
                        invalidDocuments
                            .add(key); // أضف المستند غير المطابق إلى القائمة
                      }
                    });

                    if (allStatusFalse) {
                      // إرسال البيانات إلى Firebase
                      await FirebaseFirestore.instance
                          .collection('seles')
                          .doc(codeSales)
                          .set({
                        'createdAt': DateFormat('yyyy-MM-dd HH:mm:ss', 'en')
                            .format(DateTime.now()),
                        'codeSales': codeSales,
                        'totalWeight': totalWeight,
                        'totalLength': totalLength,
                        'totalQuantity': totalQuantity,
                        'scannedData': formattedScannedData,
                        'scannedDataLength': formattedScannedData.length,
                        'payـstatus': false,
                        'created_by': userData!.id,
                        'not_attached_to_client': false
                      });
                      print('666666');
                      /* تعديل حالة المنتج من فولس الى ترو
                      // Update sale_status field in each document
                      formattedScannedData.forEach((remainingPath) {
                        String monthFolder =
                            '${remainingPath.substring(0, 4)}-${remainingPath.substring(4, 6)}';
                        print(monthFolder);
                        String productId = remainingPath.substring(0);
                        FirebaseFirestore.instance
                            .collection('products')
                            .doc('productsForAllMonths')
                            .collection(monthFolder)
                            .where('productId', isEqualTo: productId)
                            .get()
                            .then((querySnapshot) {
                          querySnapshot.docs.forEach((doc) {
                            doc.reference.update({'sale_status': true});
                          });
                        });
                      });
                      */
                      print('111111');
                      print(formattedScannedData);
                      print(invalidDocuments);

                      setState(() {
                        provider.scannedData.clear();
                        provider.codeDetails.clear();
                      });

                      Navigator.of(context).pop();
                    } else {
                      // عرض مربع حوار يظهر العناصر غير المطابقة
                      scanItemDialogs.soldOutDialog(context, invalidDocuments);
                    }
                  },
                  child: Text(S().send,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black)),
                )),
                const SizedBox(height: 5, width: 5),
                Expanded(
                  child: TextButton(
                    style:
                        TextButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: Text(S().cancel,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                    onPressed: () {
                      Navigator.of(context).pop();
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

  @override
  void dispose() {
    controller?.dispose();
    scanItemService.audioPlayer.dispose();
    super.dispose();
  }
}
