class KondisiAset {
  final String id;
  final String nama;
  final String? warnaBadge;

  final DateTime createdAt;
  final DateTime updatedAt;

  KondisiAset({
    required this.id,
    required this.nama,
    this.warnaBadge,
    required this.createdAt,
    required this.updatedAt,
  });

  factory KondisiAset.fromJson(Map<String, dynamic> json) {
    return KondisiAset(
      id: json['id'],
      nama: json['nama'],
      warnaBadge: json['warna_badge'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
