class Ruangan {
  final String id;
  final String nama;
  final String kode;
  final String? lantai;
  final String? gedung;
  final int? kapasitas;

  final DateTime createdAt;
  final DateTime updatedAt;

  Ruangan({
    required this.id,
    required this.nama,
    required this.kode,
    this.lantai,
    this.gedung,
    this.kapasitas,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ruangan.fromJson(Map<String, dynamic> json) {
    return Ruangan(
      id: json['id'],
      nama: json['nama'],
      kode: json['kode'],
      lantai: json['lantai'],
      gedung: json['gedung'],
      kapasitas: json['kapasitas'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
