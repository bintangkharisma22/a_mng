class Barang {
  final String id;
  final String nama;
  final String kode;
  final String? spesifikasi;
  final String? satuan;

  Barang({
    required this.id,
    required this.nama,
    required this.kode,
    this.spesifikasi,
    this.satuan,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      nama: json['nama'],
      kode: json['kode'],
      spesifikasi: json['spesifikasi'],
      satuan: json['satuan'],
    );
  }
}
