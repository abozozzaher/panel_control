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
    ['Riza', (S().riza)],
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

  List<List<String>> yarnTypes = [
    ['Polyester', 'يوليستر'],
    ['Propylene', 'بروبلين'],
    ['Cotton', 'قطن'],
  ];

  List<List<String>> yarnSupplier = [
    ['Haron', 'Haron'],
    ['Malih', 'Malih'],
    ['Onder', 'Onder'],
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
    ['BurntـBrown', S().brown_burnt],
    ['Brown', S().brown],
    ['Jamli', S().jamli],
    ['Red', S().red],
    ['NavyـBlue', S().navy_blue],
    ['DarkـGreen', S().dark_green],
    ['Silver', S().silver],
  ];

// قائمة الشفتات (النوبات)

  List<List<String>> shift = [
    ['Morning', S().morning],
    ['Afternoon', S().afternoon],
    ['Evening', S().evening],
  ];
// قائمة الاشهر لاستيرادها
  List<String> months = [
    // 2024
    "2024-08",

    "2024-09", "2024-10", "2024-11", "2024-12",

    // 2025
    "2025-01", "2025-02", "2025-03", "2025-04", "2025-05", "2025-06",
    "2025-07", "2025-08", "2025-09", "2025-10", "2025-11", "2025-12",

    // 2026
    "2026-01", "2026-02", "2026-03", "2026-04", "2026-05", "2026-06",
    "2026-07", "2026-08", "2026-09", "2026-10", "2026-11", "2026-12",

    // 2027
    "2027-01", "2027-02", "2027-03", "2027-04", "2027-05", "2027-06",
    "2027-07", "2027-08", "2027-09", "2027-10", "2027-11", "2027-12",

    // 2028
    "2028-01", "2028-02", "2028-03", "2028-04", "2028-05", "2028-06",
    "2028-07", "2028-08", "2028-09", "2028-10", "2028-11", "2028-12",

    // 2029
    "2029-01", "2029-02", "2029-03", "2029-04", "2029-05", "2029-06",
    "2029-07", "2029-08", "2029-09", "2029-10", "2029-11", "2029-12",

    // 2030
    "2030-01", "2030-02", "2030-03", "2030-04", "2030-05", "2030-06",
    "2030-07", "2030-08", "2030-09", "2030-10", "2030-11", "2030-12",
  ];

  List<String>? allTypes;
  List<String>? allWidths;
  List<String>? allWeights;
  List<String>? allYarnNumbers;
  List<String>? allYarnTypes;
  List<String>? allYarnSuppliers;
  List<String>? allQuantities;
  List<String>? allLengths;
  List<String>? allColors;

  DataLists() {
    allTypes = types.map((item) => item[0]).toList();
    allWidths = widths.map((item) => item[0]).toList();
    allWeights = weights.map((item) => item[0]).toList();
    allYarnNumbers = yarnNumbers.map((item) => item[0]).toList();
    allYarnTypes = yarnTypes.map((item) => item[0]).toList();
    allYarnSuppliers = yarnSupplier.map((item) => item[0]).toList();
    allQuantities = quantity.map((item) => item[0]).toList();
    allLengths = length.map((item) => item[0]).toList();
    allColors = colors.map((item) => item[0]).toList();
  }
}
