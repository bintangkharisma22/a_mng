class MaintenanceAset {
  final String id;
  final String asetId;
  final String? jenisMaintenance;
  final String status;

  MaintenanceAset({
    required this.id,
    required this.asetId,
    this.jenisMaintenance,
    required this.status,
  });

  factory MaintenanceAset.fromJson(Map<String, dynamic> json) {
    return MaintenanceAset(
      id: json['id'],
      asetId: json['aset_id'],
      jenisMaintenance: json['jenis_maintenance'],
      status: json['status'],
    );
  }
}
