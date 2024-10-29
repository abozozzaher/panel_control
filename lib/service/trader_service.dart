import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/dataBase.dart';

class TraderService {
  final DatabaseHelper databaseHelper = DatabaseHelper();

// لجلب الدين المستحق تم تسجيله فقط في اخر مستند
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
      return (lastDuesDoc.data()['dues'] as num?)?.toDouble() ?? 0.0;
    }

    return 0.0;
  }

// لجلب كل بيانات العميل

  Future<List<Map<String, dynamic>>> fetchAllDues(String codeIdClien) async {
    final traderAccountCollection = FirebaseFirestore.instance
        .collection('cliens')
        .doc(codeIdClien)
        .collection('account');

    final allDataSnapshot = await traderAccountCollection
        .orderBy('createdAt', descending: true)
        .get();

    List<Map<String, dynamic>> allData = allDataSnapshot.docs.map((doc) {
      return doc.data();
    }).toList();

    return allData;
  }
}
