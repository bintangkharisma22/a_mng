import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/session.dart';

class DashboardService {
  static const baseUrl = 'http://localhost:3000/api/dashboard';

  static Future<Map<String, dynamic>> getStats() async {
    final token = await SessionManager.getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/stats'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    throw Exception('Gagal mengambil statistik');
  }

  static Future<Map<String, dynamic>> getKondisiAset() async {
    final token = await SessionManager.getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/kondisi-aset'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else if (res.statusCode == 304) {
      return {};
    }
    throw Exception('Gagal mengambil kondisi aset');
  }
}
