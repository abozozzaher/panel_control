import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/invoice_provider.dart';

class ScannedDataList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // استرجاع مزود البيانات
    final documentsProvider = Provider.of<DocumentProvider>(context);

    List<String> selectedItems = [];

    // عرض العناصر المحددة فقط في ListTile
    return ListView.builder(
      shrinkWrap: true,
      itemCount: selectedItems.length,
      itemBuilder: (context, index) {
        final documentId = selectedItems[index];
        final document = documentsProvider.selectedDocuments
            .firstWhere((document) => document.id == documentId);
        final codeSales = document['codeSales'] ?? 'No Code Sales';
        final scannedData = document['scannedData'] ?? [];

        return ListTile(
          title: Text(codeSales.toString()),
          subtitle: Text(scannedData.join(', ')),
        );
      },
    );
  }
}
