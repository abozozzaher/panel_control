// دالة لعرض رسالة Toast عند عدم وجود فاتورة
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<bool> isNetworkAvailable() async {
  try {
    await FirebaseFirestore.instance.enableNetwork();
    return true;
  } catch (e) {
    return false;
  }
}

void showToast(String message) {
  Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
}
