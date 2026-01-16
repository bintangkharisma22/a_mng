class PeminjamanAset {
  final String id;
  final String asetId;
  final String peminjamId;
  final String status;

  PeminjamanAset({
    required this.id,
    required this.asetId,
    required this.peminjamId,
    required this.status,
  });

  factory PeminjamanAset.fromJson(Map<String, dynamic> json) {
    return PeminjamanAset(
      id: json['id'],
      asetId: json['aset_id'],
      peminjamId: json['peminjam_id'],
      status: json['status'],
    );
  }
}
