import '../config/api_config.dart';
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

  /// Automatically resolves image URL, converting relative paths or localhost
  /// to the current platform-aware API base and ensuring CORS-compatible /api/storage route.
  String? get displayImageUrl {
    if (productImage == null || productImage!.trim().isEmpty) return null;
    final img = productImage!.trim();

    // If it's a 3rd party web image (Unsplash, imgur, etc.)
    if (img.startsWith('http://') || img.startsWith('https://')) {
      if (!img.contains('127.0.0.1') &&
          !img.contains('localhost') &&
          !img.contains('10.0.2.2')) {
        return img;
      }
    }

    try {
      final baseUri = Uri.parse(ApiConfig.baseUrl);
      final hostPrefix = '${baseUri.scheme}://${baseUri.host}:${baseUri.port}';

      String path = img;
      if (path.startsWith('http://') || path.startsWith('https://')) {
        path = Uri.parse(path).path;
      }

      if (!path.startsWith('/')) {
        path = '/$path';
      }

      // Convert /storage/ to /api/storage/ for full CORS header support
      if (path.startsWith('/storage/')) {
        path = '/api$path';
      }

      return '$hostPrefix$path';
    } catch (_) {
      return img;
    }
  }

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
