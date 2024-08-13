// data_lists.dart

// قائمة الأنواع
import 'package:panel_control/generated/l10n.dart';

List<String> types = [
  'عباية',
  'محجرة',
  'حورانية',
  'سبلة',
  'شنطه',
  'حبل',
  'رزة'
];

// قائمة العرض
List<String> widths = ['10', '20', '25', '30', '35', '40', '43', '45', '50'];

// قائمة الأوزان
List<String> weights = ['650', '700', '350'];

// قائمة الألوان
List<String> colors = ['color1', 'color2', 'احمر', 'اخرض'];

// قائمة أرقام الغزل
List<String> yarnNumbers = ['150', '300', '450', '600', '900', '1200'];

// قائمة الشفتات (النوبات)
List<String> shift = ['${S().morning}' '${S().afternoon}', '${S().evening}'];

// قائمة الكميات
List<String> quantity = ['20', '35', '50', '10'];

// قائمة الأطوال
List<String> length = ['25', '35', '50', '70', '100', 'غير معين'];

// دالة لاختبار الطباعة
void printLists() {
  print('Types: $types');
  print('Widths: $widths');
  print('Weights: $weights');
  print('Colors: $colors');
  print('Yarn Numbers: $yarnNumbers');
  print('Shift: $shift');
  print('Quantity: $quantity');
  print('Length: $length');
}
