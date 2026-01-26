import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  bool get isManager => role == 'manager';
  bool get isAdmin => role == 'admin';

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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _approvePengadaan(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Tolak'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _updateStatus('ditolak'),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.kodePengadaan,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                _statusChip(p.status ?? 'draft'),
              ],
            ),
            const Divider(height: 24),
            if (p.supplier != null)
              _infoRow(Icons.business, 'Supplier', p.supplier!.nama),
            if (p.tanggalPembelian != null)
              _infoRow(
                Icons.calendar_today,
                'Tanggal Pembelian',
                DateFormat('dd MMMM yyyy', 'id_ID').format(p.tanggalPembelian!),
              ),
            if (p.catatan != null) ...[
              const SizedBox(height: 8),
              _infoRow(Icons.note, 'Catatan', p.catatan!),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Barang',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p.totalBarang} item',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Harga',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${NumberFormat('#,##0', 'id_ID').format(p.totalHarga)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'disetujui':
        color = Colors.green;
        break;
      case 'ditolak':
        color = Colors.red;
        break;
      case 'diajukan':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            if (details.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Tidak ada detail barang'),
                ),
              )
            else
              ...details.expand((detail) {
                // Tampilkan barang_tmp
                final barangTmpList = detail.barangTmp ?? [];
                return barangTmpList.map((tmp) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.grey.shade50,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        tmp.nama,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Kode: ${tmp.kode}'),
                          if (tmp.spesifikasi != null &&
                              tmp.spesifikasi!.isNotEmpty)
                            Text('Spesifikasi: ${tmp.spesifikasi}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Jumlah: ${tmp.jumlah} ${tmp.satuan ?? "pcs"}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (tmp.harga != null)
                                Text(
                                  'Rp ${NumberFormat('#,##0', 'id_ID').format(tmp.harga)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          if (tmp.harga != null) ...[
                            const Divider(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text('Total: '),
                                Text(
                                  'Rp ${NumberFormat('#,##0', 'id_ID').format(tmp.totalHarga)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      trailing: tmp.status != 'draft'
                          ? Chip(
                              label: Text(
                                tmp.status,
                                style: const TextStyle(fontSize: 10),
                              ),
                              padding: EdgeInsets.zero,
                              backgroundColor: tmp.status == 'dipindah'
                                  ? Colors.green.shade100
                                  : Colors.blue.shade100,
                            )
                          : null,
                    ),
                  );
                });
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _approvePengadaan() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Setujui Pengadaan'),
        content: const Text(
          'Barang akan dipindahkan ke master data barang. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await PengadaanService.approve(widget.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengadaan berhasil disetujui'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateStatus(String status) async {
    try {
      await PengadaanService.updateStatus(widget.id, status: status);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }
}
