import 'kategori.dart';
import 'ruangan.dart';
import 'divisi.dart';
import 'kondisi_aset.dart';
import 'pengadaan_detail.dart';

class Aset {
  final String id;
  final String? pengadaanDetailId;
  final String kodeAset;
  final String? nomorSeri;

  final double? hargaPembelian;
  final DateTime? tanggalPembelian;
  final DateTime? tanggalAkhirGaransi;

  final String? status;
  final String? qrCode;
  final String? gambar;

  final Kategori kategori;
  final Ruangan ruangan;
  final Divisi divisi;
  final KondisiAset kondisi;

  // Relasi ke pengadaan_detail (opsional)
  final PengadaanDetail? pengadaanDetail;

  final DateTime createdAt;
  final DateTime updatedAt;

  Aset({
    required this.id,
    this.pengadaanDetailId,
    required this.kodeAset,
    this.nomorSeri,
    this.hargaPembelian,
    this.tanggalPembelian,
    this.tanggalAkhirGaransi,
    this.status,
    this.qrCode,
    this.gambar,
    required this.kategori,
    required this.ruangan,
    required this.divisi,
    required this.kondisi,
    this.pengadaanDetail,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Aset.fromJson(Map<String, dynamic> json) {
    return Aset(
      id: json['id'],
      pengadaanDetailId: json['pengadaan_detail_id'],
      kodeAset: json['kode_aset'],
      nomorSeri: json['nomor_seri'],
      hargaPembelian: json['harga_pembelian'] != null
          ? double.parse(json['harga_pembelian'].toString())
          : null,
      tanggalPembelian: json['tanggal_pembelian'] != null
          ? DateTime.parse(json['tanggal_pembelian'])
          : null,
      tanggalAkhirGaransi: json['tanggal_akhir_garansi'] != null
          ? DateTime.parse(json['tanggal_akhir_garansi'])
          : null,
      status: json['status'],
      qrCode: json['qr_code'],
      gambar: json['gambar'],
      ruangan: Ruangan.fromJson(json['ruangan']),
      divisi: Divisi.fromJson(json['divisi']),
      kondisi: KondisiAset.fromJson(json['kondisi']),
      kategori: Kategori.fromJson(json['kategori']),
      pengadaanDetail: json['pengadaan_detail'] != null
          ? PengadaanDetail.fromJson(
              json['pengadaan_detail'],
              includeNested: true,
            )
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
