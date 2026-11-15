import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Default base URL depending on platform
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api';
    } else if (Platform.isAndroid) {
      // 10.0.2.2 is the special alias to your host loopback interface on Android Emulator
      return 'http://10.0.2.2:8000/api';
    } else {
      // Windows, macOS, Linux, iOS Simulator
      return 'http://127.0.0.1:8000/api';
    }
  }

  // Active base URL (can be changed dynamically in app settings)
  static String baseUrl = defaultBaseUrl;

  static String get productsUrl => '$baseUrl/products';
  static String get categoriesUrl => '$baseUrl/categories';
}
