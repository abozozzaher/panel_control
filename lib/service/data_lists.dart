// data_lists.dart

// قائمة الأنواع
import 'package:flutter/src/widgets/framework.dart';
import 'package:panel_control/generated/l10n.dart';
import 'package:path/path.dart';

class DataLists {
  List<String> types = [
    'عباية',
    'محجرة',
    'حورانية',
    'سبلة',
    'شنطه',
    'حبل',
    'رزة'
  ];
  List<TypeItem> types2 = [
    TypeItem('عباية', 'robe'),
    TypeItem('محجرة', 'veil'),
    TypeItem('حورانية', 'hourani'),
    // ...
  ];

// قائمة العرض
  List<String> widths = [
    '10',
    '20',
    '25',
    '30',
    '35',
    '40',
    '43',
    '45',
    '50',
  ];

// قائمة الأوزان
  List<String> weights = ['650', '700', '350'];

// قائمة الألوان
  List<String> colors = [
    '3اسود',
    'بني محروق',
    'بني',
    'جملي',
    'حمري',
    'كحلي',
    'عسكري',
    'فضي'
  ];

// قائمة أرقام الغزل
  List<String> yarnNumbers = ['150', '300', '450', '600', '900', '1200'];

// قائمة الشفتات (النوبات)
  List<String> shift = [(S().morning), (S().afternoon), (S().evening)];
// قائمة الكميات
  List<String> quantity = ['10', '20', '35', '50'];

// قائمة الأطوال
  List<String> length = ['25', '35', '50', '70', '100'];
}

// تعريف كلاس TypeItem لتخزين الكلمة الأصلية والكلمة المفتاحية للترجمة
class TypeItem {
  final String original; // الكلمة الأصلية
  final String translationKey; // مفتاح الترجمة

  TypeItem(this.original, this.translationKey);

  // دالة ترجمة تعتمد على S() وتمرر مفتاح الترجمة
  String get translated => _getTranslation();

  // دالة الترجمة بناءً على مفتاح الترجمة (S().key)
  String _getTranslation() {
    switch (translationKey) {
      case 'robe':
        return S().robe; // ترجمة 'عباية'
      case 'veil':
        return S().veil; // ترجمة 'محجرة'
      case 'hourani':
        return S().hourani; // ترجمة 'حورانية'
      default:
        return original; // في حالة عدم وجود ترجمة، تعرض الكلمة الأصلية
    }
  }
}
