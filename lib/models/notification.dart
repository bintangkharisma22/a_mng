// models/notification.dart
class NotificationModel {
  final String id;
  final String userId;
  final String description;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.description,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      description: json['description'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'description': description,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'data': data,
    };
  }

  // Helper untuk mendapatkan tipe notifikasi
  String get type => data?['type'] ?? 'general';

  // Helper untuk mendapatkan ID terkait
  String? get relatedId {
    if (data == null) return null;
    return data!['pengadaan_id'] ??
        data!['aset_id'] ??
        data!['peminjaman_id'] ??
        data!['maintenance_id'];
  }
}
