import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../config/api_config.dart';
import '../models/category.dart';
import '../models/product.dart';

class ApiService {
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 1. Get all products (with optional search and category filter)
  Future<List<Product>> getProducts({String? search, int? categoryId}) async {
    try {
      String url = ApiConfig.productsUrl;
      final List<String> queryParams = [];

      if (search != null && search.trim().isNotEmpty) {
        queryParams.add('search=${Uri.encodeComponent(search.trim())}');
      }
      if (categoryId != null && categoryId > 0) {
        queryParams.add('category_id=$categoryId');
      }
      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> list = jsonResponse['data'] ?? [];
        return list.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // 2. Get single product by ID
  Future<Product> getProductById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.productsUrl}/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return Product.fromJson(jsonResponse['data']);
      } else {
        throw Exception('Product not found: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // 3. Create a new product (POST with JSON or Multipart if device image is selected)
  Future<Product> createProduct(Product product, {XFile? imageFile}) async {
    try {
      if (imageFile != null) {
        final uri = Uri.parse(ApiConfig.productsUrl);
        final request = http.MultipartRequest('POST', uri);
        request.headers.addAll({'Accept': 'application/json'});

        product.toJson().forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });

        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'ProductImage',
            bytes,
            filename: imageFile.name,
          ),
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 201 || response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          return Product.fromJson(jsonResponse['data']);
        } else {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          throw Exception(jsonResponse['message'] ?? 'Failed to create product');
        }
      } else {
        final response = await http.post(
          Uri.parse(ApiConfig.productsUrl),
          headers: _headers,
          body: jsonEncode(product.toJson()),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          return Product.fromJson(jsonResponse['data']);
        } else {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          throw Exception(jsonResponse['message'] ?? 'Failed to create product');
        }
      }
    } catch (e) {
      throw Exception('Create error: $e');
    }
  }

  // 4. Update an existing product (PUT with JSON or POST with Multipart if device image is selected)
  Future<Product> updateProduct(int id, Product product, {XFile? imageFile}) async {
    try {
      if (imageFile != null) {
        final uri = Uri.parse('${ApiConfig.productsUrl}/$id');
        final request = http.MultipartRequest('POST', uri);
        request.headers.addAll({'Accept': 'application/json'});
        request.fields['_method'] = 'PUT';

        product.toJson().forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });

        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'ProductImage',
            bytes,
            filename: imageFile.name,
          ),
        );

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          return Product.fromJson(jsonResponse['data']);
        } else {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          throw Exception(jsonResponse['message'] ?? 'Failed to update product');
        }
      } else {
        final response = await http.put(
          Uri.parse('${ApiConfig.productsUrl}/$id'),
          headers: _headers,
          body: jsonEncode(product.toJson()),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          return Product.fromJson(jsonResponse['data']);
        } else {
          final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
          throw Exception(jsonResponse['message'] ?? 'Failed to update product');
        }
      }
    } catch (e) {
      throw Exception('Update error: $e');
    }
  }

  // 5. Delete product (DELETE)
  Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.productsUrl}/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        throw Exception(jsonResponse['message'] ?? 'Failed to delete product');
      }
    } catch (e) {
      throw Exception('Delete error: $e');
    }
  }

  // 6. Get all categories (for dropdown selection)
  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.categoriesUrl),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> list = jsonResponse['data'] ?? [];
        return list.map((item) => Category.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Category network error: $e');
    }
  }
}
