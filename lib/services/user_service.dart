import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/session.dart';
import '../core/config.dart';
import '../models/user.dart';

class UserService {
  static const baseUrl = '${Config.baseUrl}/api/users';

  // Get all users
  static Future<List<User>> getUsers({
    String? peranId,
    String? divisiId,
    bool? statusAktif,
  }) async {
    final token = await SessionManager.getToken();

    String url = baseUrl;
    List<String> params = [];

    if (peranId != null) params.add('peran_id=$peranId');
    if (divisiId != null) params.add('divisi_id=$divisiId');
    if (statusAktif != null) params.add('status_aktif=$statusAktif');

    if (params.isNotEmpty) {
      url += '?${params.join('&')}';
    }

    final res = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => User.fromJson(json)).toList();
    }
    throw Exception('Gagal mengambil data user');
  }

  // Get user by ID
  static Future<User> getUserById(String id) async {
    final token = await SessionManager.getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    }
    throw Exception('Gagal mengambil detail user');
  }

  // Create user
  static Future<User> createUser({
    required String email,
    required String password,
    required String peranId,
    String? divisiId,
    String? telepon,
    String? alamat,
    String? foto,
    bool statusAktif = true,
  }) async {
    final token = await SessionManager.getToken();

    final res = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'peran_id': peranId,
        'divisi_id': divisiId,
        'telepon': telepon,
        'alamat': alamat,
        'foto': foto,
        'status_aktif': statusAktif,
      }),
    );

    if (res.statusCode == 201) {
      return User.fromJson(jsonDecode(res.body));
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Gagal membuat user');
  }

  // Update user
  static Future<User> updateUser({
    required String id,
    String? email,
    String? password,
    String? peranId,
    String? divisiId,
    String? telepon,
    String? alamat,
    String? foto,
    bool? statusAktif,
  }) async {
    final token = await SessionManager.getToken();

    final Map<String, dynamic> body = {};
    if (email != null) body['email'] = email;
    if (password != null) body['password'] = password;
    if (peranId != null) body['peran_id'] = peranId;
    if (divisiId != null) body['divisi_id'] = divisiId;
    if (telepon != null) body['telepon'] = telepon;
    if (alamat != null) body['alamat'] = alamat;
    if (foto != null) body['foto'] = foto;
    if (statusAktif != null) body['status_aktif'] = statusAktif;

    final res = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    }
    throw Exception(jsonDecode(res.body)['error'] ?? 'Gagal mengupdate user');
  }

  // Delete user (soft delete)
  static Future<void> deleteUser(String id) async {
    final token = await SessionManager.getToken();

    final res = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error'] ?? 'Gagal menghapus user');
    }
  }

  // Hard delete user
  static Future<void> permanentDeleteUser(String id) async {
    final token = await SessionManager.getToken();

    final res = await http.delete(
      Uri.parse('$baseUrl/$id/permanent'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception(
        jsonDecode(res.body)['error'] ?? 'Gagal menghapus user permanen',
      );
    }
  }

  // Reset password
  static Future<void> resetPassword(String id, String newPassword) async {
    final token = await SessionManager.getToken();

    final res = await http.post(
      Uri.parse('$baseUrl/$id/reset-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'new_password': newPassword}),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['error'] ?? 'Gagal reset password');
    }
  }

  // Toggle status
  static Future<void> toggleStatus(String id) async {
    final token = await SessionManager.getToken();

    final res = await http.patch(
      Uri.parse('$baseUrl/$id/toggle-status'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal mengubah status user');
    }
  }
}
