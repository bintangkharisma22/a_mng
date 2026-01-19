import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../models/ruangan.dart';
import '../core/session.dart';

class RuanganService {
  static const String _baseUrl = Config.baseUrl;

  static Future<List<Ruangan>> getRuangan() async {
    final token = await SessionManager.getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/lokasi/ruangan'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Ruangan.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load ruangan');
    }
  }

  static Future<Ruangan> create(Map<String, dynamic> body) async {
    final token = await SessionManager.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/lokasi/ruangan'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return Ruangan.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create ruangan');
    }
  }

  static Future<Ruangan> update(String id, Map<String, dynamic> body) async {
    final token = await SessionManager.getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/api/lokasi/ruangan/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return Ruangan.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal update ruangan');
    }
  }

  static Future<void> delete(String id) async {
    final token = await SessionManager.getToken();

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/lokasi/ruangan/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal hapus ruangan');
    }
  }
}
