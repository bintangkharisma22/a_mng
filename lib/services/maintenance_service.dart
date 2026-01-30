import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../core/session.dart';
import '../core/config.dart';
import '../models/maintenance_aset.dart';

class MaintenanceService {
  static const String _baseUrl = '${Config.baseUrl}/api/maintenance';

  static Future<List<MaintenanceAset>> getAll({
    String? asetId,
    String? status,
    String? jenisMaintenance,
  }) async {
    try {
      final token = await SessionManager.getToken();

      final query = <String, String>{};
      if (asetId != null) query['aset_id'] = asetId;
      if (status != null) query['status'] = status;
      if (jenisMaintenance != null) {
        query['jenis_maintenance'] = jenisMaintenance;
      }

      final uri = Uri.parse(_baseUrl).replace(queryParameters: query);

      debugPrint('📡 Fetching maintenance from: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        debugPrint('✅ Fetched ${data.length} maintenance records');

        return data.map((e) => MaintenanceAset.fromJson(e)).toList();
      } else {
        throw Exception(
          'Gagal mengambil data maintenance: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error getAll: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<MaintenanceAset> getDetail(String id) async {
    try {
      final token = await SessionManager.getToken();

      debugPrint('📡 Fetching maintenance detail for ID: $id');

      final response = await http.get(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Maintenance detail fetched');
        return MaintenanceAset.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Gagal mengambil detail maintenance: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error getDetail: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  static Future<MaintenanceAset> create(MaintenanceAset maintenance) async {
    try {
      final token = await SessionManager.getToken();

      debugPrint('📤 Creating maintenance: ${maintenance.toJson()}');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(maintenance.toJson()),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 201) {
        debugPrint('✅ Maintenance created successfully');
        return MaintenanceAset.fromJson(json.decode(response.body));
      } else {
        final errorMsg = json.decode(response.body)['error'] ?? 'Unknown error';
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ Error create: $e');
      throw Exception('Gagal membuat maintenance: $e');
    }
  }

  static Future<MaintenanceAset> update(
    String id,
    MaintenanceAset maintenance,
  ) async {
    try {
      final token = await SessionManager.getToken();

      debugPrint('📤 Updating maintenance $id: ${maintenance.toJson()}');

      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(maintenance.toJson()),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Maintenance updated successfully');
        return MaintenanceAset.fromJson(json.decode(response.body));
      } else {
        final errorMsg = json.decode(response.body)['error'] ?? 'Unknown error';
        throw Exception(errorMsg);
      }
    } catch (e) {
      debugPrint('❌ Error update: $e');
      throw Exception('Gagal update maintenance: $e');
    }
  }

  static Future<void> delete(String id) async {
    try {
      final token = await SessionManager.getToken();

      debugPrint('🗑️ Deleting maintenance ID: $id');

      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('✅ Maintenance deleted successfully');
      } else {
        throw Exception('Gagal menghapus maintenance: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error delete: $e');
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
