class Supplier {
  final String id;
  final String nama;
  final String? telepon;
  final String? alamat;

  Supplier({required this.id, required this.nama, this.telepon, this.alamat});

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'],
      nama: json['nama'],
      telepon: json['telepon'],
      alamat: json['alamat'],
    );
  }
}
