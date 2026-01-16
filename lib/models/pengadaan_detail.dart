import 'barang.dart';
import 'pengadaan.dart';

class PengadaanDetail {
  final String id;
  final int jumlah;
  final double? hargaSatuan;

  final Barang? barang;
  final Pengadaan? pengadaan;

  final DateTime createdAt;
  final DateTime updatedAt;

  PengadaanDetail({
    required this.id,
    required this.jumlah,
    this.hargaSatuan,
    this.barang,
    this.pengadaan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PengadaanDetail.fromJson(Map<String, dynamic> json) {
    return PengadaanDetail(
      id: json['id'],
      jumlah: json['jumlah'],
      hargaSatuan: json['harga_satuan'] != null
          ? double.tryParse(json['harga_satuan'].toString())
          : null,
      barang: json['barang'] != null ? Barang.fromJson(json['barang']) : null,
      pengadaan: json['pengadaan'] != null
          ? Pengadaan.fromJson(json['pengadaan'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
