// data_lists.dart

// قائمة الأنواع
import 'package:panel_control/generated/l10n.dart';

class DataLists {
  List<List<String>> types = [
    ['Abaya', (S().abaya)],
    ['Mahjara', (S().mahjara)],
    ['Hourani', (S().hourani)],
    ['Sablah', (S().sablah)],
    ['Shanta', (S().shanta)],
    ['Habl', (S().habl)],
    ['Raza', (S().raza)],
  ];

// قائمة العرض
  List<List<String>> widths = [
    ['10', '10'],
    ['20', '20'],
    ['25', '25'],
    ['30', '30'],
    ['35', '35'],
    ['40', '40'],
    ['43', '43'],
    ['45', '45'],
    ['50', '50'],
  ];

// قائمة الأوزان
  List<List<String>> weights = [
    ['650', '650'],
    ['700', '700'],
    ['350', '350'],
  ];

  List<List<String>> yarnNumbers = [
    ['150', '150'],
    ['300', '300'],
    ['450', '450'],
    ['600', '600'],
    ['900', '900'],
    ['1200', '1200'],
  ];

  List<List<String>> quantity = [
    ['10', '10'],
    ['20', '20'],
    ['35', '35'],
    ['50', '50'],
  ];

  List<List<String>> length = [
    ['25', '25'],
    ['35', '35'],
    ['50', '50'],
    ['70', '70'],
    ['100', '100'],
  ];
// قائمة الألوان
  List<List<String>> colors = [
    ['Black', S().black],
    ['Burnt Brown', S().brown_burnt],
    ['Brown', S().brown],
    ['Jamli', S().jamli],
    ['Red', S().red],
    ['Navy Blue', S().navy_blue],
    ['Military', S().military],
    ['Silver', S().silver],
  ];

// قائمة الشفتات (النوبات)
  List<List<String>> shift = [
    ['Morning', S().morning],
    ['Afternoon', S().afternoon],
    ['Evening', S().evening],
  ];
}
