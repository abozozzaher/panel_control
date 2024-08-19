class Invoice {
  String invoiceCode;
  String traderCode;
  List<String> documentCodes;
  List<String> scannedData;

  Invoice({
    required this.invoiceCode,
    required this.traderCode,
    required this.documentCodes,
    required this.scannedData,
  });
}
