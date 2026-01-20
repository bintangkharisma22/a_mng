import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:a_mng/models/kategori.dart';
import 'package:a_mng/models/ruangan.dart';
import 'package:a_mng/models/divisi.dart';
import 'package:a_mng/models/kondisi_aset.dart';
import 'package:a_mng/services/aset_service.dart';
import 'package:a_mng/services/kategori_service.dart';
import 'package:a_mng/services/ruangan_service.dart';
import 'package:a_mng/services/divisi_service.dart';
import 'package:a_mng/services/kondisi_service.dart';

class AsetFormPage extends StatefulWidget {
  const AsetFormPage({super.key});

  @override
  State<AsetFormPage> createState() => _AsetFormPageState();
}

class _AsetFormPageState extends State<AsetFormPage> {
  final _formKey = GlobalKey<FormState>();

  final kodeController = TextEditingController();
  final seriController = TextEditingController();

  Kategori? selectedKategori;
  Ruangan? selectedRuangan;
  Divisi? selectedDivisi;
  KondisiAset? selectedKondisi;

  File? selectedImage;

  bool loading = false;

  late Future<List<Kategori>> kategoriFuture;
  late Future<List<Ruangan>> ruanganFuture;
  late Future<List<Divisi>> divisiFuture;
  late Future<List<KondisiAset>> kondisiFuture;

  @override
  void initState() {
    super.initState();
    kategoriFuture = KategoriService.getKategori();
    ruanganFuture = RuanganService.getRuangan();
    divisiFuture = DivisiService.getDivisi();
    kondisiFuture = KondisiService.getKondisi();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedKategori == null ||
        selectedRuangan == null ||
        selectedDivisi == null ||
        selectedKondisi == null) {
      _showError('Semua pilihan wajib diisi');
      return;
    }

    setState(() => loading = true);

    try {
      await AsetService.create({
        'kode_aset': kodeController.text,
        'nomor_seri': seriController.text,
        'kategori_id': selectedKategori!.id,
        'ruangan_id': selectedRuangan!.id,
        'divisi_id': selectedDivisi!.id,
        'kondisi_id': selectedKondisi!.id,
      }, gambar: selectedImage);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showError('Gagal menyimpan aset');
    } finally {
      setState(() => loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Aset')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title('Foto Aset'),
                  const SizedBox(height: 10),

                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      height: 160,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        image: selectedImage != null
                            ? DecorationImage(
                                image: FileImage(selectedImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: selectedImage == null
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 6),
                                  Text('Pilih Gambar'),
                                ],
                              ),
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(height: 24),
                  _title('Informasi Aset'),
                  const SizedBox(height: 16),

                  _textField(
                    controller: kodeController,
                    label: 'Kode Aset',
                    icon: Icons.qr_code,
                  ),

                  _textField(
                    controller: seriController,
                    label: 'Nomor Seri (opsional)',
                    icon: Icons.confirmation_number,
                    required: false,
                  ),

                  const SizedBox(height: 20),
                  _title('Relasi Data'),
                  const SizedBox(height: 12),

                  _dropdown<Kategori>(
                    label: 'Kategori',
                    future: kategoriFuture,
                    value: selectedKategori,
                    getLabel: (e) => e.nama,
                    onChanged: (val) => setState(() => selectedKategori = val),
                  ),

                  _dropdown<Ruangan>(
                    label: 'Ruangan',
                    future: ruanganFuture,
                    value: selectedRuangan,
                    getLabel: (e) => e.nama,
                    onChanged: (val) => setState(() => selectedRuangan = val),
                  ),

                  _dropdown<Divisi>(
                    label: 'Divisi',
                    future: divisiFuture,
                    value: selectedDivisi,
                    getLabel: (e) => e.nama,
                    onChanged: (val) => setState(() => selectedDivisi = val),
                  ),

                  _dropdown<KondisiAset>(
                    label: 'Kondisi',
                    future: kondisiFuture,
                    value: selectedKondisi,
                    getLabel: (e) => e.nama,
                    onChanged: (val) => setState(() => selectedKondisi = val),
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: loading ? null : _submit,
                      icon: const Icon(Icons.save),
                      label: loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Simpan Aset'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _title(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: required
            ? (v) => v == null || v.isEmpty ? '$label wajib diisi' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required Future<List<T>> future,
    required T? value,
    required String Function(T) getLabel,
    required void Function(T?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: FutureBuilder<List<T>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LinearProgressIndicator();
          }

          final items = snapshot.data!;

          return DropdownButtonFormField<T>(
            value: value,
            validator: (v) => v == null ? '$label wajib dipilih' : null,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: items
                .map(
                  (e) =>
                      DropdownMenuItem<T>(value: e, child: Text(getLabel(e))),
                )
                .toList(),
            onChanged: onChanged,
          );
        },
      ),
    );
  }
}
