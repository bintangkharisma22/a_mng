import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/session.dart';
import '../core/config.dart';
import '../models/peminjaman_aset.dart';

class PeminjamanService {
  static const String baseUrl = '${Config.baseUrl}/api/peminjaman';

  /// GET all peminjaman
  static Future<List<PeminjamanAset>> getPeminjaman({String? status}) async {
    final token = await SessionManager.getToken();

    final query = <String, String>{};
    if (status != null) query['status'] = status;

    final uri = Uri.parse(baseUrl).replace(queryParameters: query);

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil data peminjaman');
    }

    final List list = json.decode(res.body);
    return list.map((e) => PeminjamanAset.fromJson(e)).toList();
  }

  /// GET peminjaman by user
  static Future<List<PeminjamanAset>> getPeminjamanByUser(String userId) async {
    final token = await SessionManager.getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/user/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil data peminjaman user');
    }

    final List list = json.decode(res.body);
    return list.map((e) => PeminjamanAset.fromJson(e)).toList();
  }

  /// GET detail peminjaman
  static Future<PeminjamanAset> getDetail(String id) async {
    final token = await SessionManager.getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Peminjaman tidak ditemukan');
    }

    return PeminjamanAset.fromJson(json.decode(res.body));
  }

  /// POST create peminjaman (ajukan)
  static Future<PeminjamanAset> create(Map<String, dynamic> data) async {
    final token = await SessionManager.getToken();

    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(data),
    );

    if (res.statusCode != 201) {
      final error = json.decode(res.body);
      throw Exception(error['error'] ?? 'Gagal membuat peminjaman');
    }

    return PeminjamanAset.fromJson(json.decode(res.body));
  }

  /// PATCH approve peminjaman
  static Future<PeminjamanAset> approve(String id, {String? catatan}) async {
    final token = await SessionManager.getToken();

    final body = {if (catatan != null) 'catatan': catatan};

    final res = await http.patch(
      Uri.parse('$baseUrl/$id/approve'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (res.statusCode != 200) {
      final error = json.decode(res.body);
      throw Exception(error['error'] ?? 'Gagal menyetujui peminjaman');
    }

    return PeminjamanAset.fromJson(json.decode(res.body));
  }

  /// PATCH reject peminjaman
  static Future<PeminjamanAset> reject(String id, {String? catatan}) async {
    final token = await SessionManager.getToken();

    final body = {if (catatan != null) 'catatan': catatan};

    final res = await http.patch(
      Uri.parse('$baseUrl/$id/reject'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (res.statusCode != 200) {
      final error = json.decode(res.body);
      throw Exception(error['error'] ?? 'Gagal menolak peminjaman');
    }

    return PeminjamanAset.fromJson(json.decode(res.body));
  }

  /// PUT return peminjaman (pengembalian)
  static Future<PeminjamanAset> returnAset(
    String id, {
    required String kondisiSesudahId,
    String? catatan,
  }) async {
    final token = await SessionManager.getToken();

    final body = {
      'kondisi_sesudah': kondisiSesudahId,
      if (catatan != null) 'catatan': catatan,
    };

    final res = await http.put(
      Uri.parse('$baseUrl/$id/return'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (res.statusCode != 200) {
      final error = json.decode(res.body);
      throw Exception(error['error'] ?? 'Gagal mengembalikan aset');
    }

    return PeminjamanAset.fromJson(json.decode(res.body));
  }

  /// DELETE peminjaman
  static Future<void> delete(String id) async {
    final token = await SessionManager.getToken();

    final res = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      final error = json.decode(res.body);
      throw Exception(error['error'] ?? 'Gagal menghapus peminjaman');
    }
  }
}
