// data_lists.dart

// قائمة الأنواع

import '../generated/l10n.dart';

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
    ['750', '750'],
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
    ['06', '06'],
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
  ];
// قائمة الألوان
  List<List<String>> colors = [
    ['Black', S().black],
    ['Dark Brown', S().burnt_brown],
    ['Brown', S().brown],
    ['camli', S().camel],
    ['Falcons Red', S().falcons_red],
    ['Navy Blue', S().navy_blue],
    ['Dark Green', S().dark_green],
    ['Grye', S().grye],
  ];

  List<List<String>> yarnTypes = [
    ['Polyester', S().polyester],
    ['Propylene', S().propylene],
    ['Cotton', S().cotton],
  ];

  List<List<String>> yarnSupplier = [
    ['Kasım', 'Kasım güllü'],
    ['Haron', 'Haron'],
    ['Malih', 'Malih'],
    ['Onder', 'Onder'],
  ];

// قائمة الشفتات (النوبات)

  List<List<String>> shift = [
    ['Morning', S().morning],
    ['Afternoon', S().afternoon],
    ['Evening', S().evening],
  ];
// اسماء الاعمدة في جدول الفاتورة
  List<String> tableHeaders = [
    '#',
    S().type,
    S().color,
    S().yarn_number,
    S().length,
    S().total_weight,
    S().unit,
    S().quantity,
    S().price,
    S().total_price,
  ];

  // اسماء الاعمدة في جدول الفاتورة
  List<String> columnTitles = [
    S().type,
    S().color,
    S().yarn_number,
    S().length,
    '${S().weight} ${S().total}',
    S().unit,
    S().quantity,
    S().price,
    S().total_price,
  ];
  List<String> columnTitlesForProInv = [
    '#',
    S().type,
    S().color,
    S().yarn_number,
    S().length,
    '${S().weight} ${S().total}',
    S().unit,
    S().quantity,
    '${S().price}  ${S().pcs}',
    S().total_price,
    S().delett,
  ];

// قائمة الاشهر لاستيرادها
  List<String> months = [
    // 2024
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

  String translateType(String input) {
    // Find the list that contains the input and get the corresponding translation
    if (allTypes!.contains(input)) {
      int index = allTypes!.indexOf(input);
      return types[index][1]; // Return the translated value
    } else if (allWidths!.contains(input)) {
      int index = allWidths!.indexOf(input);
      return widths[index][1]; // Return the translated value
    } else if (allWeights!.contains(input)) {
      int index = allWeights!.indexOf(input);
      return weights[index][1]; // Return the translated value
    } else if (allYarnNumbers!.contains(input)) {
      int index = allYarnNumbers!.indexOf(input);
      return yarnNumbers[index][1]; // Return the translated value
    } else if (allYarnTypes!.contains(input)) {
      int index = allYarnTypes!.indexOf(input);
      return yarnTypes[index][1]; // Return the translated value
    } else if (allYarnSuppliers!.contains(input)) {
      int index = allYarnSuppliers!.indexOf(input);
      return yarnSupplier[index][1]; // Return the translated value
    } else if (allQuantities!.contains(input)) {
      int index = allQuantities!.indexOf(input);
      return quantity[index][1]; // Return the translated value
    } else if (allLengths!.contains(input)) {
      int index = allLengths!.indexOf(input);
      return length[index][1]; // Return the translated value
    } else if (allColors!.contains(input)) {
      int index = allColors!.indexOf(input);
      return colors[index][1]; // Return the translated value
    }
    return input; // Return the original value if no translation is found
  }
}
