import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../provider/scan_item_provider.dart';
import 'dataBase.dart';

class ScanItemService {
  final AudioPlayer audioPlayer = AudioPlayer();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> requestCameraPermission() async {
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

  Future<Map<String, dynamic>?> fetchDataFromFirebase(String url) async {
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
      print('11111 Error fetching data: $e');
      return null;
    }
  }

  String generateCodeSales() {
    DateTime now = DateTime.now();
    var formatter = DateFormat('yy0MM0dd0HH0mm0ss0');
    String date = formatter.format(now);
    String serialNumber = date.replaceAllMapped(RegExp(r'[٠-٩]'),
        (match) => (match.group(0)!.codeUnitAt(0) - 1632).toString());
    return serialNumber;
  }

  Future<void> playSound(String path) async {
    try {
      await audioPlayer.setAsset(path);
      await audioPlayer.play();
    } catch (e) {
      print('Error playing sound: $e');
    }
  }
}
