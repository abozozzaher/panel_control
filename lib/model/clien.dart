class ClienData {
  String clienCode;
  String fullNameArabic;
  String fullNameEnglish;
  String address;
  String phoneNumber;
  DateTime createdAt;
  String codeIdClien;

  ClienData({
    required this.clienCode,
    required this.fullNameArabic,
    required this.fullNameEnglish,
    required this.address,
    required this.phoneNumber,
    required this.createdAt,
    required this.codeIdClien,
  });

  // تحويل البيانات إلى شكل يمكن رفعه إلى Firebase
  Map<String, dynamic> toMap() {
    return {
      'clienCode': clienCode,
      'fullNameArabic': fullNameArabic,
      'fullNameEnglish': fullNameEnglish,
      'address': address,
      'phoneNumber': phoneNumber,
      'createdAt': createdAt.toIso8601String(),
      'code': codeIdClien,
    };
  }
}
