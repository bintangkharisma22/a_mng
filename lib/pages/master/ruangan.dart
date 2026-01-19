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
      appBar: AppBar(title: const Text('Ruangan')),

      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showForm(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,

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
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final ruangan = list[i];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    title: Text(
                      ruangan.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Kode: ${ruangan.kode}\n'
                        'Gedung: ${ruangan.gedung ?? '-'} | '
                        'Lantai: ${ruangan.lantai ?? '-'}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),

                    // 🔹 ROLE BASED ACTION
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: isAdmin
                          ? [
                              IconButton(
                                tooltip: 'Edit',
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                                onPressed: () => _showForm(ruangan: ruangan),
                              ),
                              IconButton(
                                tooltip: 'Hapus',
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDelete(ruangan),
                              ),
                            ]
                          : [
                              IconButton(
                                tooltip: 'Detail',
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showDetail(ruangan),
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
              _input(namaController, 'Nama Ruangan'),
              _input(kodeController, 'Kode'),
              _input(gedungController, 'Gedung'),
              _input(lantaiController, 'Lantai'),
              _input(
                kapasitasController,
                'Kapasitas',
                keyboard: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Simpan'),
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
          ),
        ],
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  void _showDetail(Ruangan ruangan) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detail Ruangan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detail('Nama', ruangan.nama),
            _detail('Kode', ruangan.kode),
            _detail('Gedung', ruangan.gedung ?? '-'),
            _detail('Lantai', ruangan.lantai ?? '-'),
            _detail('Kapasitas', '${ruangan.kapasitas ?? '-'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text('$label : $value'),
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
