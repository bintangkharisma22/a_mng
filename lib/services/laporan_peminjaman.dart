import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../core/session.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class LaporanPeminjamanService {
  static const String _baseUrl = Config.baseUrl;

  static Future<List<dynamic>> getLaporan({
    String? kategoriId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await SessionManager.getToken();

    final query = <String, String>{};

    if (kategoriId != null) query['kategori_id'] = kategoriId;
    if (status != null) query['status'] = status;
    if (startDate != null) {
      query['start_date'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      query['end_date'] = endDate.toIso8601String().split('T')[0];
    }

    final uri = Uri.parse(
      '$_baseUrl/api/laporan/peminjaman',
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
      throw Exception('Gagal memuat laporan peminjaman');
    }
  }

  static Future<void> exportExcel({
    String? kategoriId,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await SessionManager.getToken();

    final query = <String, String>{};

    if (kategoriId != null) query['kategori_id'] = kategoriId;
    if (status != null) query['status'] = status;
    if (startDate != null) {
      query['start_date'] = startDate.toIso8601String().split('T')[0];
    }
    if (endDate != null) {
      query['end_date'] = endDate.toIso8601String().split('T')[0];
    }

    final uri = Uri.parse(
      '$_baseUrl/api/laporan/export/peminjaman',
    ).replace(queryParameters: query);

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal export laporan peminjaman');
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/laporan_peminjaman_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    await OpenFilex.open(filePath);
  }
}
