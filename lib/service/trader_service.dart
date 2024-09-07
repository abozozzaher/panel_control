import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../data/dataBase.dart';

class TraderService {
  final DatabaseHelper databaseHelper = DatabaseHelper();

  /// 5555
  Future<double> fetchLastDues(String codeIdClien) async {
    final traderAccountCollection = FirebaseFirestore.instance
        .collection('cliens')
        .doc(codeIdClien)
        .collection('account');

    final lastDuesSnapshot = await traderAccountCollection
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (lastDuesSnapshot.docs.isNotEmpty) {
      final lastDuesDoc = lastDuesSnapshot.docs.first;
      return lastDuesDoc.data()['dues'] ?? 0.0;
    }

    return 0.0;
  }
}
