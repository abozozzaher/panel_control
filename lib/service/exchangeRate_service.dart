import 'dart:convert';

import 'package:http/http.dart' as http;

Future<double?> fetchExchangeRateTR() async {
  final url = Uri.parse(
      'https://api.exchangerate-api.com/v4/latest/USD'); // يمكنك تغيير الـ API هنا حسب رغبتك
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['rates']['TRY']; // جلب سعر الصرف مقابل الليرة التركية
    } else {
      print('Failed to load exchange rate');
      return null;
    }
  } catch (e) {
    print('Error: $e');
    return null;
  }
}
