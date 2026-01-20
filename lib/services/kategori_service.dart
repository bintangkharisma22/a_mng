import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../core/session.dart';
import '../models/kategori.dart';

class KategoriService {
  static const String _baseUrl = Config.baseUrl;

  static Future<List<Kategori>> getKategori() async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/lokasi/kategori'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Kategori.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat kategori');
    }
  }

  static Future<Kategori> create(Map<String, dynamic> body) async {
    final token = await SessionManager.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/lokasi/kategori'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return Kategori.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal menambah kategori');
    }
  }

  static Future<Kategori> update(String id, Map<String, dynamic> body) async {
    final token = await SessionManager.getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/api/lokasi/kategori/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return Kategori.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal mengubah kategori');
    }
  }

  static Future<void> delete(String id) async {
    final token = await SessionManager.getToken();

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/lokasi/kategori/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus kategori');
    }
  }
}
