// دالة لعرض رسالة Toast عند عدم وجود فاتورة
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String message) {
  Fluttertoast.showToast(msg: message, toastLength: Toast.LENGTH_SHORT);
}