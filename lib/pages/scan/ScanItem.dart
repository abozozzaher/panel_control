import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:panel_control/model/user.dart';
import 'package:permission_handler/permission_handler.dart';
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
// Provider مع SharedPreferences
  @override
  void initState() {
    super.initState();
    scanItemService.requestCameraPermission();
    Provider.of<ScanItemProvider>(context, listen: false).reloadData();
  }

  Future<void> showAddCodeDialog() async {
    TextEditingController codeController = TextEditingController();
    final provider = Provider.of<ScanItemProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S().enter_code),
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
                            String formattedData =
                                '${baseUrl}${codeController.text.substring(0, 4)}-${codeController.text.substring(4, 6)}/${codeController.text}';

                            scanItemService
                                .fetchDataFromFirebase(formattedData)
                                .then((data) {
                              if (data != null) {
                                if (provider.scannedData
                                    .contains(formattedData)) {
                                  scanItemDialogs.showDuplicateDialog(
                                      context, codeController.text);
                                } else {
                                  setState(() {
                                    //  provider.addScanData(formattedData, data);
                                    provider.addScanData(
                                        formattedData, provider.codeDetails);
                                  });
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
          setState(() {
            provider.addScanData(code, {});
          });
          /*  
        provider.addScanData(code, {});
          
          setState(() {
            scannedData.add(code);
          });
          */
          scanItemService.playSound('assets/sound/beep.mp3');
          scanItemService.fetchDataFromFirebase(code).then((data) {
            if (data != null) {
              setState(() {
                provider.codeDetails[code] = data;
              });
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${S().scanned} $code'),
              backgroundColor: scanData.format == BarcodeFormat.qrcode
                  ? Colors.green
                  : Colors.blue,
            ),
          );
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
    int totalWeight = 0;

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
        if (weight is int) {
          totalWeight += weight;
        } else if (weight is String) {
          totalWeight += int.tryParse(weight) ?? 0;
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
        toggleTheme: widget.toggleTheme,
        toggleLocale: widget.toggleLocale,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          kIsWeb
              ? Container()
              : Container(
                  color: Colors.blue,
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
                              '${S().total_codes_scanned} : ${provider.scannedData.length} PPcs',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13)),
                          Text('${S().total_quantity} : $totalQuantity Pcs',
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
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton(
                          child: Text('Save and send data'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Center(
                                        child: Text(
                                            'Long press to activate the button')),
                                    duration: Duration(seconds: 2)));
                          },
                          onLongPress: provider.scannedData.isNotEmpty &&
                                  userData!.work == true
                              ? () => showConfirmDialog(userData)
                              : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Center(
                                          child: Text('No data to send')),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                },
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
                          provider.removeScanData(code);

                          //   scannedData.removeAt(index);
                          //  codeDetails.remove(code);
                        });
                      },
                    ),
                    onTap: () async {
                      final data =
                          await scanItemService.fetchDataFromFirebase(code);
                      scanItemDialogs.showDetailsDialog(context, code, data);
                    },
                  );
                },
              ),
            ),
          ),
          scanDataTableWidgets.scrollViewScannedDataTableWidget(context),

          /*
          Container(
            color: Colors.grey,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(
                        label: Text(S().type,
                            style: TextStyle(color: Colors.greenAccent))),
                    DataColumn(
                        label: Text(S().color,
                            style: TextStyle(color: Colors.greenAccent))),
                    DataColumn(
                        label: Text(S().width,
                            style: TextStyle(color: Colors.greenAccent))),
                    DataColumn(
                        label: Text(S().yarn_number,
                            style: TextStyle(color: Colors.greenAccent))),
                    DataColumn(
                        label: Text(S().quantity,
                            style: TextStyle(color: Colors.greenAccent))),
                    DataColumn(
                        label: Text(S().length,
                            style: TextStyle(color: Colors.greenAccent))),
                    DataColumn(
                        label: Text('${S().weight} ${S().total}',
                            style: TextStyle(color: Colors.greenAccent))),
                    DataColumn(
                        label: Text('${S().scanned}',
                            style: TextStyle(color: Colors.greenAccent))),
                  ],
                  rows: buildRows(codeDetails),
                ),
              ),
            ),
          ),
          */
        ],
      ),
    );
  }

/*
  List<DataRow> buildRows(codeDetails) {
    final provider = Provider.of<ScanItemProvider>(context);

    Map<String, Map<String, dynamic>> aggregatedData = {};

    for (var entry in provider.codeDetails.entries) {
      var data = entry.value;

      String key =
          '${data['yarn_number']}-${data['type']}-${data['color']}-${data['width']}';

      if (!aggregatedData.containsKey(key)) {
        aggregatedData[key] = {
          'yarn_number': data['yarn_number'],
          'type': data['type'],
          'color': data['color'],
          'width': data['width'],
          'total_weight': 0,
          'quantity': 0,
          'length': 0,
          'scanned_data': 0,
        };
      }
      aggregatedData[key]!['total_weight'] += data['total_weight'] is int
          ? data['total_weight']
          : int.tryParse(data['total_weight'].toString()) ?? 0;
      aggregatedData[key]!['quantity'] += data['quantity'] is int
          ? data['quantity']
          : int.tryParse(data['quantity'].toString()) ?? 0;
      aggregatedData[key]!['length'] += data['length'] is int
          ? data['length']
          : int.tryParse(data['length'].toString()) ?? 0;
      aggregatedData[key]!['scanned_data'] += 1;
    }

    return aggregatedData.entries.map((entry) {
      var data = entry.value;
      return DataRow(cells: [
        DataCell(Center(
          child: Text(data['type'].toString(),
              style: const TextStyle(color: Colors.redAccent)),
        )),
        DataCell(Center(
          child: Text(data['color'].toString(),
              style: const TextStyle(color: Colors.redAccent)),
        )),
        DataCell(Center(
            child: Text('${data['width']} mm',
                style: const TextStyle(color: Colors.redAccent)))),
        DataCell(Center(
            child: Text('${data['yarn_number']} D',
                style: const TextStyle(color: Colors.redAccent)))),
        DataCell(Center(
            child: Text('${data['quantity']} Pcs',
                style: const TextStyle(color: Colors.redAccent)))),
        DataCell(Center(
            child: Text('${data['length']} Mt',
                style: const TextStyle(color: Colors.redAccent)))),
        DataCell(Center(
            child: Text('${data['total_weight']} Kg',
                style: const TextStyle(color: Colors.redAccent)))),
        DataCell(Center(
            child: Text(data['scanned_data'].toString(),
                style: const TextStyle(color: Colors.black)))),
      ]);
    }).toList();
  }
*/
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

    final int totalWeight = provider.codeDetails.values
        .map((data) => data['total_weight'] is int
            ? data['total_weight']
            : ((int.tryParse(data['total_weight'].toString()) ?? 0) as int))
        .fold(0, (sum, item) => sum + (item as int));

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
          title: const Text(
            'Confirm Data',
            textAlign: TextAlign.center,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total Weight: $totalWeight Kg'),
              Text('Total Length: $totalLength MT'),
              Text('Total Quantity: $totalQuantity Pcs'),
              Text('Scanned Data Length: ${formattedScannedData.length}'),
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
                        // إرسال البيانات إلى Firebase
                        await FirebaseFirestore.instance
                            .collection('seles')
                            .doc(codeSales)
                            .set({
                          'date': DateTime.now(),
                          'codeSales': codeSales,
                          'totalWeight': totalWeight,
                          'totalLength': totalLength,
                          'totalQuantity': totalQuantity,
                          'scannedData': formattedScannedData,
                          'scannedDataLength': formattedScannedData.length,
                          'payـstatus': false,
                          'created_by': userData!.id,
                        });

                        setState(() {
                          provider.scannedData.clear();
                          provider.codeDetails.clear();
                        });

                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        'Send',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      )),
                ),
                const SizedBox(height: 5, width: 5),
                Expanded(
                  child: TextButton(
                    style:
                        TextButton.styleFrom(backgroundColor: Colors.redAccent),
                    child: Text(
                      S().cancel,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
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
