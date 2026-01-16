class Aset {
  final String id;
  final String kodeAset;
  final String? nomorSeri;
  final String? status;

  final Kategori? kategori;
  final Ruangan? ruangan;
  final Divisi? divisi;
  final KondisiAset? kondisi;

  final String? gambar;
  final String? qrCode;

  Aset({
    required this.id,
    required this.kodeAset,
    this.nomorSeri,
    this.status,
    this.kategori,
    this.ruangan,
    this.divisi,
    this.kondisi,
    this.gambar,
    this.qrCode,
  });

  factory Aset.fromJson(Map<String, dynamic> json) {
    return Aset(
      id: json['id'],
      kodeAset: json['kode_aset'],
      nomorSeri: json['nomor_seri'],
      status: json['status'],
      gambar: json['gambar'],
      qrCode: json['qr_code'],
      kategori: json['kategori'] != null
          ? Kategori.fromJson(json['kategori'])
          : null,
      ruangan: json['ruangan'] != null
          ? Ruangan.fromJson(json['ruangan'])
          : null,
      divisi: json['divisi'] != null ? Divisi.fromJson(json['divisi']) : null,
      kondisi: json['kondisi'] != null
          ? KondisiAset.fromJson(json['kondisi'])
          : null,
    );
  }
}
