import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../core/session.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class LaporanMaintenanceService {
  static const String _baseUrl = Config.baseUrl;

  static Future<List<dynamic>> getLaporan({
    String? kategoriId,
    String? status,
  }) async {
    final token = await SessionManager.getToken();

    final query = <String, String>{};

    if (kategoriId != null) query['kategori_id'] = kategoriId;
    if (status != null) query['status'] = status;

    final uri = Uri.parse(
      '$_baseUrl/api/laporan/maintenance',
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
      throw Exception('Gagal memuat laporan maintenance');
    }
  }

  static Future<void> exportExcel({String? kategoriId, String? status}) async {
    final token = await SessionManager.getToken();

    final query = <String, String>{};
    if (kategoriId != null) query['kategori_id'] = kategoriId;
    if (status != null) query['status'] = status;

    final uri = Uri.parse(
      '$_baseUrl/api/laporan/export/maintenance',
    ).replace(queryParameters: query);

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Gagal export laporan maintenance');
    }

    final directory = await getApplicationDocumentsDirectory();
    final filePath =
        '${directory.path}/laporan_maintenance_${DateTime.now().millisecondsSinceEpoch}.xlsx';

    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    await OpenFilex.open(filePath);
  }
}
