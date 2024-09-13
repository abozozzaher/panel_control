import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../../service/scan_item_service.dart';
import '../../service/toasts.dart';

class ScanItemDialogs {
  bool _isDialogShowing = false;

  final ScanItemService scanItemService = ScanItemService();

  void showDuplicateDialog(BuildContext context, String code) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    scanItemService.playSound('assets/sound/ripiito.mp3');
    showToast('error duplicate code');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S().duplicate_code, textAlign: TextAlign.center),
          content: Text(
            '${S().the_code} ${code.split('/').last}\n${S().has_already_been_scanned}',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isDialogShowing = false;
              },
              child: Text(S().ok, textAlign: TextAlign.center),
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
          title: Text(S().error_code, textAlign: TextAlign.center),
          content: Text(S().invalid_code_scanned_and_removed,
              textAlign: TextAlign.center),
          backgroundColor: Colors.redAccent,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isDialogShowing = false;
              },
              child: Text(S().ok, textAlign: TextAlign.center),
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
          title: Text('${S().details} ${code.split('/').last}',
              textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: data != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: data.entries.map((entry) {
                      return ListTile(
                        title: Text('${entry.key}: ${entry.value}',
                            textAlign: TextAlign.center),
                      );
                    }).toList(),
                  )
                : Text(S().no_data_found_for_this_code,
                    textAlign: TextAlign.center),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S().ok, textAlign: TextAlign.center),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> soldOutDialog(
      BuildContext context, List<String> invalidDocuments) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S().invalid_items, textAlign: TextAlign.center),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(S().you_have_some_items_marked_as_sold_out,
                    textAlign: TextAlign.center),
                for (var doc in invalidDocuments)
                  Text(doc.split('/').last, textAlign: TextAlign.center),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Center(child: Text(S().ok)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
