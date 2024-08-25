class InvoiceService {
  String generateInvoiceCode() {
    final DateTime now = DateTime.now();
    final String formattedDate =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour}';
    return 'INV-$formattedDate';
  }
}
