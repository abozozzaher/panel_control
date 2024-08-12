import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../service/scan_item_service.dart';

class ScanItemDialogs {
  bool _isDialogShowing = false;

  final ScanItemService scanItemService = ScanItemService();

  void showDuplicateDialog(BuildContext context, String code) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    scanItemService.playSound('assets/sound/ripiito.mp3');
    print('error duplicate code');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S().duplicate_code),
          content:
              Text('${S().the_code} "$code" ${S().has_already_been_scanned}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isDialogShowing = false;
              },
              child: Text(S().ok),
            ),
          ],
        );
      },
    );
  }

  void showErorrDialog(BuildContext context, String code) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    scanItemService.playSound('assets/sound/error-404.mp3');
    print('error code');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S().error_code),
          content: const Text(
              'Invalid code scanned and removed. رمز غير صالح تم مسحه ضوئيًا وإزالته.'),
          backgroundColor: Colors.redAccent,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isDialogShowing = false;
              },
              child: Text(S().ok),
            ),
          ],
        );
      },
    );
  }

  void showDetailsDialog(
      BuildContext context, String code, Map<String, dynamic>? data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${S().details} $code'),
          content: SingleChildScrollView(
            child: data != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: data.entries.map((entry) {
                      return ListTile(
                        title: Text('${entry.key}: ${entry.value}'),
                      );
                    }).toList(),
                  )
                : Text(S().no_data_found_for_this_code),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S().ok),
            ),
          ],
        );
      },
    );
  }
}
