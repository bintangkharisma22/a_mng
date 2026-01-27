import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

import '../core/session.dart';
import '../core/config.dart';
import '../models/aset.dart';
import '../models/riwayat_kondisi_aset.dart';

class AsetService {
  static const String baseUrl = '${Config.baseUrl}/api/aset';

  static Future<List<Aset>> getAset({
    String? kategoriId,
    String? ruanganId,
    String? divisiId,
    String? kondisiId,
    String? status,
    String? search,
    String? pengadaanDetailId,
  }) async {
    final token = await SessionManager.getToken();

    final query = <String, String>{};
    if (kategoriId != null) query['kategori_id'] = kategoriId;
    if (ruanganId != null) query['ruangan_id'] = ruanganId;
    if (divisiId != null) query['divisi_id'] = divisiId;
    if (kondisiId != null) query['kondisi_id'] = kondisiId;
    if (status != null) query['status'] = status;
    if (search != null) query['search'] = search;
    if (pengadaanDetailId != null) {
      query['pengadaan_detail_id'] = pengadaanDetailId;
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: query);

    final res = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil data aset');
    }

    final List list = json.decode(res.body);
    return list.map((e) => Aset.fromJson(e)).toList();
  }

  static Future<Aset> getDetail(String id) async {
    final token = await SessionManager.getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Aset tidak ditemukan');
    }

    return Aset.fromJson(json.decode(res.body));
  }

  static Future<Aset> create(Map<String, dynamic> body, {File? gambar}) async {
    final token = await SessionManager.getToken();

    final request = http.MultipartRequest('POST', Uri.parse(baseUrl));
    request.headers['Authorization'] = 'Bearer $token';

    body.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    if (gambar != null) {
      final mimeType = lookupMimeType(gambar.path) ?? 'image/jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'gambar',
          gambar.path,
          contentType: http.MediaType.parse(mimeType),
        ),
      );
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 201) {
      throw Exception('Gagal menambahkan aset : ${res.body}');
    }

    return Aset.fromJson(json.decode(res.body));
  }

  static Future<Aset> update(String id, Map<String, dynamic> body) async {
    final token = await SessionManager.getToken();

    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(body),
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal update aset');
    }

    return Aset.fromJson(json.decode(res.body));
  }

  static Future<Aset> updateMultipart(
    String id,
    Map<String, dynamic> body, {
    File? gambar,
  }) async {
    final token = await SessionManager.getToken();

    final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/$id'));

    request.headers['Authorization'] = 'Bearer $token';

    body.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    if (gambar != null) {
      final mimeType = lookupMimeType(gambar.path) ?? 'image/jpeg';

      request.files.add(
        await http.MultipartFile.fromPath(
          'gambar',
          gambar.path,
          contentType: http.MediaType.parse(mimeType),
        ),
      );
    }

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);

    if (res.statusCode != 200) {
      throw Exception('Gagal update aset: ${res.body}');
    }

    return Aset.fromJson(json.decode(res.body));
  }

  static Future<void> delete(String id) async {
    final token = await SessionManager.getToken();

    final res = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal hapus aset');
    }
  }

  static Future<List<RiwayatKondisiAset>> getRiwayatKondisi(
    String asetId,
  ) async {
    final token = await SessionManager.getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/$asetId/riwayat-kondisi'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil riwayat kondisi');
    }

    final List list = json.decode(res.body);
    return list.map((e) => RiwayatKondisiAset.fromJson(e)).toList();
  }
}
