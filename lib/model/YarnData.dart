import 'package:intl/intl.dart';

class YarnData {
  String yarnNumber;
  String yarnType;
  String yarnSupplier;
  String color;
  double weight;
  String userId;
  String firstName;
  String lastName;
  DateTime createdAt;
  String codeIdYarn;

  YarnData({
    required this.yarnNumber,
    required this.yarnType,
    required this.yarnSupplier,
    required this.color,
    required this.weight,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.createdAt,
    required this.codeIdYarn,
  });

  Map<String, dynamic> toMap() {
    String formattedCreatedAt =
        DateFormat('yyyy-MM-dd HH:mm:ss', 'en').format(createdAt);

    return {
      'yarnNumber': yarnNumber,
      'yarnType': yarnType,
      'yarnSupplier': yarnSupplier,
      'color': color,
      'weight': weight,
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'createdAt': formattedCreatedAt,
      'code': codeIdYarn,
      formattedCreatedAt: '+ $codeIdYarn'
    };
  }
}
