// flutter run -d chrome --web-renderer html
// alias firebase="`npm config get prefix`/bin/firebase"
// firebase init
// flutter build web --release --web-renderer=html
// flutter build web --web-renderer html
// firebase deploy
// لرفع التطبيق علي اعادة تشغيل الكمبيوتر لتفريغ الكاش
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'package:pdf/widgets.dart' as pw;

import 'generated/l10n.dart';
import 'service/app_drawer.dart';

class TestPage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;
  const TestPage(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(S().add),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/');
          },
        ),
      ),
      drawer: AppDrawer(
        toggleTheme: widget.toggleTheme,
        toggleLocale: widget.toggleLocale,
      ),
      body: Container(
        child: Center(
          child: ElevatedButton(
            onPressed: _printDocument,
            child: Text('Print Document'),
          ),
        ),
      ),
    );
  }

  void _printDocument() {
    final doc = pw.Document();

    doc.addPage(
      pw.Page(
        pageFormat:
            PdfPageFormat(100 * PdfPageFormat.mm, 100 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Container(
            color: PdfColors.red,
            child: pw.Center(
              child: pw.Text(
                'Hello World',
                style: pw.TextStyle(
                  color: PdfColors.white,
                ),
              ),
            ),
          );
        },
      ),
    );

    Printing.layoutPdf(onLayout: (PdfPageFormat format) async => doc.save());
  }
}


/*


import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';

import '../../generated/l10n.dart';
import '../../service/app_drawer.dart';

class ScanItemQr extends StatefulWidget {
  final VoidCallback toggleTheme;
  final VoidCallback toggleLocale;

  const ScanItemQr(
      {super.key, required this.toggleTheme, required this.toggleLocale});

  @override
  _ScanItemQrState createState() => _ScanItemQrState();
}

class _ScanItemQrState extends State<ScanItemQr> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final Set<String> scannedCodes = {};
  final AudioPlayer player = AudioPlayer();
  final String urlPattern = r'^https://panel-control-company-zaher\.web\.app/\d{4}-\d{2}/\d{16}$';

  void _onQRViewCreated(QRViewController controller) {
    controller.scannedDataStream.listen((scanData) async {
      final code = scanData.code;
      if (code != null && !scannedCodes.contains(code)) {
        if (_isValidUrl(code)) {
          setState(() {
            scannedCodes.add(code);
          });
          await player.play(AssetSource('assets/sound/scanner-beep.mp3'));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registered: $code')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid URL: $code')),
          );
        }
      }
    });
  }

  bool _isValidUrl(String url) {
    final regex = RegExp(urlPattern);
    return regex.hasMatch(url);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png'],
    );
    if (result != null) {
      final file = result.files.single;
      // يمكنك إضافة معالجة إضافية للملف هنا
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Picked file: ${file.name}')),
      );
    }
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text('${S().scan} ${S().new1} ${S().item}'),
        centerTitle: true,
        leading: isMobile
            ? IconButton(
                icon: Icon(Icons.arrow_back),
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
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: Text('QR Scanner'),
                    ),
                    body: QRView(
                      key: qrKey,
                      onQRViewCreated: _onQRViewCreated,
                      overlay: QrScannerOverlayShape(
                        borderColor: Colors.red,
                        borderRadius: 10,
                        borderLength: 30,
                        borderWidth: 10,
                        cutOutSize: MediaQuery.of(context).size.width * 0.8,
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Text('Open Camera'),
          ),
          ElevatedButton(
            onPressed: _pickFile,
            child: Text('Upload Image/PDF'),
          ),
          Expanded(
            child: ListView(
              children: scannedCodes
                  .map((code) => ListTile(
                        title: Text(code),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}


*/