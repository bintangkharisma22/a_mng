import 'kondisi_aset.dart';

class RiwayatKondisiAset {
  final String id;
  final String asetId;
  final String kondisiId;
  final String? catatan;
  final KondisiAset? kondisi;
  final DateTime tanggalPerubahan;

  RiwayatKondisiAset({
    required this.id,
    required this.asetId,
    required this.kondisiId,
    required this.tanggalPerubahan,
    this.catatan,
    this.kondisi,
  });

  factory RiwayatKondisiAset.fromJson(Map<String, dynamic> json) {
    return RiwayatKondisiAset(
      id: json['id'],
      asetId: json['aset_id'],
      kondisiId: json['kondisi_id'],
      catatan: json['catatan'],
      kondisi: json['kondisi'] != null
          ? KondisiAset.fromJson(json['kondisi'])
          : null,
      tanggalPerubahan: DateTime.parse(json['tanggal_perubahan']),
    );
  }
}
