import 'dart:convert';
import 'package:http/http.dart' as http;

import '../core/session.dart';
import '../core/config.dart';
import '../models/pengadaan.dart';
import '../models/pengadaan_detail.dart';

class PengadaanService {
  static const String baseUrl = '${Config.baseUrl}/api/pengadaan';

  static Future<List<Pengadaan>> getPengadaan({
    String? status,
    String? supplierId,
  }) async {
    final token = await SessionManager.getToken();

    final query = <String, String>{};
    if (status != null) query['status'] = status;
    if (supplierId != null) query['supplier_id'] = supplierId;

    final uri = Uri.parse(baseUrl).replace(queryParameters: query);

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil data pengadaan');
    }

    final List list = json.decode(res.body);
    return list.map((e) => Pengadaan.fromJson(e)).toList();
  }

  static Future<Pengadaan> getDetail(String id) async {
    final token = await SessionManager.getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Pengadaan tidak ditemukan');
    }

    return Pengadaan.fromJson(json.decode(res.body));
  }

  static Future<List<PengadaanDetail>> getAvailableForAsset() async {
    final token = await SessionManager.getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/detail/available'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil data pengadaan tersedia');
    }

    final List list = json.decode(res.body);
    return list.map((e) => PengadaanDetail.fromJson(e)).toList();
  }

  static Future<Pengadaan> create({
    required Pengadaan pengadaan,
    required List<PengadaanDetail> detail,
  }) async {
    final token = await SessionManager.getToken();

    final body = {
      'pengadaan': pengadaan.toJson(),
      'detail': detail.map((e) => e.toJson()).toList(),
    };

    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (res.statusCode != 201) {
      final error = json.decode(res.body);
      throw Exception(error['error'] ?? 'Gagal membuat pengadaan');
    }

    return Pengadaan.fromJson(json.decode(res.body));
  }

  static Future<Pengadaan> update(String id, Map<String, dynamic> data) async {
    final token = await SessionManager.getToken();

    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (res.statusCode != 200) {
      final error = json.decode(res.body);
      throw Exception(error['error'] ?? 'Gagal update pengadaan');
    }

    return Pengadaan.fromJson(json.decode(res.body));
  }

  static Future<Pengadaan> updateStatus(
    String id, {
    required String status,
    String? catatan,
  }) async {
    final token = await SessionManager.getToken();

    final body = {'status': status, if (catatan != null) 'catatan': catatan};

    final res = await http.patch(
      Uri.parse('$baseUrl/$id/status'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (res.statusCode != 200) {
      final error = json.decode(res.body);
      throw Exception(error['error'] ?? 'Gagal update status');
    }

    return Pengadaan.fromJson(json.decode(res.body));
  }

  static Future<void> delete(String id) async {
    final token = await SessionManager.getToken();

    final res = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      final error = json.decode(res.body);
      throw Exception(error['error'] ?? 'Gagal hapus pengadaan');
    }
  }
}
