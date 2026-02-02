import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/session.dart';
import '../core/config.dart';
import '../models/notification.dart';

class NotificationService {
  static const baseUrl = '${Config.baseUrl}/api/notifications';

  // Get semua notifikasi
  static Future<List<NotificationModel>> getNotifications({
    bool? isRead,
    int limit = 50,
  }) async {
    final token = await SessionManager.getToken();

    String url = '$baseUrl?limit=$limit';
    if (isRead != null) {
      url += '&is_read=$isRead';
    }

    final res = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => NotificationModel.fromJson(json)).toList();
    }
    throw Exception('Gagal mengambil notifikasi');
  }

  // Get jumlah notifikasi belum dibaca
  static Future<int> getUnreadCount() async {
    final token = await SessionManager.getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/unread/count'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return data['count'] ?? 0;
    }
    throw Exception('Gagal mengambil jumlah notifikasi');
  }

  // Get detail notifikasi
  static Future<NotificationModel> getNotificationDetail(String id) async {
    final token = await SessionManager.getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      return NotificationModel.fromJson(jsonDecode(res.body));
    }
    throw Exception('Gagal mengambil detail notifikasi');
  }

  // Tandai sebagai sudah dibaca (single)
  static Future<void> markAsRead(String id) async {
    final token = await SessionManager.getToken();

    final res = await http.patch(
      Uri.parse('$baseUrl/$id/read'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal menandai notifikasi sebagai dibaca');
    }
  }

  // Tandai semua sebagai sudah dibaca
  static Future<void> markAllAsRead() async {
    final token = await SessionManager.getToken();

    final res = await http.patch(
      Uri.parse('$baseUrl/read/all'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal menandai semua notifikasi sebagai dibaca');
    }
  }

  // Hapus notifikasi
  static Future<void> deleteNotification(String id) async {
    final token = await SessionManager.getToken();

    final res = await http.delete(
      Uri.parse('$baseUrl/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal menghapus notifikasi');
    }
  }

  // Hapus semua notifikasi yang sudah dibaca
  static Future<void> deleteAllRead() async {
    final token = await SessionManager.getToken();

    final res = await http.delete(
      Uri.parse('$baseUrl/read/all'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal menghapus notifikasi');
    }
  }
}
