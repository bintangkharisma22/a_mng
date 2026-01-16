class Kategori {
  final String id;
  final String nama;
  final String kode;

  Kategori({required this.id, required this.nama, required this.kode});

  factory Kategori.fromJson(Map<String, dynamic> json) {
    return Kategori(id: json['id'], nama: json['nama'], kode: json['kode']);
  }
}
