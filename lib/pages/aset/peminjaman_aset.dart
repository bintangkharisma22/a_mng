import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/peminjaman_aset.dart';
import '../../services/peminjaman_service.dart';
import '../../core/session.dart';
import 'peminjaman_form.dart';
import 'peminjaman_detail.dart';

class PeminjamanPage extends StatefulWidget {
  const PeminjamanPage({super.key});

  @override
  State<PeminjamanPage> createState() => _PeminjamanPageState();
}

class _PeminjamanPageState extends State<PeminjamanPage> {
  List<PeminjamanAset> items = [];
  bool loading = true;
  String? role;
  String? filterStatus;

  final List<String> statusList = [
    'Semua',
    'diajukan',
    'dipinjam',
    'ditolak',
    'dikembalikan',
  ];

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
      final data = await PeminjamanService.getPeminjaman(
        status: filterStatus == 'Semua' ? null : filterStatus,
      );
      setState(() => items = data);
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
  bool get isStaff => role == 'Staff' || role == 'staff';
  bool get isManager => role == 'Manager' || role == 'manager';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peminjaman Aset'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                filterStatus = value;
              });
              loadData();
            },
            itemBuilder: (context) => statusList
                .map(
                  (status) => PopupMenuItem(value: status, child: Text(status)),
                )
                .toList(),
          ),
        ],
      ),
      floatingActionButton: (isAdmin || isStaff)
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PeminjamanFormPage()),
                );
                if (result == true) loadData();
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada peminjaman',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final p = items[index];
                  return _buildCard(p);
                },
              ),
            ),
    );
  }

  Widget _buildCard(PeminjamanAset p) {
    Color color;
    IconData icon;

    switch (p.status.toLowerCase()) {
      case 'diajukan':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'dipinjam':
        color = Colors.blue;
        icon = Icons.shopping_bag;
        break;
      case 'ditolak':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'dikembalikan':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PeminjamanDetailPage(id: p.id)),
          );
          if (result == true) loadData();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          p.aset?.kodeAset ?? '-',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      p.status,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _infoItem(
                      Icons.person,
                      'Peminjam',
                      p.namaPeminjam ?? '-',
                    ),
                  ),
                  Expanded(
                    child: _infoItem(
                      Icons.calendar_today,
                      'Tanggal Pinjam',
                      p.tanggalPinjam != null
                          ? DateFormat('dd MMM yyyy').format(p.tanggalPinjam!)
                          : '-',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _infoItem(
                      Icons.event,
                      'Rencana Kembali',
                      p.tanggalKembaliRencana != null
                          ? DateFormat(
                              'dd MMM yyyy',
                            ).format(p.tanggalKembaliRencana!)
                          : '-',
                    ),
                  ),
                  if (p.tanggalKembaliAktual != null)
                    Expanded(
                      child: _infoItem(
                        Icons.check_circle,
                        'Kembali Aktual',
                        DateFormat(
                          'dd MMM yyyy',
                        ).format(p.tanggalKembaliAktual!),
                      ),
                    ),
                ],
              ),
              if ((isAdmin || isManager) && p.status == 'diajukan') ...[
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _rejectPeminjaman(p.id),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Tolak'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _approvePeminjaman(p.id),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Setujui'),
                      ),
                    ),
                  ],
                ),
              ],
              if (isAdmin && p.status == 'dipinjam') ...[
                const Divider(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showReturnDialog(p),
                    icon: const Icon(Icons.keyboard_return, size: 18),
                    label: const Text('Kembalikan Aset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _approvePeminjaman(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
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
      await PeminjamanService.approve(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman berhasil disetujui'),
            backgroundColor: Colors.green,
          ),
        );
      }
      loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectPeminjaman(String id) async {
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
        id,
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
      }
      loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _showReturnDialog(PeminjamanAset peminjaman) async {
    // Navigate to detail page to handle return
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PeminjamanDetailPage(id: peminjaman.id, autoShowReturn: true),
      ),
    );
    if (result == true) loadData();
  }
}
