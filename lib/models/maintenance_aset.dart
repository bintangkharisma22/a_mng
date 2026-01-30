import 'aset.dart';

class MaintenanceAset {
  final String id;
  final String? asetId;
  final String? jenisMaintenance;
  final String? teknisi;
  final DateTime? tanggalDijadwalkan;
  final DateTime? tanggalSelesai;
  final double? biaya;
  final String? status;
  final String? catatan;
  final DateTime? createdAt;

  // Relasi
  final Aset? aset;

  MaintenanceAset({
    required this.id,
    this.asetId,
    this.jenisMaintenance,
    this.teknisi,
    this.tanggalDijadwalkan,
    this.tanggalSelesai,
    this.biaya,
    this.status,
    this.catatan,
    this.createdAt,
    this.aset,
  });

  factory MaintenanceAset.fromJson(Map<String, dynamic> json) {
    return MaintenanceAset(
      id: json['id'],
      asetId: json['aset_id'],
      jenisMaintenance: json['jenis_maintenance'],
      teknisi: json['teknisi'],
      tanggalDijadwalkan: json['tanggal_dijadwalkan'] != null
          ? DateTime.tryParse(json['tanggal_dijadwalkan'])
          : null,
      tanggalSelesai: json['tanggal_selesai'] != null
          ? DateTime.tryParse(json['tanggal_selesai'])
          : null,
      biaya: json['biaya'] != null
          ? (json['biaya'] is num
                ? (json['biaya'] as num).toDouble()
                : double.tryParse(json['biaya'].toString()))
          : null,
      status: json['status'],
      catatan: json['catatan'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      aset: json['aset'] != null && json['aset'] is Map
          ? Aset.fromJson(json['aset'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (asetId != null) 'aset_id': asetId,
      if (jenisMaintenance != null) 'jenis_maintenance': jenisMaintenance,
      if (teknisi != null) 'teknisi': teknisi,
      if (tanggalDijadwalkan != null)
        'tanggal_dijadwalkan': tanggalDijadwalkan!.toIso8601String().split(
          'T',
        )[0],
      if (tanggalSelesai != null)
        'tanggal_selesai': tanggalSelesai!.toIso8601String().split('T')[0],
      if (biaya != null) 'biaya': biaya,
      if (status != null) 'status': status,
      if (catatan != null) 'catatan': catatan,
    };
  }
}
