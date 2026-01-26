import 'kategori.dart';

class BarangTmp {
  final String id;
  final String pengadaanId;
  final String pengadaanDetailId;
  final String? kategoriId;
  final String nama;
  final String kode;
  final String? spesifikasi;
  final String? satuan;
  final int jumlah;
  final double? harga;
  final String status; // draft | siap | dipindah

  final DateTime createdAt;
  final DateTime updatedAt;

  // Relasi
  final Kategori? kategori;

  BarangTmp({
    required this.id,
    required this.pengadaanId,
    required this.pengadaanDetailId,
    this.kategoriId,
    required this.nama,
    required this.kode,
    this.spesifikasi,
    this.satuan,
    required this.jumlah,
    this.harga,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.kategori,
  });

  factory BarangTmp.fromJson(Map<String, dynamic> json) {
    return BarangTmp(
      id: json['id'],
      pengadaanId: json['pengadaan_id'],
      pengadaanDetailId: json['pengadaan_detail_id'],
      kategoriId: json['kategori_id'],
      nama: json['nama'],
      kode: json['kode'],
      spesifikasi: json['spesifikasi'],
      satuan: json['satuan'],
      jumlah: json['jumlah'],
      harga: json['harga'] != null
          ? double.tryParse(json['harga'].toString())
          : null,
      status: json['status'] ?? 'draft',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      kategori: json['kategori'] != null
          ? Kategori.fromJson(json['kategori'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pengadaan_id': pengadaanId,
      'pengadaan_detail_id': pengadaanDetailId,
      if (kategoriId != null) 'kategori_id': kategoriId,
      'nama': nama,
      'kode': kode,
      if (spesifikasi != null) 'spesifikasi': spesifikasi,
      if (satuan != null) 'satuan': satuan,
      'jumlah': jumlah,
      if (harga != null) 'harga': harga,
      'status': status,
    };
  }

  double get totalHarga => (harga ?? 0) * jumlah;
}
