import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:a_mng/models/aset.dart';
import 'package:a_mng/models/riwayat_kondisi_aset.dart';
import 'package:a_mng/services/aset_detail_service.dart';

class AsetDetailPage extends StatefulWidget {
  final String asetId;

  const AsetDetailPage({super.key, required this.asetId});

  @override
  State<AsetDetailPage> createState() => _AsetDetailPageState();
}

class _AsetDetailPageState extends State<AsetDetailPage> {
  late Future<Aset> asetFuture;
  late Future<List<RiwayatKondisiAset>> riwayatFuture;

  @override
  void initState() {
    super.initState();
    asetFuture = AsetDetailService.getDetailAset(widget.asetId);
    riwayatFuture = AsetDetailService.getRiwayatKondisi(widget.asetId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Aset')),
      body: FutureBuilder<Aset>(
        future: asetFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final aset = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _infoCard('Kode Aset', aset.kodeAset),
              _infoCard('Status', aset.status),
              _infoCard('Kategori', aset.kategori.nama),
              _infoCard('Ruangan', aset.ruangan.nama),
              _infoCard('Divisi', aset.divisi.nama),
              _infoCard('Kondisi', aset.kondisi.nama),

              const SizedBox(height: 16),

              if (aset.qrCode != null) _qrSection(aset.qrCode!),

              const SizedBox(height: 24),

              const Text(
                'Riwayat Kondisi Aset',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              FutureBuilder<List<RiwayatKondisiAset>>(
                future: riwayatFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final list = snapshot.data!;

                  if (list.isEmpty) {
                    return const Text(
                      'Belum ada riwayat kondisi',
                      style: TextStyle(color: Colors.grey),
                    );
                  }

                  return Column(children: list.map(_riwayatItem).toList());
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(label),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _qrSection(String qrBase64) {
    final bytes = base64Decode(
      qrBase64.replaceFirst(RegExp(r'data:image\/png;base64,'), ''),
    );

    return Column(
      children: [
        const Text(
          'QR Code Aset',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Image.memory(bytes, width: 180),
      ],
    );
  }

  Widget _riwayatItem(RiwayatKondisiAset item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.history),
        title: Text(item.kondisi?.nama ?? '-'),
        subtitle: Text(item.catatan ?? '-'),
        trailing: Text(
          item.tanggalPerubahan.toIso8601String().substring(0, 10),
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
