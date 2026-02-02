class Divisi {
  final String id;
  final String nama;
  final String kode;
  final String? managerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Divisi({
    required this.id,
    required this.nama,
    required this.kode,
    this.managerId,
    this.createdAt,
    this.updatedAt,
  });

  factory Divisi.fromJson(Map<String, dynamic> json) {
    return Divisi(
      id: json['id'],
      nama: json['nama'],
      kode: json['kode'],
      managerId: json['manager_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'kode': kode,
      'manager_id': managerId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Divisi && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
