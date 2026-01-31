import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/session.dart';
import '../core/config.dart';
import '../models/pemindahan_aset.dart';

class PemindahanService {
  static const String _baseUrl = '${Config.baseUrl}/api/pemindahan';

  static Future<List<PemindahanAset>> getAllPemindahan() async {
    try {
      final token = await SessionManager.getToken();

      debugPrint('📡 Fetching all pemindahan...');

      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        debugPrint('✅ Fetched ${data.length} pemindahan');

        return data.map((e) => PemindahanAset.fromJson(e)).toList();
      } else {
        throw Exception(
          'Gagal mengambil data pemindahan: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error getAllPemindahan: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<List<PemindahanAset>> getPemindahanByAset(String asetId) async {
    try {
      final token = await SessionManager.getToken();

      debugPrint('📡 Fetching pemindahan for aset: $asetId');

      final response = await http.get(
        Uri.parse('$_baseUrl/aset/$asetId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        debugPrint('✅ Fetched ${data.length} pemindahan for aset');

        return data.map((e) => PemindahanAset.fromJson(e)).toList();
      } else {
        throw Exception(
          'Gagal mengambil data pemindahan aset: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error getPemindahanByAset: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<PemindahanAset> createPemindahan({
    required String asetId,
    String? keRuanganId,
    String? keDivisiId,
    String? alasan,
  }) async {
    try {
      final token = await SessionManager.getToken();

      if (keRuanganId == null && keDivisiId == null) {
        throw Exception(
          'Minimal salah satu dari ruangan atau divisi harus dipilih',
        );
      }

      final body = {
        'aset_id': asetId,
        if (keRuanganId != null) 'ke_ruangan_id': keRuanganId,
        if (keDivisiId != null) 'ke_divisi_id': keDivisiId,
        if (alasan != null && alasan.isNotEmpty) 'alasan': alasan,
      };

      debugPrint('📤 Creating pemindahan: $body');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 201) {
        debugPrint('✅ Pemindahan created successfully');
        return PemindahanAset.fromJson(json.decode(response.body));
      } else {
        final errorMsg = json.decode(response.body)['error'] ?? 'Unknown error';
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ Error createPemindahan: $e');
      throw Exception('Gagal membuat pemindahan: $e');
    }
  }

  static Future<PemindahanAset> updatePemindahan({
    required String id,
    String? keRuanganId,
    String? keDivisiId,
    String? alasan,
  }) async {
    try {
      final token = await SessionManager.getToken();

      if (keRuanganId == null && keDivisiId == null && alasan == null) {
        throw Exception('Tidak ada perubahan data');
      }

      final body = {
        if (keRuanganId != null) 'ke_ruangan_id': keRuanganId,
        if (keDivisiId != null) 'ke_divisi_id': keDivisiId,
        if (alasan != null) 'alasan': alasan,
      };

      debugPrint('📤 Updating pemindahan $id: $body');

      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        return PemindahanAset.fromJson(json.decode(response.body));
      } else {
        final errorMsg = json.decode(response.body)['error'] ?? 'Unknown error';
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ Error updatePemindahan: $e');
      throw Exception('Gagal update pemindahan: $e');
    }
  }

  static Future<void> deletePemindahan(String id) async {
    try {
      final token = await SessionManager.getToken();

      debugPrint('📤 Deleting pemindahan $id');

      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 204) {
        debugPrint('✅ Pemindahan deleted successfully');
      } else {
        final errorMsg = json.decode(response.body)['error'] ?? 'Unknown error';
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ Error deletePemindahan: $e');
      throw Exception('Gagal menghapus pemindahan: $e');
    }
  }
}
