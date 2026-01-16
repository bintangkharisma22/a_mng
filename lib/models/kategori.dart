class Kategori {
  final String id;
  final String nama;
  final String kode;

  final DateTime createdAt;
  final DateTime updatedAt;

  Kategori({
    required this.id,
    required this.nama,
    required this.kode,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(
      id: json['id'],
      nama: json['nama'],
      kode: json['kode'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
