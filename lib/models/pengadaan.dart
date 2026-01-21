import 'supplier.dart';
import 'pengadaan_detail.dart';

class Pengadaan {
  final String id;
  final String kodePengadaan;
  final String? supplierId;
  final String? createdBy;
  final String? approvedBy;

  final DateTime? tanggalPembelian;
  final DateTime? tanggalPengirimanRencana;
  final DateTime? tanggalPengirimanAktual;
  final DateTime? approvedAt;

  final String? status;
  final String? catatan;

  final DateTime createdAt;
  final DateTime updatedAt;

  // Relasi
  final Supplier? supplier;
  final List<PengadaanDetail>? pengadaanDetail;

  Pengadaan({
    required this.id,
    required this.kodePengadaan,
    this.supplierId,
    this.createdBy,
    this.approvedBy,
    this.tanggalPembelian,
    this.tanggalPengirimanRencana,
    this.tanggalPengirimanAktual,
    this.approvedAt,
    this.status,
    this.catatan,
    required this.createdAt,
    required this.updatedAt,
    this.supplier,
    this.pengadaanDetail,
  });

  factory Pengadaan.fromJson(Map<String, dynamic> json) {
    return Pengadaan(
      id: json['id'],
      kodePengadaan: json['kode_pengadaan'],
      supplierId: json['supplier_id'],
      createdBy: json['created_by'],
      approvedBy: json['approved_by'],
      tanggalPembelian: json['tanggal_pembelian'] != null
          ? DateTime.parse(json['tanggal_pembelian'])
          : null,
      tanggalPengirimanRencana: json['tanggal_pengiriman_rencana'] != null
          ? DateTime.parse(json['tanggal_pengiriman_rencana'])
          : null,
      tanggalPengirimanAktual: json['tanggal_pengiriman_aktual'] != null
          ? DateTime.parse(json['tanggal_pengiriman_aktual'])
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      status: json['status'],
      catatan: json['catatan'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      supplier: json['supplier'] != null
          ? Supplier.fromJson(json['supplier'])
          : null,
      pengadaanDetail: json['pengadaan_detail'] != null
          ? (json['pengadaan_detail'] as List)
                .map((e) => PengadaanDetail.fromJson(e))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode_pengadaan': kodePengadaan,
      if (supplierId != null) 'supplier_id': supplierId,
      if (tanggalPembelian != null)
        'tanggal_pembelian': tanggalPembelian!.toIso8601String().split('T')[0],
      if (tanggalPengirimanRencana != null)
        'tanggal_pengiriman_rencana': tanggalPengirimanRencana!
            .toIso8601String()
            .split('T')[0],
      if (tanggalPengirimanAktual != null)
        'tanggal_pengiriman_aktual': tanggalPengirimanAktual!
            .toIso8601String()
            .split('T')[0],
      if (status != null) 'status': status,
      if (catatan != null) 'catatan': catatan,
    };
  }
}
