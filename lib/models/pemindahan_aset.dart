import 'aset.dart';
import 'ruangan.dart';
import 'divisi.dart';

class PemindahanAset {
  final String id;
  final String? asetId;
  final String? dariRuanganId;
  final String? keRuanganId;
  final String? dariDivisiId;
  final String? keDivisiId;
  final String? dipindahkanOleh;
  final DateTime? tanggalPemindahan;
  final String? alasan;
  final DateTime? createdAt;

  // Relasi
  final Aset? aset;
  final Ruangan? dariRuangan;
  final Ruangan? keRuangan;
  final Divisi? dariDivisi;
  final Divisi? keDivisi;

  PemindahanAset({
    required this.id,
    this.asetId,
    this.dariRuanganId,
    this.keRuanganId,
    this.dariDivisiId,
    this.keDivisiId,
    this.dipindahkanOleh,
    this.tanggalPemindahan,
    this.alasan,
    this.createdAt,
    this.aset,
    this.dariRuangan,
    this.keRuangan,
    this.dariDivisi,
    this.keDivisi,
  });

  factory PemindahanAset.fromJson(Map<String, dynamic> json) {
    return PemindahanAset(
      id: json['id'],
      asetId: json['aset_id'],
      dariRuanganId: json['dari_ruangan_id'],
      keRuanganId: json['ke_ruangan_id'],
      dariDivisiId: json['dari_divisi_id'],
      keDivisiId: json['ke_divisi_id'],
      dipindahkanOleh: json['dipindahkan_oleh'],
      tanggalPemindahan: json['tanggal_pemindahan'] != null
          ? DateTime.tryParse(json['tanggal_pemindahan'])
          : null,
      alasan: json['alasan'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      aset: json['aset'] != null && json['aset'] is Map
          ? Aset.fromJson(json['aset'])
          : null,
      dariRuangan: json['dari_ruangan'] != null && json['dari_ruangan'] is Map
          ? Ruangan.fromJson(json['dari_ruangan'])
          : null,
      keRuangan: json['ke_ruangan'] != null && json['ke_ruangan'] is Map
          ? Ruangan.fromJson(json['ke_ruangan'])
          : null,
      dariDivisi: json['dari_divisi'] != null && json['dari_divisi'] is Map
          ? Divisi.fromJson(json['dari_divisi'])
          : null,
      keDivisi: json['ke_divisi'] != null && json['ke_divisi'] is Map
          ? Divisi.fromJson(json['ke_divisi'])
          : null,
    );
  }
}
