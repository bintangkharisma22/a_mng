import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../core/session.dart';
import '../models/supplier.dart';

class SupplierService {
  static const String _baseUrl = Config.baseUrl;

  static Future<List<Supplier>> getSupplier() async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/lokasi/supplier'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Supplier.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat supplier');
    }
  }

  static Future<Supplier> create(Map<String, dynamic> body) async {
    final token = await SessionManager.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/lokasi/supplier'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return Supplier.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal menambah supplier');
    }
  }
}
