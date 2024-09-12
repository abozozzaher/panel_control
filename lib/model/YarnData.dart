import 'package:intl/intl.dart';

class YarnData {
  String yarnNumber;
  String yarnType;
  String yarnSupplier;
  String color;
  double weight;
  String userId;
  String nameUserAddData;
  DateTime createdAt;
  String codeIdYarn;
  double priceYarn;
  double goodsPrice;

  YarnData(
      {required this.yarnNumber,
      required this.yarnType,
      required this.yarnSupplier,
      required this.color,
      required this.weight,
      required this.userId,
      required this.nameUserAddData,
      required this.createdAt,
      required this.codeIdYarn,
      required this.priceYarn,
      required this.goodsPrice});

  Map<String, dynamic> toMap(double? exchangeRateTR) {
    String formattedCreatedAt =
        DateFormat('yyyy-MM-dd HH:mm:ss', 'en').format(createdAt);

    return {
      'yarn_number': yarnNumber,
      'yarnType': yarnType,
      'yarnSupplier': yarnSupplier,
      'color': color,
      'weight': weight,
      'userId': userId,
      'nameUserAddData': nameUserAddData,
      'createdAt': formattedCreatedAt,
      'code': codeIdYarn,
      'exchangeRate': '$exchangeRateTR TRY',
      'priceYarn': priceYarn,
      'goodsPrice': goodsPrice,
    };
  }
}
