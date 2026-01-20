import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barang.dart';
import '../core/session.dart';
import '../core/config.dart';

class BarangService {
  static const String _baseUrl = Config.baseUrl;

  static Future<List<Barang>> getBarang() async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/lokasi/barang'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Barang.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data barang');
    }
  }

  static Future<Barang> create(Map<String, dynamic> body) async {
    final token = await SessionManager.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/lokasi/barang'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return Barang.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<Barang> update(String id, Map<String, dynamic> body) async {
    final token = await SessionManager.getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/api/lokasi/barang/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return Barang.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }

  static Future<void> delete(String id) async {
    final token = await SessionManager.getToken();

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/lokasi/barang/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception(jsonDecode(response.body)['error']);
    }
  }
}
