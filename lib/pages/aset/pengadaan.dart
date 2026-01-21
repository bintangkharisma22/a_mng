import 'package:flutter/material.dart';
import '../../models/pengadaan.dart';
import '../../services/pengadaan_service.dart';
import '../../core/session.dart';
import 'pengadaan_form.dart';
import 'pengadaan_detail.dart';

class PengadaanPage extends StatefulWidget {
  const PengadaanPage({super.key});

  @override
  State<PengadaanPage> createState() => _PengadaanPageState();
}

class _PengadaanPageState extends State<PengadaanPage> {
  List<Pengadaan> items = [];
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
      final data = await PengadaanService.getPengadaan();
      setState(() => items = data);
    } catch (e) {
      debugPrint('Error: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  bool get isAdmin => role == 'Admin';
  bool get isStaff => role == 'Staff';
  bool get isManager => role == 'Manager';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengadaan Aset')),

      floatingActionButton: (isAdmin || isStaff)
          ? FloatingActionButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PengadaanFormPage()),
                );
                if (result == true) loadData();
              },
              child: const Icon(Icons.add),
            )
          : null,

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text('Belum ada pengadaan'))
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

  Widget _buildCard(Pengadaan p) {
    Color color;
    switch (p.status) {
      case 'diajukan':
        color = Colors.orange;
        break;
      case 'disetujui':
        color = Colors.green;
        break;
      case 'ditolak':
        color = Colors.red;
        break;
      case 'selesai':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Text(
            p.status![0].toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(p.kodePengadaan),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p.supplier != null) Text('Supplier: ${p.supplier!.nama}'),
            const SizedBox(height: 4),
            Text('Status: ${p.status}'),
          ],
        ),

        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PengadaanDetailPage(id: p.id)),
          );
          if (result == true) loadData();
        },

        trailing: buildActions(p),
      ),
    );
  }

  Widget buildActions(Pengadaan p) {
    if (isStaff && p.status == 'diajukan') {
      return IconButton(
        icon: const Icon(Icons.edit, color: Colors.blue),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PengadaanFormPage(pengadaan: p)),
          );
          if (result == true) loadData();
        },
      );
    }

    // ADMIN: edit + delete
    if (isAdmin) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PengadaanFormPage(pengadaan: p),
                ),
              );
              if (result == true) loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => deletePengadaan(p.id),
          ),
        ],
      );
    }

    return const SizedBox();
  }

  Future<void> deletePengadaan(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Pengadaan'),
        content: const Text('Yakin ingin menghapus pengadaan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await PengadaanService.delete(id);
      loadData();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }
}
