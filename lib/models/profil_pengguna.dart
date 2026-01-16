class ProfilPengguna {
  final String userId;
  final String? peranId;
  final String? divisiId;
  final bool statusAktif;

  ProfilPengguna({
    required this.userId,
    this.peranId,
    this.divisiId,
    required this.statusAktif,
  });

  factory ProfilPengguna.fromJson(Map<String, dynamic> json) {
    return ProfilPengguna(
      userId: json['user_id'],
      peranId: json['peran_id'],
      divisiId: json['divisi_id'],
      statusAktif: json['status_aktif'],
    );
  }
}
