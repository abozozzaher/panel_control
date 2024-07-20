// flutter run -d chrome --web-renderer html
// alias firebase="`npm config get prefix`/bin/firebase"
// firebase init
// flutter build web --release --web-renderer=html
// flutter build web --web-renderer html
// firebase deploy

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
