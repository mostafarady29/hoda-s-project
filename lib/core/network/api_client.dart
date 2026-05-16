import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  static String get baseUrl {
    // Web
    if (kIsWeb) {
      return "http://127.0.0.1:8000";
    }

    // Android Emulator
    if (Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    }

    // Windows / Desktop / iPhone physical device
    return "http://127.0.0.1:8000";
  }

  static Future<Map<String, dynamic>> getRequest(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "error": "Request failed",
          "status": response.statusCode,
          "body": response.body,
        };
      }
    } catch (e) {
      return {
        "error": "Connection failed",
        "details": e.toString(),
      };
    }
  }
}
