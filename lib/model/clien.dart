import 'package:intl/intl.dart';

class ClienData {
  String fullNameArabic;
  String fullNameEnglish;
  String country;
  String state;
  String city;
  String addressArabic;
  String addressEnglish;
  String email;
  String phoneNumber;
  DateTime createdAt;
  String codeIdClien;
  bool? work;

  ClienData(
      {required this.fullNameArabic,
      required this.fullNameEnglish,
      required this.country,
      required this.state,
      required this.city,
      required this.addressArabic,
      required this.addressEnglish,
      required this.email,
      required this.phoneNumber,
      required this.createdAt,
      required this.codeIdClien,
      this.work});

  // تحويل البيانات إلى شكل يمكن رفعه إلى Firebase
  Map<String, dynamic> toMap() {
    String formattedCreatedAt =
        DateFormat('yyyy-MM-dd HH:mm:ss', 'en').format(createdAt);

    return {
      'fullNameArabic': fullNameArabic,
      'fullNameEnglish': fullNameEnglish,
      'country': country,
      'state': state,
      'city': city,
      'addressArabic': addressArabic,
      'addressEnglish': addressEnglish,
      'email': email,
      'phoneNumber': phoneNumber,
      'createdAt': formattedCreatedAt,
      'codeIdClien': codeIdClien,
      'work': work,
    };
  }

  factory ClienData.fromMap(Map<String, dynamic> data) {
    return ClienData(
      fullNameArabic: data['fullNameArabic'] ?? '',
      fullNameEnglish: data['fullNameEnglish'] ?? '',
      country: data['country'] ?? '',
      state: data['state'] ?? '',
      city: data['city'] ?? '',
      addressArabic: data['addressArabic'] ?? '',
      addressEnglish: data['addressEnglish'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      createdAt:
          DateFormat('yyyy-MM-dd HH:mm:ss', 'en').parse(data['createdAt']),
      codeIdClien: data['codeIdClien'],
      work: data['work']!.toString() == 'true' ? true : false,
    );
  }
}
