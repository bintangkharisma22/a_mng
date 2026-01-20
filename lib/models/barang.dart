class Barang {
  final String id;
  final String nama;
  final String kode;
  final String? spesifikasi;
  final String? satuan;
  final String? kategoriId;
  final String? kategoriNama;

  final DateTime createdAt;
  final DateTime updatedAt;

  Barang({
    required this.id,
    required this.nama,
    required this.kode,
    this.spesifikasi,
    this.satuan,
    this.kategoriId,
    this.kategoriNama,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      nama: json['nama'],
      kode: json['kode'],
      spesifikasi: json['spesifikasi'],
      satuan: json['satuan'],
      kategoriId: json['kategori_id'],
      kategoriNama: json['kategori']?['nama'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
