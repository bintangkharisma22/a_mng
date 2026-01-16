class Divisi {
  final String id;
  final String nama;
  final String kode;
  final String? managerId;

  Divisi({
    required this.id,
    required this.nama,
    required this.kode,
    this.managerId,
  });

  factory Divisi.fromJson(Map<String, dynamic> json) {
    return Divisi(
      id: json['id'],
      nama: json['nama'],
      kode: json['kode'],
      managerId: json['manager_id'],
    );
  }
}
