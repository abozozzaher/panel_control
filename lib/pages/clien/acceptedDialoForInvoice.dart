import 'package:flutter/material.dart';

import '../../data/data_lists.dart';
import '../../generated/l10n.dart';

class AcceptedDialo extends StatelessWidget {
  final DataLists dataLists = DataLists();

  AcceptedDialo({super.key});

  @override
  Widget build(BuildContext context) {
    //  final invoiceProvider = Provider.of<InvoiceProvider>(context);
// Fetch the cached data using the provided docId

    return AlertDialog(
      title: Text('${S().confirm}   ${S().item}', textAlign: TextAlign.center),
      content: const SizedBox(
        width: 500,
        height: 400,
        child: SingleChildScrollView(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: []),
        ),
      ),
      actions: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S().cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S().save_and_send_data),
            ),
          ],
        ),
      ],
    );
  }
}
