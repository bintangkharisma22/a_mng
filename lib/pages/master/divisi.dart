import 'package:flutter/material.dart';
import '../../models/divisi.dart';
import '../../services/divisi_service.dart';
import '../../core/session.dart';

class DivisiPage extends StatefulWidget {
  const DivisiPage({super.key});

  @override
  State<DivisiPage> createState() => _DivisiPageState();
}

class _DivisiPageState extends State<DivisiPage> {
  late Future<List<Divisi>> futureDivisi;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
    _loadRole();
  }

  void _load() {
    futureDivisi = DivisiService.getDivisi();
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
      appBar: AppBar(title: const Text('Divisi')),

      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showForm(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,

      body: RefreshIndicator(
        onRefresh: () async => setState(_load),
        child: FutureBuilder<List<Divisi>>(
          future: futureDivisi,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final list = snapshot.data ?? [];

            if (list.isEmpty) {
              return const Center(child: Text('Belum ada data divisi'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final divisi = list[i];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    title: Text(
                      divisi.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Kode: ${divisi.kode}\n'
                        'Manager ID: ${divisi.managerId ?? '-'}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),

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
                                onPressed: () => _showForm(divisi: divisi),
                              ),
                              IconButton(
                                tooltip: 'Hapus',
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDelete(divisi),
                              ),
                            ]
                          : [
                              IconButton(
                                tooltip: 'Detail',
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showDetail(divisi),
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

  void _showForm({Divisi? divisi}) {
    final namaController = TextEditingController(text: divisi?.nama ?? '');
    final kodeController = TextEditingController(text: divisi?.kode ?? '');
    final managerController = TextEditingController(
      text: divisi?.managerId ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(divisi == null ? 'Tambah Divisi' : 'Edit Divisi'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _input(kodeController, 'Kode'),
              _input(namaController, 'Nama Divisi'),
              _input(managerController, 'Manager ID'),
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
                'kode': kodeController.text,
                'nama': namaController.text,
                'manager_id': managerController.text.isEmpty
                    ? null
                    : managerController.text,
              };

              try {
                if (divisi == null) {
                  await DivisiService.create(body);
                } else {
                  await DivisiService.update(divisi.id, body);
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

  void _showDetail(Divisi divisi) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detail Divisi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detail('Nama', divisi.nama),
            _detail('Kode', divisi.kode),
            _detail('Manager ID', divisi.managerId ?? '-'),
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

  void _confirmDelete(Divisi divisi) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Divisi'),
        content: Text('Yakin hapus divisi "${divisi.nama}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await DivisiService.delete(divisi.id);
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
