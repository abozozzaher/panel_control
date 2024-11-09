import 'dart:async';
import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
  AnchorElement(
      href:
          'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
    ..setAttribute('download', fileName)
    ..click();
}
