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
      appBar: AppBar(title: const Text('Master Barang')),
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
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada data barang',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Barang akan otomatis tersimpan saat pengadaan disetujui',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final barang = list[i];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      child: Text(barang.nama[0].toUpperCase()),
                    ),
                    title: Text(
                      barang.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Kode: ${barang.kode}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    trailing: isAdmin
                        ? PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Hapus'),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showForm(barang: barang);
                              } else if (value == 'delete') {
                                _confirmDelete(barang);
                              }
                            },
                          )
                        : null,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _detailRow(
                              'Kategori',
                              barang.kategori?.nama ?? '-',
                            ),
                            _detailRow(
                              'Spesifikasi',
                              barang.spesifikasi ?? '-',
                            ),
                            _detailRow('Satuan', barang.satuan ?? '-'),
                            if (barang.pengadaanDetailId != null)
                              _detailRow('Dari Pengadaan', 'Ya'),
                            const SizedBox(height: 8),
                            Text(
                              'Dibuat: ${_formatDate(barang.createdAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const Text(': '),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(barang == null ? 'Tambah Barang' : 'Edit Barang'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              if (namaController.text.isEmpty || kodeController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama dan kode wajib diisi')),
                );
                return;
              }

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

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Barang berhasil disimpan'),
                    backgroundColor: Colors.green,
                  ),
                );
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
        decoration: const InputDecoration(labelText: 'Kategori (opsional)'),
        items: list.map((k) {
          return DropdownMenuItem(value: k.id, child: Text(k.nama));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _confirmDelete(Barang barang) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Barang'),
        content: Text('Yakin hapus barang "${barang.nama}"?'),
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

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Barang berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
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
