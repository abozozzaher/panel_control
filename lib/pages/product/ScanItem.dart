import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../generated/l10n.dart';
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
  final AudioPlayer audioPlayer = AudioPlayer();

  bool _isDialogShowing = false;
  bool _isProcessing = false; // متغير لمتابعة حالة المعالجة
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
    _startTimer();
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

  void _startTimer() {
    _timer = Timer(Duration(hours: 1), () {
      setState(() {
        scannedData.clear();
      });
    });
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
    if (_isDialogShowing) return; // التحقق من عدم إظهار مربع الحوار مسبقًا
    _isDialogShowing = true; // ضبط المتغير إلى true لإظهار مربع الحوار
    _playSound('assets/sound/ripiito.mp3');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Duplicate Code'),
          content: Text('The code "$code" has already been scanned.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isDialogShowing =
                    false; // إعادة ضبط المتغير إلى false عند إغلاق مربع الحوار
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErorrDialog(String code) {
    if (_isDialogShowing) return; // التحقق من عدم إظهار مربع الحوار مسبقًا
    _isDialogShowing = true; // ضبط المتغير إلى true لإظهار مربع الحوار
    _playSound('assets/sound/error-404.mp3');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error Code'),
          content: Text(
              'Invalid code scanned and removed. رمز غير صالح تم مسحه ضوئيًا وإزالته.'),
          backgroundColor: Colors.redAccent,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isDialogShowing =
                    false; // إعادة ضبط المتغير إلى false عند إغلاق مربع الحوار
              },
              child: Text('OK'),
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
        throw FormatException('Invalid URL format');
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
          title: Text('Details for $code'),
          content: SingleChildScrollView(
            // إضافة SingleChildScrollView هنا
            child: data != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: data.entries.map((entry) {
                      return ListTile(
                        title: Text('${entry.key}: ${entry.value}'),
                      );
                    }).toList(),
                  )
                : Text('No data found for this code.'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
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
          title: Text('Enter Code'),
          content: TextField(
            controller: codeController,
            decoration: InputDecoration(hintText: 'Enter code here'),
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
                              scannedData.add(value.text);
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
      if (_isProcessing) return; // تجنب معالجة عدة أكواد في نفس الوقت

      setState(() {
        _isProcessing = true; // تعيين حالة المعالجة
      });

      final String code = scanData.code!;
      if (!scannedData.contains(code)) {
        if (code.contains('https://panel-control-company-zaher.web.app/')) {
          setState(() {
            scannedData.add(code);
          });
          _playSound('assets/sound/beep.mp3');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Scanned: $code'),
              backgroundColor: scanData.format == BarcodeFormat.qrcode
                  ? Colors.green
                  : Colors.yellowAccent,
            ),
          );
        } else {
          _showErorrDialog(code);
          /*
          await _playSound('assets/sound/error-404.mp3');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Invalid code scanned and removed. رمز غير صالح تم مسحه ضوئيًا وإزالته.'),
              backgroundColor: Colors.red,
            ),
          );
          */
        }
        //  await Future.delayed(  Duration(seconds: 2)); // تأخير قبل السماح بالمسح التالي
      } else {
        //  await _playSound('assets/sound/ripiito.mp3');
        //   await Future.delayed(Duration(seconds: 2)); // تأخير قبل السماح بالمسح التالي
        _showDuplicateDialog(code);
      }
      setState(() {
        _isProcessing = false; // إعادة تعيين حالة المعالجة
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.add),
            onPressed: _showAddCodeDialog,
          ),
        ],
      ),
      drawer: AppDrawer(
        toggleTheme: widget.toggleTheme,
        toggleLocale: widget.toggleLocale,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          scannedData.removeAt(index);
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
