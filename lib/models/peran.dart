class Peran {
  final String id;
  final String nama;
  final String? namaTampilan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Peran({
    required this.id,
    required this.nama,
    this.namaTampilan,
    this.createdAt,
    this.updatedAt,
  });

  factory Peran.fromJson(Map<String, dynamic> json) {
    return Peran(
      id: json['id'],
      nama: json['nama'],
      namaTampilan: json['nama_tampilan'],
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
      'nama_tampilan': namaTampilan,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Peran && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
