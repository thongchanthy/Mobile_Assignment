import 'category.dart';

class Product {
  final int? productID;
  final String productName;
  final String? description;
  final int categoryID;
  final String? barcode;
  final String? expireDate;
  final int qty;
  final double unitPriceIn;
  final double unitPriceOut;
  final String? productImage;
  final int isDeleted;
  final Category? category;

  Product({
    this.productID,
    required this.productName,
    this.description,
    required this.categoryID,
    this.barcode,
    this.expireDate,
    this.qty = 0,
    this.unitPriceIn = 0.0,
    this.unitPriceOut = 0.0,
    this.productImage,
    this.isDeleted = 0,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productID: json['ProductID'] != null
          ? (json['ProductID'] is int
              ? json['ProductID']
              : int.tryParse(json['ProductID'].toString()))
          : null,
      productName: json['ProductName']?.toString() ?? '',
      description: json['Description']?.toString(),
      categoryID: json['CategoryID'] is int
          ? json['CategoryID']
          : int.parse(json['CategoryID'].toString()),
      barcode: json['Barcode']?.toString(),
      expireDate: json['Expiredate']?.toString(),
      qty: json['Qty'] != null
          ? (json['Qty'] is int ? json['Qty'] : int.tryParse(json['Qty'].toString()) ?? 0)
          : 0,
      unitPriceIn: json['UnitPriceIn'] != null
          ? double.tryParse(json['UnitPriceIn'].toString()) ?? 0.0
          : 0.0,
      unitPriceOut: json['UnitPriceOut'] != null
          ? double.tryParse(json['UnitPriceOut'].toString()) ?? 0.0
          : 0.0,
      productImage: json['ProductImage']?.toString(),
      isDeleted: json['isDeleted'] != null
          ? (json['isDeleted'] is int
              ? json['isDeleted']
              : int.tryParse(json['isDeleted'].toString()) ?? 0)
          : 0,
      category: json['category'] != null && json['category'] is Map<String, dynamic>
          ? Category.fromJson(json['category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'ProductName': productName,
      'Description': description,
      'CategoryID': categoryID,
      'Barcode': barcode,
      'Expiredate': expireDate,
      'Qty': qty,
      'UnitPriceIn': unitPriceIn,
      'UnitPriceOut': unitPriceOut,
      'ProductImage': productImage,
      'isDeleted': isDeleted,
    };
    if (productID != null) {
      data['ProductID'] = productID;
    }
    return data;
  }
}
