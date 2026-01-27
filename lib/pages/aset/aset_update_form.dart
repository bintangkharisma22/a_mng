import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/aset.dart';
import '../../models/ruangan.dart';
import '../../models/divisi.dart';
import '../../models/kondisi_aset.dart';

import '../../services/aset_service.dart';
import '../../services/ruangan_service.dart';
import '../../services/divisi_service.dart';
import '../../services/kondisi_service.dart';
import '../../core/config.dart';

class AsetEditPage extends StatefulWidget {
  final String asetId;
  const AsetEditPage({super.key, required this.asetId});

  @override
  State<AsetEditPage> createState() => _AsetEditPageState();
}

class _AsetEditPageState extends State<AsetEditPage> {
  Aset? aset;

  File? gambarBaru;

  Ruangan? ruangan;
  Divisi? divisi;
  KondisiAset? kondisi;

  String? nomorSeri;
  DateTime? tanggalPenerimaan;
  DateTime? tanggalAkhirGaransi;

  bool loading = true;
  bool saving = false;

  late Future<List<Ruangan>> ruanganFuture;
  late Future<List<Divisi>> divisiFuture;
  late Future<List<KondisiAset>> kondisiFuture;

  @override
  void initState() {
    super.initState();

    ruanganFuture = RuanganService.getRuangan();
    divisiFuture = DivisiService.getDivisi();
    kondisiFuture = KondisiService.getKondisi();

    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final data = await AsetService.getDetail(widget.asetId);

      setState(() {
        aset = data;

        ruangan = data.ruangan;
        divisi = data.divisi;
        kondisi = data.kondisi;

        nomorSeri = data.nomorSeri;
        tanggalPenerimaan = data.tanggalPenerimaan;
        tanggalAkhirGaransi = data.tanggalAkhirGaransi;

        loading = false;
      });
    } catch (e) {
      _showError('Gagal memuat detail aset');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => gambarBaru = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (aset == null) return;

    if (ruangan == null || divisi == null || kondisi == null) {
      _showError('Ruangan, divisi, dan kondisi wajib diisi');
      return;
    }

    setState(() => saving = true);

    try {
      final body = {
        'nomor_seri': nomorSeri,
        'ruangan_id': ruangan!.id,
        'divisi_id': divisi!.id,
        'kondisi_id': kondisi!.id,

        'tanggal_penerimaan': tanggalPenerimaan != null
            ? DateFormat('yyyy-MM-dd').format(tanggalPenerimaan!)
            : null,

        'tanggal_akhir_garansi': tanggalAkhirGaransi != null
            ? DateFormat('yyyy-MM-dd').format(tanggalAkhirGaransi!)
            : null,

        'status': aset!.status,
      };

      await AsetService.updateMultipart(aset!.id, body, gambar: gambarBaru);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aset berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      _showError('Gagal update aset: $e');
    } finally {
      setState(() => saving = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    if (loading || aset == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit Aset ${aset!.kodeAset}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title('Foto Aset'),

            const SizedBox(height: 12),

            InkWell(
              onTap: _pickImage,
              child: Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  image: gambarBaru != null
                      ? DecorationImage(
                          image: FileImage(gambarBaru!),
                          fit: BoxFit.cover,
                        )
                      : aset!.gambar != null
                      ? DecorationImage(
                          image: NetworkImage(
                            '${Config.bucketUrl}/${aset!.gambar}',
                          ),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: const Center(child: Text('Tap untuk ganti foto')),
              ),
            ),

            const SizedBox(height: 24),

            _dropdown<KondisiAset>(
              label: 'Kondisi',
              future: kondisiFuture,
              value: kondisi,
              getLabel: (e) => e.nama,
              onChanged: (val) => setState(() => kondisi = val),
            ),

            _dropdown<Ruangan>(
              label: 'Ruangan',
              future: ruanganFuture,
              value: ruangan,
              getLabel: (e) => e.nama,
              onChanged: (val) => setState(() => ruangan = val),
            ),

            _dropdown<Divisi>(
              label: 'Divisi',
              future: divisiFuture,
              value: divisi,
              getLabel: (e) => e.nama,
              onChanged: (val) => setState(() => divisi = val),
            ),

            TextFormField(
              initialValue: nomorSeri,
              decoration: const InputDecoration(
                labelText: 'Nomor Seri',
                border: OutlineInputBorder(),
              ),
              onChanged: (val) => nomorSeri = val,
            ),

            const SizedBox(height: 12),

            InputDatePickerFormField(
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              fieldLabelText: 'Tanggal Penerimaan',
              initialDate: tanggalPenerimaan ?? DateTime.now(),
              onDateSubmitted: (date) =>
                  setState(() => tanggalPenerimaan = date),
            ),

            const SizedBox(height: 12),

            InputDatePickerFormField(
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              fieldLabelText: 'Tanggal Akhir Garansi',
              initialDate: tanggalAkhirGaransi ?? DateTime.now(),
              onDateSubmitted: (date) =>
                  setState(() => tanggalAkhirGaransi = date),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saving ? null : _submit,
                icon: const Icon(Icons.save),
                label: saving
                    ? const CircularProgressIndicator(strokeWidth: 2)
                    : const Text('Simpan Perubahan'),
              ),
            ),
          ],
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
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
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
