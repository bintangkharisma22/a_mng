import 'package:flutter/material.dart';
import '../../models/supplier.dart';
import '../../services/supplier_service.dart';
import '../../core/session.dart';

class SupplierPage extends StatefulWidget {
  const SupplierPage({super.key});

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  late Future<List<Supplier>> futureSupplier;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
    _loadRole();
  }

  void _load() {
    futureSupplier = SupplierService.getSupplier();
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
      appBar: AppBar(title: const Text('Supplier')),

      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () => _showForm(),
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,

      body: RefreshIndicator(
        onRefresh: () async => setState(_load),
        child: FutureBuilder<List<Supplier>>(
          future: futureSupplier,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final list = snapshot.data ?? [];

            if (list.isEmpty) {
              return const Center(child: Text('Belum ada data supplier'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final supplier = list[i];

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),

                    title: Text(
                      supplier.nama,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Telepon: ${supplier.telepon ?? '-'}\n'
                        'Alamat: ${supplier.alamat ?? '-'}',
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
                                onPressed: () => _showForm(supplier: supplier),
                              ),
                              IconButton(
                                tooltip: 'Hapus',
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDelete(supplier),
                              ),
                            ]
                          : [
                              IconButton(
                                tooltip: 'Detail',
                                icon: const Icon(
                                  Icons.visibility,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _showDetail(supplier),
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

  void _showForm({Supplier? supplier}) {
    final namaController = TextEditingController(text: supplier?.nama ?? '');
    final teleponController = TextEditingController(
      text: supplier?.telepon ?? '',
    );
    final alamatController = TextEditingController(
      text: supplier?.alamat ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(supplier == null ? 'Tambah Supplier' : 'Edit Supplier'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _input(namaController, 'Nama Supplier'),
              _input(
                teleponController,
                'Telepon',
                keyboard: TextInputType.phone,
              ),
              _input(alamatController, 'Alamat'),
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
                'telepon': teleponController.text.isEmpty
                    ? null
                    : teleponController.text,
                'alamat': alamatController.text.isEmpty
                    ? null
                    : alamatController.text,
              };

              try {
                if (supplier == null) {
                  await SupplierService.create(body);
                } else {
                  await SupplierService.update(supplier.id, body);
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

  void _showDetail(Supplier supplier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Detail Supplier'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detail('Nama', supplier.nama),
            _detail('Telepon', supplier.telepon ?? '-'),
            _detail('Alamat', supplier.alamat ?? '-'),
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

  void _confirmDelete(Supplier supplier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Supplier'),
        content: Text('Yakin hapus supplier "${supplier.nama}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await SupplierService.delete(supplier.id);
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
