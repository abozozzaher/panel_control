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

class ScanItemQr extends StatefulWidget {
  @override
  _ScanItemQrState createState() => _ScanItemQrState();
}

class _ScanItemQrState extends State<ScanItemQr> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${S().scan} ${S().new1} ${S().item}'),
          centerTitle: true,
        ),
        body: Center(child: CircularProgressIndicator()));
  }
}
