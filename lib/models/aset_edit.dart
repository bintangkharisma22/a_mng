class AsetEdit {
  final String id;
  final String kodeAset;
  final String? nomorSeri;
  final String pengadaanDetailId;

  final String kategoriId;
  final String? ruanganId;
  final String? divisiId;
  final String kondisiId;

  final double? hargaPembelian;
  final DateTime? tanggalPenerimaan;
  final DateTime? tanggalAkhirGaransi;

  final String status;
  final String? gambar;

  AsetEdit({
    required this.id,
    required this.kodeAset,
    required this.pengadaanDetailId,
    this.nomorSeri,
    required this.kategoriId,
    this.ruanganId,
    this.divisiId,
    required this.kondisiId,
    this.hargaPembelian,
    this.tanggalPenerimaan,
    this.tanggalAkhirGaransi,
    required this.status,
    this.gambar,
  });

  factory AsetEdit.fromJson(Map<String, dynamic> json) {
    return AsetEdit(
      id: json['id'],
      kodeAset: json['kode_aset'],
      pengadaanDetailId: json['pengadaan_detail_id'],
      nomorSeri: json['nomor_seri'],
      kategoriId: json['kategori_id'],
      ruanganId: json['ruangan_id'],
      divisiId: json['divisi_id'],
      kondisiId: json['kondisi_id'],
      hargaPembelian: json['harga_pembelian'] != null
          ? (json['harga_pembelian'] as num).toDouble()
          : null,
      tanggalPenerimaan: json['tanggal_penerimaan'] != null
          ? DateTime.parse(json['tanggal_penerimaan'])
          : null,
      tanggalAkhirGaransi: json['tanggal_akhir_garansi'] != null
          ? DateTime.parse(json['tanggal_akhir_garansi'])
          : null,
      status: json['status'],
      gambar: json['gambar'],
    );
  }

  Map<String, dynamic> toPayload() => {
    "nomor_seri": nomorSeri,
    "kategori_id": kategoriId,
    "ruangan_id": ruanganId,
    "divisi_id": divisiId,
    "kondisi_id": kondisiId,
    "harga_pembelian": hargaPembelian,
    "tanggal_penerimaan": tanggalPenerimaan?.toIso8601String().substring(0, 10),
    "tanggal_akhir_garansi": tanggalAkhirGaransi?.toIso8601String().substring(
      0,
      10,
    ),
    "status": status,
  };
}
