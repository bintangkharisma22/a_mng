import 'package:flutter/material.dart';
import '../../models/kategori.dart';
import '../../services/kategori_service.dart';
import '../../core/session.dart';

class KategoriPage extends StatefulWidget {
  const KategoriPage({super.key});

  @override
  State<KategoriPage> createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  late Future<List<Kategori>> futureKategori;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
    _loadRole();
  }

  void _load() {
    futureKategori = KategoriService.getKategori();
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
      appBar: AppBar(title: const Text('Master Kategori')),

      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showForm(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,

      body: RefreshIndicator(
        onRefresh: () async => setState(_load),
        child: FutureBuilder<List<Kategori>>(
          future: futureKategori,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final list = snapshot.data ?? [];

            if (list.isEmpty) {
              return const Center(child: Text('Belum ada data kategori'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final kategori = list[i];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    title: Text(
                      kategori.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Kode : ${kategori.kode}',
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
                                onPressed: () => _showForm(kategori: kategori),
                              ),
                              IconButton(
                                tooltip: 'Hapus',
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDelete(kategori),
                              ),
                            ]
                          : [
                              IconButton(
                                tooltip: 'Detail',
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showDetail(kategori),
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

  void _showForm({Kategori? kategori}) {
    final namaController = TextEditingController(text: kategori?.nama ?? '');
    final kodeController = TextEditingController(text: kategori?.kode ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(kategori == null ? 'Tambah Kategori' : 'Edit Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _input(namaController, 'Nama Kategori'),
            _input(kodeController, 'Kode Kategori'),
          ],
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
              };

              try {
                if (kategori == null) {
                  await KategoriService.create(body);
                } else {
                  await KategoriService.update(kategori.id, body);
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

  Widget _input(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  void _showDetail(Kategori kategori) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detail Kategori'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detail('Nama', kategori.nama),
            _detail('Kode', kategori.kode),
            _detail('Dibuat', kategori.createdAt.toString()),
            _detail('Diupdate', kategori.updatedAt.toString()),
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

  void _confirmDelete(Kategori kategori) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Kategori'),
        content: Text('Yakin hapus kategori "${kategori.nama}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await KategoriService.delete(kategori.id);
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
