import 'kategori.dart';
import 'ruangan.dart';
import 'divisi.dart';
import 'kondisi_aset.dart';

class Aset {
  final String id;
  final String kodeAset;
  final String? nomorSeri;
  final String status;
  final String? qrCode;
  final String? gambar;

  final DateTime createdAt;
  final DateTime updatedAt;

  final Kategori kategori;
  final Ruangan ruangan;
  final Divisi divisi;
  final KondisiAset kondisi;

  Aset({
    required this.id,
    required this.kodeAset,
    required this.status,
    required this.kategori,
    required this.ruangan,
    required this.divisi,
    required this.kondisi,
    required this.createdAt,
    required this.updatedAt,
    this.nomorSeri,
    this.qrCode,
    this.gambar,
  });

  factory Aset.fromJson(Map<String, dynamic> json) {
    return Aset(
      id: json['id'],
      kodeAset: json['kode_aset'],
      nomorSeri: json['nomor_seri'],
      status: json['status'],
      qrCode: json['qr_code'],
      gambar: json['gambar'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      kategori: Kategori.fromJson(json['kategori']),
      ruangan: Ruangan.fromJson(json['ruangan']),
      divisi: Divisi.fromJson(json['divisi']),
      kondisi: KondisiAset.fromJson(json['kondisi']),
    );
  }
}
