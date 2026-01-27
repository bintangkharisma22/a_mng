import 'kategori.dart';

class Barang {
  final String id;
  final String nama;
  final String kode;
  final String? spesifikasi;
  final String? satuan;
  final String? kategoriId;
  final String? pengadaanDetailId;
  final String? harga;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Relasi
  final Kategori? kategori;

  Barang({
    required this.id,
    required this.nama,
    required this.kode,
    this.spesifikasi,
    this.satuan,
    this.kategoriId,
    this.pengadaanDetailId,
    required this.createdAt,
    required this.updatedAt,
    this.kategori,
    this.harga,
  });

  factory Barang.fromJson(Map<String, dynamic> json) {
    return Barang(
      id: json['id'],
      nama: json['nama'],
      kode: json['kode'],
      spesifikasi: json['spesifikasi'],
      satuan: json['satuan'],
      kategoriId: json['kategori_id'],
      pengadaanDetailId: json['pengadaan_detail_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      kategori: json['kategori'] != null
          ? Kategori.fromJson(json['kategori'])
          : null,
      harga: json['harga'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'kode': kode,
      if (spesifikasi != null) 'spesifikasi': spesifikasi,
      if (satuan != null) 'satuan': satuan,
      if (kategoriId != null) 'kategori_id': kategoriId,
      if (pengadaanDetailId != null) 'pengadaan_detail_id': pengadaanDetailId,
      if (harga != null) 'harga': harga,
    };
  }
}
