import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/clien.dart';
import 'toasts.dart';

import '../data/data_lists.dart';
import '../provider/invoice_provider.dart';

class InvoiceService {
  final BuildContext context;
  final InvoiceProvider invoiceProvider;
  Map<String, dynamic> separateData = {};

  InvoiceService(this.context, this.invoiceProvider);
  //999 هذا المستند كلو يحتاج الى تعديل بشان حفظ البيانات في المحلي
  final DataLists dataLists = DataLists();

  String generateInvoiceCode() {
    final DateTime now = DateTime.now();
    final String formattedDate =
        '${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.year.toString().substring(2)}';

    return formattedDate;
  }

  Map<String, dynamic> prepareData(
    Map<String, Map<String, dynamic>> aggregatedData,
    Map<String, dynamic> data,
  ) {
    String key =
        '${data['yarn_number']}-${data['type']}-${data['color']}-${data['width']}';

    // إنشاء خريطة جديدة لتخزين البيانات بشكل منفصل
    Map<String, dynamic> separateData = {
      'yarn_number': data['yarn_number'],
      'type': data['type'],
      'color': data['color'],
      'width': data['width'],
      'total_weight': double.tryParse(data['total_weight'].toString()) ?? 0.0,
      'quantity': data['quantity'] is int
          ? data['quantity']
          : int.tryParse(data['quantity'].toString()) ?? 0,
      'length': data['length'] is int
          ? data['length']
          : int.tryParse(data['length'].toString()) ?? 0,
      'scanned_data': 1,
      'product_id': data['productId'],
      'shift': data['shift'],
      'created_by': data['created_by'],
      'image_url': data['image_url'],

      // أضف هنا أي بيانات إضافية تحتاجها
    };

    if (!aggregatedData.containsKey(key)) {
      aggregatedData[key] = {
        'yarn_number': data['yarn_number'],
        'type': data['type'],
        'color': data['color'],
        'width': data['width'],
        'total_weight': 0.0,
        'quantity': 0,
        'length': 0,
        'scanned_data': 0,
      };
    }

    aggregatedData[key]!['total_weight'] += separateData['total_weight'];
    aggregatedData[key]!['quantity'] += separateData['quantity'];
    aggregatedData[key]!['length'] += separateData['length'];
    aggregatedData[key]!['scanned_data'] += 1;

    // إرجاع separateData لاستخدامها في دالة أخرى
    return separateData;
  }

  Future<Map<String, dynamic>?> fetchDataFromFirestore(String docId) async {
    final monthFolder = '${docId.substring(0, 4)}-${docId.substring(4, 6)}';
    final documentSnapshot = await FirebaseFirestore.instance
        .doc('/products/productsForAllMonths/$monthFolder/$docId')
        .get();

    if (documentSnapshot.exists) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      return data;
    }
    return null;
  }

  Future<Map<String, Map<String, dynamic>>> fetchData() async {
    Map<String, Map<String, dynamic>> aggregatedData = {};
    Map<String, dynamic> allSeparateData =
        {}; // خريطة لتخزين جميع البيانات المنفصلة
    List<String> selectedIds = invoiceProvider.selectionState.keys
        .where((id) => invoiceProvider.selectionState[id] == true)
        .toList();

    for (String id in selectedIds) {
      final itemData = invoiceProvider.getDataById(id);
      if (itemData != null) {
        List<dynamic> scannedData = itemData['scannedData'] ?? [];

        for (var docId in scannedData) {
          final cachedData = invoiceProvider.getCachedData(docId);

          if (cachedData != null) {
            final separateData = prepareData(aggregatedData, cachedData);
            allSeparateData[docId] = separateData; // حفظ البيانات المنفصلة
          } else {
            final data = await fetchDataFromFirestore(docId);
            if (data != null) {
              final separateData = prepareData(aggregatedData, data);
              allSeparateData[docId] = separateData; // حفظ البيانات المنفصلة
              invoiceProvider.cacheData(docId, data);
            }
          }
        }
      }
    }

    // تعيين البيانات المنفصلة للحفظ
    separateData = allSeparateData;
    return aggregatedData;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveData(
      Map<String, dynamic> aggregatedData,
      double finalTotal,
      ClienData? trader,
      double grandTotalPrice,
      double grandTotalPriceTaxs,
      double taxs,
      double previousDebts,
      double shippingFees,
      String? invoiceCode,
      String downloadUrlPdf,
      String shippingCompanyName,
      String shippingTrackingNumber,
      String packingBagsNumber,
      double totalWeight,
      int totalQuantity,
      int totalLength,
      int totalScannedData) async {
    // قائمة لجمع جميع الأسعار
    final totalLinePrices = aggregatedData.keys.map((groupKey) {
      return invoiceProvider.getPrice(groupKey);
    }).toList();
    // قائمة لجمع جميع الأسعار

    aggregatedData = aggregatedData.map((groupKey, groupData) {
      double price =
          double.tryParse(invoiceProvider.getPriceController(groupKey).text) ??
              0.00;

      // الحصول على السعر المناسب من allPrices
      final priceIndex = aggregatedData.keys.toList().indexOf(groupKey);
      final totalLinePrice = priceIndex < totalLinePrices.length
          ? totalLinePrices[priceIndex]
          : 0.00;
      // إضافة السعر إلى الماب الخاصة بكل مجموعة
      return MapEntry(groupKey, {
        ...groupData,
        'price': price,
        'totalLinePrices': totalLinePrice, // إضافة allPrice
      });
    });

    try {
      DocumentReference clientDocument =
          _firestore.collection('cliens').doc(trader!.codeIdClien);

      await clientDocument.collection('invoices').doc(invoiceCode).set({
        'aggregatedData': aggregatedData,
        'separateData': separateData, // استخدام البيانات المنفصلة هنا
        'finalTotal': finalTotal,
        'grandTotalPrice': grandTotalPrice,
        'grandTotalPriceTaxs': grandTotalPriceTaxs,
        'taxs': taxs,
        'previousDebts': previousDebts,
        'shippingFees': shippingFees,
        'shippingCompanyName': shippingCompanyName,
        'shippingTrackingNumber': shippingTrackingNumber,
        'packingBagsNumber': packingBagsNumber,
        "totalWeight": totalWeight,
        "totalQuantity": totalQuantity,
        "totalLength": totalLength,
        "totalScannedData": totalScannedData,
        'createdAt':
            DateFormat('yyyy-MM-dd HH:mm:ss', 'en').format(DateTime.now()),
        'downloadUrlPdf': downloadUrlPdf,
        'invoiceCode': invoiceCode,
        'trader': trader.toMap(),
      });
      for (var innerMap in separateData.values) {
        final productId = innerMap['product_id'];

        final monthFolder =
            '${productId.substring(0, 4)}-${productId.substring(4, 6)}';
        final productDocument = _firestore
            .collection('products')
            .doc('productsForAllMonths')
            .collection(monthFolder)
            .doc(productId);

        productDocument.update({
          'sale_status': true, // or any other status you want to update
        });
      }

      List<String> selectedIds = invoiceProvider.selectionState.keys
          .where((id) => invoiceProvider.selectionState[id] == true)
          .toList();

      for (String id in selectedIds) {
        _firestore
            .collection('seles')
            .doc(id)
            .update({'not_attached_to_client': true});
      }
    } catch (e) {
      showToast('Error saving data to Firestore: $e');
      print('Error saving data to Firestore: $e');
      rethrow; // أعيد الخطأ للتعامل معه لاحقًا
    }
  }
}
