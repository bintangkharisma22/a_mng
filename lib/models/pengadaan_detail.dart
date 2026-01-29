import 'barang_tmp.dart';
import 'barang.dart';
import 'pengadaan.dart';

class PengadaanDetail {
  final String id;
  final String? pengadaanId;
  final double? hargaSatuan;
  final String? catatan;
  final String? kodePengadaan;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  // Relasi
  final List<BarangTmp>? barangTmp;
  final List<Barang>? barang;
  final Pengadaan? pengadaan;

  PengadaanDetail({
    required this.id,
    this.pengadaanId,
    this.hargaSatuan,
    this.catatan,
    this.createdAt,
    this.updatedAt,
    this.barangTmp,
    this.barang,
    this.pengadaan,
    this.kodePengadaan,
  });

  factory PengadaanDetail.fromJson(
    Map<String, dynamic> json, {
    bool includeNested = false,
  }) {
    return PengadaanDetail(
      id: json['id'],
      pengadaanId: json['pengadaan_id'],
      kodePengadaan: json['kode_pengadaan'],
      hargaSatuan: json['harga_satuan'] != null
          ? double.tryParse(json['harga_satuan'].toString())
          : null,
      catatan: json['catatan'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      barangTmp: json['barang_tmp'] != null
          ? (json['barang_tmp'] as List)
                .map((e) => BarangTmp.fromJson(e))
                .toList()
          : null,
      barang: json['barang'] != null
          ? (json['barang'] as List).map((e) => Barang.fromJson(e)).toList()
          : null,
      pengadaan: includeNested && json['pengadaan'] != null
          ? Pengadaan.fromJson(json['pengadaan'], includeDetails: false)
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      if (pengadaan != null) 'pengadaan': pengadaan?.toJson(),
      if (pengadaanId != null) 'pengadaan_id': pengadaanId,
      if (hargaSatuan != null) 'harga_satuan': hargaSatuan,
      if (catatan != null) 'catatan': catatan,
      if (kodePengadaan != null) 'kode_pengadaan': kodePengadaan,
    };
  }

  double get totalHargaBarangTmp {
    if (barangTmp == null || barangTmp!.isEmpty) return 0;
    return barangTmp!.fold(0, (sum, item) => sum + item.totalHarga);
  }

  int get totalJumlahBarangTmp {
    if (barangTmp == null || barangTmp!.isEmpty) return 0;
    return barangTmp!.fold(0, (sum, item) => sum + item.jumlah);
  }
}
