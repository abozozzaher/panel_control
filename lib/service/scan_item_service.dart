import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/dataBase.dart';
import '../generated/l10n.dart';
import 'toasts.dart';

class ScanItemService {
  final AudioPlayer audioPlayer = AudioPlayer();
  final DatabaseHelper databaseHelper = DatabaseHelper();

  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      if (await Permission.camera.request().isGranted) {
        print(S().camera_permission_granted);
        showToast(S().camera_permission_granted);
      }
    }
    if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  ///999
  Future<Map<String, dynamic>?> fetchDataFromFirebase(String url) async {
    try {
      String baseUrl = 'https://admin.bluedukkan.com/';
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

      if (document.exists) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        if (data['sale_status'] != false) {
          print('11113 Error fetching data: ');

          return null; // or throw an exception, depending on your requirements
        } else {
          return data;
        }
      } else {
        print('11112 Error fetching data: ');

        return null;
      }
    } catch (e) {
      print('11111 Error fetching data: $e');
      return null;
    }
  }

  ///9999
  Future<List<Map<String, dynamic>?>?> fetchDataFromFirebaseForInvoice(
      String url) async {
    try {
      String baseUrl = 'https://admin.bluedukkan.com/';
      if (!url.startsWith(baseUrl)) {
        throw const FormatException('Invalid URL format');
      }
      String remainingPath = url.substring(baseUrl.length);
      String monthFolder = remainingPath.substring(0, 7);

      // Get the list of product IDs
      List<String> productIds = await _fetchProductIdsFromUrl(url);

      // Fetch data for each product ID
      List<Map<String, dynamic>?> data = [];
      for (String productId in productIds) {
        DocumentSnapshot document = await FirebaseFirestore.instance
            .collection('products')
            .doc('productsForAllMonths')
            .collection(monthFolder)
            .doc(productId)
            .get();
        data.add(
            document.exists ? document.data() as Map<String, dynamic>? : null);
      }
      return data;
    } catch (e) {
      print('11111 Error fetching data: $e');
      return null;
    }
  }

  Future<List<String>> _fetchProductIdsFromUrl(String url) async {
    // Assuming the product IDs are in the format [id1, id2, id3]
    String productIdString = url.substring(url.lastIndexOf('/') + 1);
    List<String> productIds =
        productIdString.substring(1, productIdString.length - 1).split(', ');
    return productIds;
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
      showToast('Error playing sound');
      print('Error playing sound: $e');
    }
  }
}
