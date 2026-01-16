class Peran {
  final String id;
  final String nama;
  final String? namaTampilan;

  Peran({required this.id, required this.nama, this.namaTampilan});

  factory Peran.fromJson(Map<String, dynamic> json) {
    return Peran(
      id: json['id'],
      nama: json['nama'],
      namaTampilan: json['nama_tampilan'],
    );
  }
}
