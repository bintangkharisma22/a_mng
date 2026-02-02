import 'peran.dart';
import 'divisi.dart';

class User {
  final String userId;
  final String? email;
  final Peran? peran;
  final Divisi? divisi;
  final String? telepon;
  final String? alamat;
  final String? foto;
  final bool statusAktif;
  final DateTime? emailConfirmedAt;
  final DateTime? lastSignInAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.userId,
    this.email,
    this.peran,
    this.divisi,
    this.telepon,
    this.alamat,
    this.foto,
    required this.statusAktif,
    this.emailConfirmedAt,
    this.lastSignInAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      email: json['email'],
      peran: json['peran'] != null ? Peran.fromJson(json['peran']) : null,
      divisi: json['divisi'] != null ? Divisi.fromJson(json['divisi']) : null,
      telepon: json['telepon'],
      alamat: json['alamat'],
      foto: json['foto'],
      statusAktif: json['status_aktif'] ?? true,
      emailConfirmedAt: json['email_confirmed_at'] != null
          ? DateTime.parse(json['email_confirmed_at'])
          : null,
      lastSignInAt: json['last_sign_in_at'] != null
          ? DateTime.parse(json['last_sign_in_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'peran_id': peran?.id,
      'divisi_id': divisi?.id,
      'telepon': telepon,
      'alamat': alamat,
      'foto': foto,
      'status_aktif': statusAktif,
    };
  }
}
