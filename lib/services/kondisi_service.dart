import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../core/session.dart';
import '../models/kondisi_aset.dart';

class KondisiService {
  static const String _baseUrl = Config.baseUrl;

  static Future<List<KondisiAset>> getKondisi() async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/lokasi/kondisi'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => KondisiAset.fromJson(e)).toList();
    } else {
      throw Exception('Gagal memuat kondisi aset');
    }
  }
}
