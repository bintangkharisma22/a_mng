import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config.dart';
import '../models/peran.dart';
import '../core/session.dart';

class PeranService {
  static const _baseUrl = '${Config.baseUrl}/api/peran';

  static Future<List<Peran>> getPeranList() async {
    final token = await SessionManager.getToken();

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Peran.fromJson(e)).toList();
    } else {
      throw Exception('Gagal mengambil data peran');
    }
  }
}
