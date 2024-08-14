import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

class ProductModel {
  String? selectedType;
  String? selectedWidth;
  String? selectedWeight;
  String? selectedColor;
  String? selectedYarnNumber;
  String? selectedShift;
  String? selectedQuantity;
  String? selectedLength;
  XFile? selectedImage;
  Uint8List? webImage;
  String? image;
  String productId;

  List<String>? types;
  List<String>? widths;
  List<String>? weights;
  List<String>? colors;
  List<String>? yarnNumbers;
  List<String>? shift;
  List<String>? quantity;
  List<String>? length;

  ProductModel({
    this.selectedType,
    this.selectedWidth,
    this.selectedWeight,
    this.selectedColor,
    this.selectedYarnNumber,
    this.selectedShift,
    this.selectedQuantity,
    this.selectedLength,
    this.selectedImage,
    this.webImage,
    this.image,
    this.productId = '',
    this.types,
    this.widths,
    this.weights,
    this.colors,
    this.yarnNumbers,
    this.shift,
    this.quantity,
    this.length,
  });
}
