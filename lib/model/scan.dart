import '../provider/scan_item_provider.dart';

class ScanItemQrModel {
  List<String> scannedData;
  Map<String, dynamic> codeDetails;
  int totalQuantity;
  int totalLength;
  double totalWeight;

  bool isProcessing;

  ScanItemQrModel({
    this.scannedData = const [],
    this.codeDetails = const {},
    this.totalQuantity = 0,
    this.totalLength = 0,
    this.totalWeight = 0.0,
    this.isProcessing = false,
  });

  factory ScanItemQrModel.fromProvider(ScanItemProvider provider) {
    return ScanItemQrModel(
      scannedData: provider.scannedData,
      codeDetails: provider.codeDetails,
    );
  }
}
