import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../core/session.dart';
import '../models/aset.dart';
import '../models/riwayat_kondisi_aset.dart';

class AsetDetailService {
  static const String _baseUrl = Config.baseUrl;

  static Future<Aset> getDetailAset(String id) async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/aset/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Aset.fromJson(jsonDecode(response.body));
    }

    throw Exception('Gagal memuat detail aset');
  }

  static Future<List<RiwayatKondisiAset>> getRiwayatKondisi(
    String asetId,
  ) async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/aset/$asetId/riwayat-kondisi'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body);
      return list.map((e) => RiwayatKondisiAset.fromJson(e)).toList();
    }

    throw Exception('Gagal memuat riwayat kondisi aset');
  }
}
