import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/peminjaman_aset.dart';
import '../../models/kondisi_aset.dart';
import '../../services/peminjaman_service.dart';
import '../../services/kondisi_service.dart';
import '../../core/session.dart';
import '../../core/config.dart';

class PeminjamanDetailPage extends StatefulWidget {
  final String id;
  final bool autoShowReturn;

  const PeminjamanDetailPage({
    super.key,
    required this.id,
    this.autoShowReturn = false,
  });

  @override
  State<PeminjamanDetailPage> createState() => _PeminjamanDetailPageState();
}

class _PeminjamanDetailPageState extends State<PeminjamanDetailPage> {
  PeminjamanAset? peminjaman;
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
      final data = await PeminjamanService.getDetail(widget.id);
      setState(() => peminjaman = data);

      // Auto show return dialog if requested
      if (widget.autoShowReturn &&
          peminjaman?.status == 'dipinjam' &&
          mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showReturnDialog();
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => loading = false);
    }
  }

  bool get isAdmin => role == 'Admin' || role == 'admin';
  bool get isManager => role == 'Manager' || role == 'manager';

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Peminjaman')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (peminjaman == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Peminjaman')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    final p = peminjaman!;
    Color statusColor;

    switch (p.status.toLowerCase()) {
      case 'diajukan':
        statusColor = Colors.orange;
        break;
      case 'dipinjam':
        statusColor = Colors.blue;
        break;
      case 'ditolak':
        statusColor = Colors.red;
        break;
      case 'dikembalikan':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Peminjaman'),
        actions: [
          if (isAdmin && p.status == 'diajukan')
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deletePeminjaman,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: loadData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Status Card
            Card(
              color: statusColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(p.status),
                      color: statusColor,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Peminjaman',
                            style: TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Peminjaman
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Informasi Peminjaman'),
                    const Divider(height: 24),
                    _detailRow('Nama Peminjam', p.namaPeminjam ?? '-'),
                    _detailRow(
                      'Tanggal Pinjam',
                      p.tanggalPinjam != null
                          ? DateFormat(
                              'dd MMMM yyyy',
                              'id_ID',
                            ).format(p.tanggalPinjam!)
                          : '-',
                    ),
                    _detailRow(
                      'Rencana Kembali',
                      p.tanggalKembaliRencana != null
                          ? DateFormat(
                              'dd MMMM yyyy',
                              'id_ID',
                            ).format(p.tanggalKembaliRencana!)
                          : '-',
                    ),
                    if (p.tanggalKembaliAktual != null)
                      _detailRow(
                        'Kembali Aktual',
                        DateFormat(
                          'dd MMMM yyyy',
                          'id_ID',
                        ).format(p.tanggalKembaliAktual!),
                      ),
                    if (p.catatan != null && p.catatan!.isNotEmpty) ...[
                      const Divider(height: 16),
                      const Text(
                        'Catatan',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(p.catatan!),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Aset
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Detail Aset'),
                    const Divider(height: 24),
                    if (p.aset?.gambar != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          '${Config.bucketUrl}/${p.aset!.gambar}',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image, size: 64),
                          ),
                        ),
                      ),
                    if (p.aset?.gambar != null) const SizedBox(height: 16),
                    _detailRow('Kode Aset', p.aset?.kodeAset ?? '-'),
                    _detailRow('Kategori', p.aset?.kategori?.nama ?? '-'),
                    _detailRow('Ruangan', p.aset?.ruangan?.nama ?? '-'),
                    _detailRow('Divisi', p.aset?.divisi?.nama ?? '-'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Kondisi
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Kondisi Aset'),
                    const Divider(height: 24),
                    _detailRow(
                      'Kondisi Sebelum Dipinjam',
                      p.kondisiSebelum?.nama ?? p.aset?.kondisi?.nama ?? '-',
                    ),
                    if (p.kondisiSesudah != null)
                      _detailRow(
                        'Kondisi Setelah Dikembalikan',
                        p.kondisiSesudah!.nama,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            if ((isAdmin || isManager) && p.status == 'diajukan') ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _rejectPeminjaman,
                      icon: const Icon(Icons.close),
                      label: const Text('Tolak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: approvePeminjaman,
                      icon: const Icon(Icons.check),
                      label: const Text('Setujui'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (isAdmin && p.status == 'dipinjam') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _showReturnDialog,
                  icon: const Icon(Icons.keyboard_return),
                  label: const Text('Kembalikan Aset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'diajukan':
        return Icons.pending;
      case 'dipinjam':
        return Icons.shopping_bag;
      case 'ditolak':
        return Icons.cancel;
      case 'dikembalikan':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> approvePeminjaman() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Peminjaman'),
        content: const Text('Yakin ingin menyetujui peminjaman ini?'),
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
      await PeminjamanService.approve(widget.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman berhasil disetujui'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectPeminjaman() async {
    final catatanController = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Tolak Peminjaman'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Yakin ingin menolak peminjaman ini?'),
            const SizedBox(height: 16),
            TextField(
              controller: catatanController,
              decoration: const InputDecoration(
                labelText: 'Alasan penolakan',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await PeminjamanService.reject(
        widget.id,
        catatan: catatanController.text.isNotEmpty
            ? catatanController.text
            : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman ditolak'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showReturnDialog() async {
    final kondisiList = await KondisiService.getKondisi();
    KondisiAset? selectedKondisi;
    final catatanController = TextEditingController();
    if (!mounted) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Kembalikan Aset'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kondisi aset setelah dikembalikan:'),
                const SizedBox(height: 12),
                DropdownButtonFormField<KondisiAset>(
                  initialValue: selectedKondisi,
                  decoration: const InputDecoration(
                    labelText: 'Kondisi Aset',
                    border: OutlineInputBorder(),
                  ),
                  items: kondisiList
                      .map(
                        (k) => DropdownMenuItem(value: k, child: Text(k.nama)),
                      )
                      .toList(),
                  onChanged: (v) {
                    setDialogState(() => selectedKondisi = v);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: catatanController,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: selectedKondisi == null
                  ? null
                  : () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Kembalikan'),
            ),
          ],
        ),
      ),
    );

    if (confirm != true || selectedKondisi == null) return;

    try {
      await PeminjamanService.returnAset(
        widget.id,
        kondisiSesudahId: selectedKondisi!.id,
        catatan: catatanController.text.isNotEmpty
            ? catatanController.text
            : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aset berhasil dikembalikan'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> deletePeminjaman() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Peminjaman'),
        content: const Text('Yakin ingin menghapus peminjaman ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await PeminjamanService.delete(widget.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
