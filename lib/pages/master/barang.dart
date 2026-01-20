import 'package:flutter/material.dart';
import '../../models/barang.dart';
import '../../models/kategori.dart';
import '../../services/barang_service.dart';
import '../../services/kategori_service.dart';
import '../../core/session.dart';

class BarangPage extends StatefulWidget {
  const BarangPage({super.key});

  @override
  State<BarangPage> createState() => _BarangPageState();
}

class _BarangPageState extends State<BarangPage> {
  late Future<List<Barang>> futureBarang;
  late Future<List<Kategori>> futureKategori;

  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
    _loadRole();
    futureKategori = KategoriService.getKategori();
  }

  void _load() {
    futureBarang = BarangService.getBarang();
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
      appBar: AppBar(title: const Text('Barang')),

      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showForm(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,

      body: RefreshIndicator(
        onRefresh: () async => setState(_load),
        child: FutureBuilder<List<Barang>>(
          future: futureBarang,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final list = snapshot.data ?? [];

            if (list.isEmpty) {
              return const Center(child: Text('Belum ada data barang'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final barang = list[i];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    title: Text(
                      barang.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Kode: ${barang.kode}\n'
                        'Kategori: ${barang.kategoriNama ?? '-'}\n'
                        'Satuan: ${barang.satuan ?? '-'}',
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
                                onPressed: () => _showForm(barang: barang),
                              ),
                              IconButton(
                                tooltip: 'Hapus',
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDelete(barang),
                              ),
                            ]
                          : [
                              IconButton(
                                tooltip: 'Detail',
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showDetail(barang),
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

  void _showForm({Barang? barang}) async {
    final namaController = TextEditingController(text: barang?.nama ?? '');
    final kodeController = TextEditingController(text: barang?.kode ?? '');
    final spesifikasiController = TextEditingController(
      text: barang?.spesifikasi ?? '',
    );
    final satuanController = TextEditingController(text: barang?.satuan ?? '');

    String? selectedKategoriId = barang?.kategoriId;

    final kategoriList = await futureKategori;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(barang == null ? 'Tambah Barang' : 'Edit Barang'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _input(namaController, 'Nama Barang'),
              _input(kodeController, 'Kode'),
              _dropdownKategori(
                kategoriList,
                selectedKategoriId,
                (val) => selectedKategoriId = val,
              ),
              _input(spesifikasiController, 'Spesifikasi'),
              _input(satuanController, 'Satuan'),
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
                'kategori_id': selectedKategoriId,
                'spesifikasi': spesifikasiController.text.isEmpty
                    ? null
                    : spesifikasiController.text,
                'satuan': satuanController.text.isEmpty
                    ? null
                    : satuanController.text,
              };

              try {
                if (barang == null) {
                  await BarangService.create(body);
                } else {
                  await BarangService.update(barang.id, body);
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

  Widget _dropdownKategori(
    List<Kategori> list,
    String? selectedId,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: selectedId,
        decoration: const InputDecoration(labelText: 'Kategori'),
        items: list.map((k) {
          return DropdownMenuItem(value: k.id, child: Text(k.nama));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showDetail(Barang barang) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detail Barang'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detail('Nama', barang.nama),
            _detail('Kode', barang.kode),
            _detail('Kategori', barang.kategoriNama ?? '-'),
            _detail('Spesifikasi', barang.spesifikasi ?? '-'),
            _detail('Satuan', barang.satuan ?? '-'),
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

  void _confirmDelete(Barang barang) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Yakin hapus barang "${barang.nama}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await BarangService.delete(barang.id);
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
