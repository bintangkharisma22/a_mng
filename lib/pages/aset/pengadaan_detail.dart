// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../../models/pengadaan.dart';
import '../../core/session.dart';
import '../../services/pengadaan_service.dart';

class PengadaanDetailPage extends StatefulWidget {
  final String id;
  const PengadaanDetailPage({super.key, required this.id});

  @override
  State<PengadaanDetailPage> createState() => _PengadaanDetailPageState();
}

class _PengadaanDetailPageState extends State<PengadaanDetailPage> {
  Pengadaan? data;
  bool loading = true;
  String? role;

  @override
  void initState() {
    super.initState();
    loadRole();
    loadData();
  }

  Future<void> loadRole() async {
    role = await SessionManager.getUserRole();
    setState(() {});
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    try {
      final result = await PengadaanService.getDetail(widget.id);
      setState(() => data = result);
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  bool get isManager => role == 'Manager';
  bool get isAdmin => role == 'Admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengadaan')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? const Center(child: Text('Data tidak ditemukan'))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final p = data!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoCard(p),
        const SizedBox(height: 16),
        _detailBarang(p),
        const SizedBox(height: 24),
        if ((isManager || isAdmin) && p.status == 'diajukan')
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Setujui'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () => updateStatus('disetujui'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Tolak'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () => updateStatus('ditolak'),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _infoCard(Pengadaan p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kode: ${p.kodePengadaan}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (p.supplier != null) Text('Supplier: ${p.supplier!.nama}'),
            const SizedBox(height: 8),
            Text('Status: ${p.status}'),
            if (p.catatan != null) ...[
              const SizedBox(height: 8),
              Text('Catatan: ${p.catatan}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _detailBarang(Pengadaan p) {
    final details = p.pengadaanDetail ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Barang',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),

            if (details.isEmpty)
              const Text('Tidak ada detail barang')
            else
              ...details.map((d) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(d.barang?.nama ?? '-'),
                  subtitle: Text('Jumlah: ${d.jumlah}'),
                  trailing: d.hargaSatuan != null
                      ? Text('Rp ${d.hargaSatuan}')
                      : const Text('-'),
                );
              }),
          ],
        ),
      ),
    );
  }

  Future<void> updateStatus(String status) async {
    try {
      await PengadaanService.updateStatus(widget.id, status: status);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }
}
