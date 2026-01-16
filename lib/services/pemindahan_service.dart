import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/session.dart';
import '../core/config.dart';

class PemindahanService {
  static const String _baseUrl = Config.baseUrl;

  static Future<List<dynamic>> getAllPemindahan() async {
    try {
      final token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/pemindahan'),
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal mengambil data pemindahan');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<List<dynamic>> getPemindahanByAset(String asetId) async {
    try {
      final token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/pemindahan/aset/$asetId'),
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal mengambil data pemindahan untuk aset $asetId');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<Map<String, dynamic>> createPemindahan({
    required String asetId,
    String? keRuanganId,
    String? keDivisiId,
    required String alasan,
  }) async {
    try {
      final token = await SessionManager.getToken();

      final body = {'aset_id': asetId, 'alasan': alasan};

      if (keRuanganId != null) {
        body['ke_ruangan_id'] = keRuanganId;
      }
      if (keDivisiId != null) {
        body['ke_divisi_id'] = keDivisiId;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/pemindahan'),
        headers: {
          'Authorization': 'Bearer $token',
          'content-type': 'application/json',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Gagal membuat pemindahan');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
