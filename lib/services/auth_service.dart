import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/session.dart';
import '../core/config.dart';

class AuthService {
  static const String _baseUrl = Config.baseUrl;
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final token = json['session']['access_token'];
      final role = json['user']['role'];
      await SessionManager.saveSession(token, role);
      return true;
    }

    return false;
  }

  static Future<void> logout(BuildContext context) async {
    await SessionManager.clearSession();
    Navigator.pushReplacementNamed(context, '/login');
  }
}
