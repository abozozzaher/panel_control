import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../generated/l10n.dart';
import '../../model/user.dart';
import '../../service/app_drawer.dart';

class ScanItemQr extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const ScanItemQr(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  State<StatefulWidget> createState() => _ScanItemQrState();
}

class _ScanItemQrState extends State<ScanItemQr> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  List<String> scannedData = [];
  Map<String, Map<String, dynamic>> codeDetails = {}; // لتخزين تفاصيل كل كود
  final AudioPlayer audioPlayer = AudioPlayer();

  bool _isDialogShowing = false;
  bool _isProcessing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  String generateCodeSales() {
    DateTime now = DateTime.now();
    var formatter = DateFormat('yyyyMMddHHmm');
    String date = formatter.format(now);
    String serialNumber = date.replaceAllMapped(RegExp(r'[٠-٩]'),
        (match) => (match.group(0)!.codeUnitAt(0) - 1632).toString());
    return serialNumber;
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      if (await Permission.camera.request().isGranted) {
        print('Camera permission granted');
      }
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _playSound(String path) async {
    try {
      await audioPlayer.setAsset(path);
      await audioPlayer.play();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }

  void _showDuplicateDialog(String code) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    _playSound('assets/sound/ripiito.mp3');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S().duplicate_code),
          content:
              Text('${S().the_code} "$code" ${S().has_already_been_scanned}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isDialogShowing = false;
              },
              child: Text(S().ok),
            ),
          ],
        );
      },
    );
  }

  void _showErorrDialog(String code) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    _playSound('assets/sound/error-404.mp3');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S().error_code),
          content: const Text(
              'Invalid code scanned and removed. رمز غير صالح تم مسحه ضوئيًا وإزالته.'),
          backgroundColor: Colors.redAccent,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isDialogShowing = false;
              },
              child: Text(S().ok),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _fetchDataFromFirebase(String url) async {
    try {
      String baseUrl = 'https://panel-control-company-zaher.web.app/';
      if (!url.startsWith(baseUrl)) {
        throw const FormatException('Invalid URL format');
      }
      String remainingPath = url.substring(baseUrl.length);
      String monthFolder = remainingPath.substring(0, 7);
      String productId = remainingPath.substring(8);

      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('products')
          .doc('productsForAllMonths')
          .collection(monthFolder)
          .doc(productId)
          .get();
      return document.exists ? document.data() as Map<String, dynamic>? : null;
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  void _showDetailsDialog(String code, Map<String, dynamic>? data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${S().details} $code'),
          content: SingleChildScrollView(
            child: data != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: data.entries.map((entry) {
                      return ListTile(
                        title: Text('${entry.key}: ${entry.value}'),
                      );
                    }).toList(),
                  )
                : Text(S().no_data_found_for_this_code),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S().ok),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddCodeDialog() async {
    TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S().enter_code),
          content: TextField(
            controller: codeController,
            decoration: InputDecoration(hintText: S().enter_code_here),
            keyboardType: TextInputType.number,
          ),
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
                    onPressed: value.text.length == 20 && value.text.isNotEmpty
                        ? () {
                            setState(() {
                              String baseUrl =
                                  'https://panel-control-company-zaher.web.app/';
                              String formattedData =
                                  '${baseUrl}${value.text.substring(0, 4)}-${value.text.substring(4, 6)}/${value.text}';

                              scannedData.add(formattedData);
                              _fetchDataFromFirebase(formattedData)
                                  .then((data) {
                                if (data != null) {
                                  setState(() {
                                    codeDetails[formattedData] = data;
                                  });
                                }
                              });
                            });
                            Navigator.of(context).pop();
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
      if (!scannedData.contains(code)) {
        if (code.contains('https://panel-control-company-zaher.web.app/')) {
          setState(() {
            scannedData.add(code);
          });
          _playSound('assets/sound/beep.mp3');
          _fetchDataFromFirebase(code).then((data) {
            if (data != null) {
              setState(() {
                codeDetails[code] = data;
              });
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${S().scanned} $code'),
              backgroundColor: scanData.format == BarcodeFormat.qrcode
                  ? Colors.green
                  : Colors.yellowAccent,
            ),
          );
        } else {
          _showErorrDialog(code);
        }
      } else {
        _showDuplicateDialog(code);
      }
      setState(() {
        _isProcessing = false;
      });
    });
  }

  List<DataRow> _buildRows() {
    Map<String, Map<String, dynamic>> aggregatedData = {};

    for (var entry in codeDetails.entries) {
      //   var code = entry.key;
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
        DataCell(Text(data['type'].toString(),
            style: const TextStyle(color: Colors.redAccent))),
        DataCell(Text(data['color'].toString(),
            style: const TextStyle(color: Colors.redAccent))),
        DataCell(Text('${data['width']} mm',
            style: const TextStyle(color: Colors.redAccent))),
        DataCell(Text('${data['yarn_number']} D',
            style: const TextStyle(color: Colors.redAccent))),
        DataCell(Text('${data['quantity']} Pcs',
            style: const TextStyle(color: Colors.redAccent))),
        DataCell(Text('${data['length']} Mt',
            style: const TextStyle(color: Colors.redAccent))),
        DataCell(Text('${data['total_weight']} Kg',
            style: const TextStyle(color: Colors.redAccent))),
        DataCell(Text(data['scanned_data'].toString(),
            style: const TextStyle(color: Colors.greenAccent))),
      ]);
    }).toList();
  }

  Future<void> _showConfirmDialog() async {
    String codeSales = generateCodeSales();

    final int totalQuantity = codeDetails.values
        .map((data) => data['quantity'] is int
            ? data['quantity']
            : ((int.tryParse(data['quantity'].toString()) ?? 0) as int))
        .fold(0, (sum, item) => sum + (item as int));

    final int totalLength = codeDetails.values
        .map((data) => data['length'] is int
            ? data['length']
            : ((int.tryParse(data['length'].toString()) ?? 0) as int))
        .fold(0, (sum, item) => sum + (item as int));

    final int totalWeight = codeDetails.values
        .map((data) => data['total_weight'] is int
            ? data['total_weight']
            : ((int.tryParse(data['total_weight'].toString()) ?? 0) as int))
        .fold(0, (sum, item) => sum + (item as int));

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
              Text('Scanned Data Length: ${scannedData.length}'),
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
                          'scannedData': scannedData,
                          'scannedDataLength': scannedData.length,
                          'payـstatus': false,
                          //   'created_by': UserData.fromMap(  {'uid': FirebaseAuth.instance.currentUser!.uid})
                        });
                        setState(() {
                          scannedData.clear();
                          codeDetails.clear();
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
  Widget build(BuildContext context) {
    var userData = Provider.of<UserData>(context);

    int totalQuantity = 0;
    int totalLength = 0;
    int totalWeight = 0;

// حساب إجمالي الكميات
    for (var data in codeDetails.values) {
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
    for (var data in codeDetails.values) {
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
    for (var data in codeDetails.values) {
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
            onPressed: _showAddCodeDialog,
          ),
        ],
      ),
      drawer: AppDrawer(
        toggleTheme: widget.toggleTheme,
        toggleLocale: widget.toggleLocale,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 6,
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
                    // القسم الأول
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              '${S().total_codes_scanned} : ${scannedData.length} PPcs',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13)),
                          Text('${S().total_quantity} : $totalQuantity Pcs',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                    // القسم الثاني
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
                // القسم الثالث
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Center(
                                    child: Text(
                                        'Long press to activate the button')),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Text('Save and send data'),
                          onLongPress: scannedData.isNotEmpty
                              ? _showConfirmDialog
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
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scannedData.length,
                itemBuilder: (context, index) {
                  final code = scannedData[index];
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
                          scannedData.removeAt(index);
                          codeDetails.remove(code);
                        });
                      },
                    ),
                    onTap: () async {
                      final data = await _fetchDataFromFirebase(code);
                      _showDetailsDialog(code, data);
                    },
                  );
                },
              ),
            ),
          ),
          Expanded(
            flex: 6,
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
                  rows: _buildRows(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
