import 'package:flutter/material.dart';
import '../../models/ruangan.dart';
import '../../services/ruangan_service.dart';
import '../../core/session.dart';

class RuanganPage extends StatefulWidget {
  const RuanganPage({super.key});

  @override
  State<RuanganPage> createState() => _RuanganPageState();
}

class _RuanganPageState extends State<RuanganPage> {
  late Future<List<Ruangan>> futureRuangan;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
    _loadRole();
  }

  void _load() {
    futureRuangan = RuanganService.getRuangan();
  }

  void _loadRole() async {
    final role = await SessionManager.getUserRole();
    setState(() {
      isAdmin = role == 'admin';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Master Ruangan')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(_load),
        child: FutureBuilder<List<Ruangan>>(
          future: futureRuangan,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final list = snapshot.data ?? [];

            if (list.isEmpty) {
              return const Center(child: Text('Belum ada data ruangan'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final ruangan = list[i];

                return Card(
                  child: ListTile(
                    title: Text(ruangan.nama),
                    subtitle: Text(
                      'Kode: ${ruangan.kode}\nGedung: ${ruangan.gedung ?? '-'} | Lantai: ${ruangan.lantai ?? '-'}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () => _showForm(ruangan: ruangan),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(ruangan),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showForm({Ruangan? ruangan}) {
    final namaController = TextEditingController(text: ruangan?.nama ?? '');
    final kodeController = TextEditingController(text: ruangan?.kode ?? '');
    final gedungController = TextEditingController(text: ruangan?.gedung ?? '');
    final lantaiController = TextEditingController(text: ruangan?.lantai ?? '');
    final kapasitasController = TextEditingController(
      text: ruangan?.kapasitas?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ruangan == null ? 'Tambah Ruangan' : 'Edit Ruangan'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
              TextField(
                controller: kodeController,
                decoration: const InputDecoration(labelText: 'Kode'),
              ),
              TextField(
                controller: gedungController,
                decoration: const InputDecoration(labelText: 'Gedung'),
              ),
              TextField(
                controller: lantaiController,
                decoration: const InputDecoration(labelText: 'Lantai'),
              ),
              TextField(
                controller: kapasitasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kapasitas'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final body = {
                'nama': namaController.text,
                'kode': kodeController.text,
                'gedung': gedungController.text.isEmpty
                    ? null
                    : gedungController.text,
                'lantai': lantaiController.text.isEmpty
                    ? null
                    : lantaiController.text,
                'kapasitas': kapasitasController.text.isEmpty
                    ? null
                    : int.parse(kapasitasController.text),
              };

              try {
                if (ruangan == null) {
                  await RuanganService.create(body);
                } else {
                  await RuanganService.update(ruangan.id, body);
                }

                Navigator.pop(context);
                setState(_load);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Ruangan ruangan) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Ruangan'),
        content: Text('Yakin hapus ruangan "${ruangan.nama}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await RuanganService.delete(ruangan.id);
                Navigator.pop(context);
                setState(_load);
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
