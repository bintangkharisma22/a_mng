import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../core/session.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class LaporanAsetService {
  static const String _baseUrl = Config.baseUrl;

  static Future<List<dynamic>> getLaporan({
    String? kategoriId,
    String? ruanganId,
    String? divisiId,
    String? kondisiId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await SessionManager.getToken();

    final query = <String, String>{};

    if (kategoriId != null) query['kategori_id'] = kategoriId;
    if (ruanganId != null) query['ruangan_id'] = ruanganId;
    if (divisiId != null) query['divisi_id'] = divisiId;
    if (kondisiId != null) query['kondisi_id'] = kondisiId;
    if (status != null) query['status'] = status;
    if (startDate != null) {
      query['start_date'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      query['end_date'] = endDate.toIso8601String().split('T')[0];
    }

    final uri = Uri.parse(
      '$_baseUrl/api/laporan/aset',
    ).replace(queryParameters: query);

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Gagal memuat laporan aset');
    }
  }

  static Future<void> export({
    String? kategoriId,
    String? ruanganId,
    String? divisiId,
    String? kondisiId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await SessionManager.getToken();

    final query = <String, String>{};

    if (kategoriId != null) query['kategori_id'] = kategoriId;
    if (ruanganId != null) query['ruangan_id'] = ruanganId;
    if (divisiId != null) query['divisi_id'] = divisiId;
    if (kondisiId != null) query['kondisi_id'] = kondisiId;
    if (status != null) query['status'] = status;
    if (startDate != null) {
      query['start_date'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      query['end_date'] = endDate.toIso8601String().split('T')[0];
    }

    final uri = Uri.parse(
      '$_baseUrl/api/laporan/export/aset',
    ).replace(queryParameters: query);

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal export laporan');
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/laporan_aset_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    await OpenFilex.open(filePath);
  }
}
