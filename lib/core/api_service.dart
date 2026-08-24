import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    } else {
      return 'http://10.0.2.2:5000/api';
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        if (data['token'] != null) {
          await prefs.setString('token', data['token']);
        }
        if (data['user'] != null) {
          await prefs.setString('user', jsonEncode(data['user']));
        }
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] is List
              ? (data['message'] as List).join(', ')
              : data['message'] ?? 'Invalid credentials',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server: $e'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String nationalId,
    required String address,
    required String phone,
    required String email,
    required String password,
    String? avatarUrl,
  }) async {
    final url = Uri.parse('$baseUrl/auth/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': firstName,
          'lastName': lastName,
          'nationalId': nationalId,
          'address': address,
          'phone': phone,
          'email': email,
          'password': password,
          'avatarUrl': avatarUrl ?? '',
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        if (data['token'] != null) {
          await prefs.setString('token', data['token']);
        }
        if (data['user'] != null) {
          await prefs.setString('user', jsonEncode(data['user']));
        }
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] is List
              ? (data['message'] as List).join(', ')
              : data['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Cannot connect to server: $e'};
    }
  }
}