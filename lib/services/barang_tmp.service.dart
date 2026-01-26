import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/barang_tmp.dart';
import '../core/session.dart';
import '../core/config.dart';

class BarangTmpService {
  static const String _baseUrl = '${Config.baseUrl}/api/lokasi/barang-tmp';

  /// GET barang_tmp by pengadaan_id
  static Future<List<BarangTmp>> getByPengadaanId(String pengadaanId) async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/pengadaan/$pengadaanId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => BarangTmp.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat data barang temporary');
    }
  }

  /// GET barang_tmp by ID
  static Future<BarangTmp> getById(String id) async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return BarangTmp.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Barang temporary tidak ditemukan');
    }
  }

  /// POST create barang_tmp
  static Future<BarangTmp> create(Map<String, dynamic> body) async {
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
      return BarangTmp.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Gagal menambah barang');
    }
  }

  /// PUT update barang_tmp
  static Future<BarangTmp> update(String id, Map<String, dynamic> body) async {
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
      return BarangTmp.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Gagal update barang');
    }
  }

  /// DELETE barang_tmp
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
