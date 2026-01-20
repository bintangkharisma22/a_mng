import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../core/session.dart';
import '../models/kondisi_aset.dart';

class KondisiService {
  static const String _baseUrl = Config.baseUrl;

  static Future<List<KondisiAset>> getKondisi() async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/lokasi/kondisi'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => KondisiAset.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat kondisi aset');
    }
  }

  static Future<KondisiAset> create(Map<String, dynamic> body) async {
    final token = await SessionManager.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/lokasi/kondisi'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return KondisiAset.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal menambah kondisi aset');
    }
  }

  static Future<KondisiAset> update(int id, Map<String, dynamic> body) async {
    final token = await SessionManager.getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/api/lokasi/kondisi/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return KondisiAset.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal mengupdate kondisi aset');
    }
  }

  static Future<void> delete(int id) async {
    final token = await SessionManager.getToken();

    final response = await http.delete(
      Uri.parse('$_baseUrl/api/lokasi/kondisi/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus kondisi aset');
    }
  }
}
