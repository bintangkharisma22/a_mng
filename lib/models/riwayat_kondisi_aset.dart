class RiwayatKondisiAset {
  final String id;
  final String asetId;
  final String kondisiId;
  final String? catatan;

  RiwayatKondisiAset({
    required this.id,
    required this.asetId,
    required this.kondisiId,
    this.catatan,
  });

  factory RiwayatKondisiAset.fromJson(Map<String, dynamic> json) {
    return RiwayatKondisiAset(
      id: json['id'],
      asetId: json['aset_id'],
      kondisiId: json['kondisi_id'],
      catatan: json['catatan'],
    );
  }
}
