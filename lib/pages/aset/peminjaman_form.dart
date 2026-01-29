import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/aset.dart';
import '../../services/aset_service.dart';
import '../../services/peminjaman_service.dart';

class PeminjamanFormPage extends StatefulWidget {
  const PeminjamanFormPage({super.key});

  @override
  State<PeminjamanFormPage> createState() => _PeminjamanFormPageState();
}

class _PeminjamanFormPageState extends State<PeminjamanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final namaPeminjamController = TextEditingController();
  final catatanController = TextEditingController();

  Aset? selectedAset;
  DateTime? tanggalPinjam;
  DateTime? tanggalKembaliRencana;

  late Future<List<Aset>> asetFuture;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // Load aset yang tersedia
    asetFuture = AsetService.getAset(status: 'Tersedia');

    // Set default tanggal pinjam = hari ini
    tanggalPinjam = DateTime.now();
    // Set default tanggal kembali = 7 hari dari sekarang
    tanggalKembaliRencana = DateTime.now().add(const Duration(days: 7));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Peminjaman')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('Informasi Peminjaman'),
                    const SizedBox(height: 16),

                    // Pilih Aset
                    FutureBuilder<List<Aset>>(
                      future: asetFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const LinearProgressIndicator();
                        }

                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Card(
                            color: Colors.orange,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Tidak ada aset yang tersedia untuk dipinjam',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        }

                        final asets = snapshot.data!;

                        return DropdownButtonFormField<Aset>(
                          value: selectedAset,
                          decoration: const InputDecoration(
                            labelText: 'Pilih Aset',
                            prefixIcon: Icon(Icons.inventory_2),
                            border: OutlineInputBorder(),
                          ),
                          items: asets
                              .map(
                                (a) => DropdownMenuItem(
                                  value: a,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        a.kodeAset ?? '-',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        a.kodeAset ?? '-',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedAset = v),
                          validator: (v) =>
                              v == null ? 'Aset wajib dipilih' : null,
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Nama Peminjam
                    TextFormField(
                      controller: namaPeminjamController,
                      decoration: const InputDecoration(
                        labelText: 'Nama Peminjam',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan nama peminjam',
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Nama wajib diisi' : null,
                    ),

                    const SizedBox(height: 16),

                    // Tanggal Pinjam
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Pinjam',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          tanggalPinjam != null
                              ? DateFormat(
                                  'dd MMMM yyyy',
                                  'id_ID',
                                ).format(tanggalPinjam!)
                              : 'Pilih tanggal',
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tanggal Rencana Kembali
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Rencana Tanggal Kembali',
                          prefixIcon: Icon(Icons.event),
                          border: OutlineInputBorder(),
                        ),
                        child: Text(
                          tanggalKembaliRencana != null
                              ? DateFormat(
                                  'dd MMMM yyyy',
                                  'id_ID',
                                ).format(tanggalKembaliRencana!)
                              : 'Pilih tanggal',
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Catatan
                    TextFormField(
                      controller: catatanController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (opsional)',
                        prefixIcon: Icon(Icons.note),
                        border: OutlineInputBorder(),
                        hintText: 'Keperluan peminjaman',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info Aset yang dipilih
            if (selectedAset != null)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Aset',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Divider(height: 16),
                      _detailRow('Kode', selectedAset!.kodeAset ?? '-'),
                      _detailRow(
                        'Kategori',
                        selectedAset!.kategori?.nama ?? '-',
                      ),
                      _detailRow('Ruangan', selectedAset!.ruangan?.nama ?? '-'),
                      _detailRow('Kondisi', selectedAset!.kondisi?.nama ?? '-'),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: loading ? null : _submit,
                icon: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(loading ? 'Mengajukan...' : 'Ajukan Peminjaman'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate(BuildContext context, bool isPinjam) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isPinjam
          ? (tanggalPinjam ?? DateTime.now())
          : (tanggalKembaliRencana ??
                DateTime.now().add(const Duration(days: 7))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        if (isPinjam) {
          tanggalPinjam = date;
        } else {
          tanggalKembaliRencana = date;
        }
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (tanggalPinjam == null || tanggalKembaliRencana == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal pinjam dan tanggal kembali wajib diisi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (tanggalKembaliRencana!.isBefore(tanggalPinjam!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal kembali tidak boleh sebelum tanggal pinjam'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final data = {
        'aset_id': selectedAset!.id,
        'nama_peminjam': namaPeminjamController.text,
        'tanggal_pinjam': tanggalPinjam!.toIso8601String().split('T')[0],
        'tanggal_kembali_rencana': tanggalKembaliRencana!
            .toIso8601String()
            .split('T')[0],
        if (catatanController.text.isNotEmpty)
          'catatan': catatanController.text,
      };

      await PeminjamanService.create(data);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peminjaman berhasil diajukan'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengajukan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }
}
