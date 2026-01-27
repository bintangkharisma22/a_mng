import 'aset.dart';
import 'kondisi_aset.dart';

class PeminjamanAset {
  final String id;
  final String? asetId;
  final String? peminjamId;
  final String? namaPeminjam;
  final DateTime? tanggalPinjam;
  final DateTime? tanggalKembaliRencana;
  final DateTime? tanggalKembaliAktual;
  final String? kondisiSebelumId;
  final String? kondisiSesudahId;
  final String status; // diajukan, disetujui, ditolak, dipinjam, dikembalikan
  final String? catatan;
  final DateTime createdAt;

  // Relasi
  final Aset? aset;
  final KondisiAset? kondisiSebelum;
  final KondisiAset? kondisiSesudah;

  PeminjamanAset({
    required this.id,
    this.asetId,
    this.peminjamId,
    this.namaPeminjam,
    this.tanggalPinjam,
    this.tanggalKembaliRencana,
    this.tanggalKembaliAktual,
    this.kondisiSebelumId,
    this.kondisiSesudahId,
    required this.status,
    this.catatan,
    required this.createdAt,
    this.aset,
    this.kondisiSebelum,
    this.kondisiSesudah,
  });

  factory PeminjamanAset.fromJson(Map<String, dynamic> json) {
    return PeminjamanAset(
      id: json['id'],
      asetId: json['aset_id'],
      peminjamId: json['peminjam_id'],
      namaPeminjam: json['nama_peminjam'],
      tanggalPinjam: json['tanggal_pinjam'] != null
          ? DateTime.parse(json['tanggal_pinjam'])
          : null,
      tanggalKembaliRencana: json['tanggal_kembali_rencana'] != null
          ? DateTime.parse(json['tanggal_kembali_rencana'])
          : null,
      tanggalKembaliAktual: json['tanggal_kembali_aktual'] != null
          ? DateTime.parse(json['tanggal_kembali_aktual'])
          : null,
      kondisiSebelumId: json['kondisi_sebelum'],
      kondisiSesudahId: json['kondisi_sesudah'],
      status: json['status'] ?? 'diajukan',
      catatan: json['catatan'],
      createdAt: DateTime.parse(json['created_at']),
      aset: json['aset'] != null ? Aset.fromJson(json['aset']) : null,
      kondisiSebelum: json['kondisi_sebelum_detail'] != null
          ? KondisiAset.fromJson(json['kondisi_sebelum_detail'])
          : null,
      kondisiSesudah: json['kondisi_sesudah_detail'] != null
          ? KondisiAset.fromJson(json['kondisi_sesudah_detail'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (asetId != null) 'aset_id': asetId,
      if (peminjamId != null) 'peminjam_id': peminjamId,
      if (namaPeminjam != null) 'nama_peminjam': namaPeminjam,
      if (tanggalPinjam != null)
        'tanggal_pinjam': tanggalPinjam!.toIso8601String().split('T')[0],
      if (tanggalKembaliRencana != null)
        'tanggal_kembali_rencana': tanggalKembaliRencana!
            .toIso8601String()
            .split('T')[0],
      if (kondisiSebelumId != null) 'kondisi_sebelum': kondisiSebelumId,
      'status': status,
      if (catatan != null) 'catatan': catatan,
    };
  }
}
