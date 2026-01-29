import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barang.dart';
import '../core/session.dart';
import '../core/config.dart';

class BarangService {
  static const String _baseUrl = '${Config.baseUrl}/api/lokasi/barang';

  static Future<List<Barang>> getBarang() async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Barang.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data barang');
    }
  }

  static Future<List<Barang>> getByPengadaanDetail(
    String pengadaanDetailId,
  ) async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/by-pengadaan-detail/$pengadaanDetailId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Barang.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat barang by pengadaan detail');
    }
  }

  static Future<List<Barang>> getByPgDetail(String pengadaanDetailId) async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/by-pgdid/$pengadaanDetailId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Barang.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat barang by pengadaan detail');
    }
  }

  static Future<Barang> getById(String id) async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return Barang.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Barang tidak ditemukan');
    }
  }

  static Future<Barang> create(Map<String, dynamic> body) async {
    final token = await SessionManager.getToken();

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return Barang.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Gagal membuat barang');
    }
  }

  static Future<Barang> update(String id, Map<String, dynamic> body) async {
    final token = await SessionManager.getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return Barang.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Gagal update barang');
    }
  }

  static Future<void> delete(String id) async {
    final token = await SessionManager.getToken();

    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Gagal hapus barang');
    }
  }
}
