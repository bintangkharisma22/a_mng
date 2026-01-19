import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../core/session.dart';
import '../models/divisi.dart';

class DivisiService {
  static const String _baseUrl = Config.baseUrl;

  static Future<List<Divisi>> getDivisi() async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/lokasi/divisi'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Divisi.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data divisi');
    }
  }

  static Future<Divisi> create(Map<String, dynamic> body) async {
    final token = await SessionManager.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/lokasi/divisi'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return Divisi.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal menambah divisi');
    }
  }

  static Future<Divisi> update(String id, Map<String, dynamic> body) async {
    final token = await SessionManager.getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/api/lokasi/divisi/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return Divisi.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal update divisi');
    }
  }

  static Future<void> delete(String id) async {
    final token = await SessionManager.getToken();

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/lokasi/divisi/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal hapus divisi');
    }
  }
}
