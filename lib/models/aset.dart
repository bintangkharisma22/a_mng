import 'package:flutter/foundation.dart';

import 'kategori.dart';
import 'ruangan.dart';
import 'divisi.dart';
import 'kondisi_aset.dart';
import 'pengadaan_detail.dart';

class Aset {
  final String id;
  final String? pengadaanDetailId;
  final String? kodeAset;
  final String? nomorSeri;

  final double? hargaPembelian;
  final DateTime? tanggalPenerimaan;
  final DateTime? tanggalAkhirGaransi;

  final String? status;
  final String? qrCode;
  final String? gambar;

  final Kategori? kategori;
  final Ruangan? ruangan;
  final Divisi? divisi;
  final KondisiAset? kondisi;

  final PengadaanDetail? pengadaanDetail;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  Aset({
    required this.id,
    this.pengadaanDetailId,
    this.kodeAset,
    this.nomorSeri,
    this.hargaPembelian,
    this.tanggalPenerimaan,
    this.tanggalAkhirGaransi,
    this.status,
    this.qrCode,
    this.gambar,
    this.kategori,
    this.ruangan,
    this.divisi,
    this.kondisi,
    this.pengadaanDetail,
    this.createdAt,
    this.updatedAt,
  });

  factory Aset.fromJson(Map<String, dynamic> json) {
    try {
      return Aset(
        id: json['id'],
        pengadaanDetailId: json['pengadaan_detail_id'],
        kodeAset: json['kode_aset'],
        nomorSeri: json['nomor_seri'],

        hargaPembelian: json['harga_pembelian'] != null
            ? (json['harga_pembelian'] is num
                  ? (json['harga_pembelian'] as num).toDouble()
                  : double.tryParse(json['harga_pembelian'].toString()))
            : null,

        tanggalPenerimaan: json['tanggal_penerimaan'] != null
            ? DateTime.tryParse(json['tanggal_penerimaan'])
            : null,

        tanggalAkhirGaransi: json['tanggal_akhir_garansi'] != null
            ? DateTime.tryParse(json['tanggal_akhir_garansi'])
            : null,

        status: json['status'],
        qrCode: json['qr_code'],
        gambar: json['gambar'],

        kategori: json['kategori'] != null && json['kategori'] is Map
            ? Kategori.fromJson(json['kategori'])
            : null,

        ruangan: json['ruangan'] != null && json['ruangan'] is Map
            ? Ruangan.fromJson(json['ruangan'])
            : null,

        divisi: json['divisi'] != null && json['divisi'] is Map
            ? Divisi.fromJson(json['divisi'])
            : null,

        kondisi: json['kondisi'] != null && json['kondisi'] is Map
            ? KondisiAset.fromJson(json['kondisi'])
            : null,

        pengadaanDetail:
            json['pengadaan_detail'] != null && json['pengadaan_detail'] is Map
            ? PengadaanDetail.fromJson(
                json['pengadaan_detail'],
                includeNested: true,
              )
            : null,

        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,

        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'])
            : null,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error in Aset.fromJson: $e');
      debugPrint('📦 Problematic JSON: $json');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (pengadaanDetailId != null) 'pengadaan_detail_id': pengadaanDetailId,
      if (kodeAset != null) 'kode_aset': kodeAset,
      if (nomorSeri != null) 'nomor_seri': nomorSeri,
      if (hargaPembelian != null) 'harga_pembelian': hargaPembelian,
      if (tanggalPenerimaan != null)
        'tanggal_penerimaan': tanggalPenerimaan?.toIso8601String(),
      if (tanggalAkhirGaransi != null)
        'tanggal_akhir_garansi': tanggalAkhirGaransi?.toIso8601String(),
      if (status != null) 'status': status,
      if (qrCode != null) 'qr_code': qrCode,
      if (gambar != null) 'gambar': gambar,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
