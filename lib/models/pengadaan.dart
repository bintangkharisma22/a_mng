class Pengadaan {
  final String id;
  final String kodePengadaan;
  final String? supplierId;

  final DateTime? tanggalPembelian;
  final DateTime? tanggalPengirimanRencana;
  final DateTime? tanggalPengirimanAktual;

  final String? status;
  final String? catatan;

  final DateTime createdAt;
  final DateTime updatedAt;

  Pengadaan({
    required this.id,
    required this.kodePengadaan,
    this.supplierId,
    this.tanggalPembelian,
    this.tanggalPengirimanRencana,
    this.tanggalPengirimanAktual,
    this.status,
    this.catatan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pengadaan.fromJson(Map<String, dynamic> json) {
    return Pengadaan(
      id: json['id'],
      kodePengadaan: json['kode_pengadaan'],
      supplierId: json['supplier_id'],
      tanggalPembelian: json['tanggal_pembelian'] != null
          ? DateTime.parse(json['tanggal_pembelian'])
          : null,
      tanggalPengirimanRencana: json['tanggal_pengiriman_rencana'] != null
          ? DateTime.parse(json['tanggal_pengiriman_rencana'])
          : null,
      tanggalPengirimanAktual: json['tanggal_pengiriman_aktual'] != null
          ? DateTime.parse(json['tanggal_pengiriman_aktual'])
          : null,
      status: json['status'],
      catatan: json['catatan'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
