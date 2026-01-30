// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/aset_edit.dart';
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
  AsetEdit? aset;

  File? gambarBaru;

  /// VALUE FORM (ID BASED)
  String? ruanganId;
  String? divisiId;
  String? kondisiId;

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
      final data = await AsetService.getEdit(widget.asetId);

      setState(() {
        aset = data;

        nomorSeri = data.nomorSeri;
        ruanganId = data.ruanganId;
        divisiId = data.divisiId;
        kondisiId = data.kondisiId;

        tanggalPenerimaan = data.tanggalPenerimaan;
        tanggalAkhirGaransi = data.tanggalAkhirGaransi;

        loading = false;
      });
    } catch (e) {
      loading = false;
      debugPrint(e.toString());
      debugPrintStack();
      _showError('Gagal memuat data aset');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => gambarBaru = File(picked.path));
  }

  Future<void> _submit() async {
    if (aset == null) return;

    if (ruanganId == null || divisiId == null || kondisiId == null) {
      _showError('Ruangan, Divisi, dan Kondisi wajib diisi');
      return;
    }

    setState(() => saving = true);

    try {
      final body = {
        'nomor_seri': nomorSeri,
        'ruangan_id': ruanganId,
        'divisi_id': divisiId,
        'kondisi_id': kondisiId,
        'status': aset!.status,
        'tanggal_penerimaan': tanggalPenerimaan != null
            ? DateFormat('yyyy-MM-dd').format(tanggalPenerimaan!)
            : null,
        'tanggal_akhir_garansi': tanggalAkhirGaransi != null
            ? DateFormat('yyyy-MM-dd').format(tanggalAkhirGaransi!)
            : null,
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
      _showError('Gagal update aset');
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _imageSection(),
            const SizedBox(height: 16),
            _section(
              title: "Informasi Aset",
              icon: Icons.inventory_2,
              children: [
                _readonlyField('Kode Aset', aset!.kodeAset),
                _readonlyField("Pengadaan Detail Id", aset!.pengadaanDetailId),
                _textField(
                  label: "Nomor Seri",
                  icon: Icons.confirmation_number,
                  initialValue: nomorSeri,
                  onChanged: (v) => nomorSeri = v,
                ),
              ],
            ),
            _section(
              title: "Lokasi Dan Kondisi",
              icon: Icons.apartment,
              children: [
                _dropdownId<KondisiAset>(
                  label: 'Kondisi',
                  future: kondisiFuture,
                  value: kondisiId,
                  getId: (e) => e.id,
                  getLabel: (e) => e.nama,
                  onChanged: (v) => setState(() => kondisiId = v),
                ),

                _dropdownId<Ruangan>(
                  label: 'Ruangan',
                  future: ruanganFuture,
                  value: ruanganId,
                  getId: (e) => e.id,
                  getLabel: (e) => e.nama,
                  onChanged: (v) => setState(() => ruanganId = v),
                ),

                _dropdownId<Divisi>(
                  label: 'Divisi',
                  future: divisiFuture,
                  value: divisiId,
                  getId: (e) => e.id,
                  getLabel: (e) => e.nama,
                  onChanged: (v) => setState(() => divisiId = v),
                ),
              ],
            ),

            _section(
              title: "Tanggal",
              icon: Icons.date_range,
              children: [
                _datePickerField(
                  label: 'Tanggal Penerimaan',
                  value: tanggalPenerimaan,
                  onChanged: (d) => setState(() => tanggalPenerimaan = d),
                ),

                _datePickerField(
                  label: 'Tanggal Akhir Garansi',
                  value: tanggalAkhirGaransi,
                  onChanged: (d) => setState(() => tanggalAkhirGaransi = d),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _submitButton(),
          ],
        ),
      ),
    );
  }

  Widget _imageSection() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        height: 160,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade200,
          image: gambarBaru != null
              ? DecorationImage(
                  image: FileImage(gambarBaru!),
                  fit: BoxFit.cover,
                )
              : aset!.gambar != null
              ? DecorationImage(
                  image: NetworkImage('${Config.bucketUrl}/${aset!.gambar}'),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: const Center(child: Text('Tap untuk ganti foto')),
      ),
    );
  }

  Widget _readonlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.lock),
        ),
      ),
    );
  }

  Widget _datePickerField({
    required String label,
    required DateTime? value,
    required Function(DateTime) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) onChanged(picked);
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: const Icon(Icons.calendar_month),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            value != null
                ? DateFormat('dd MMM yyyy').format(value)
                : 'Pilih tanggal',
            style: TextStyle(color: value != null ? Colors.black : Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    required IconData icon,
    String? initialValue,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.save),
        label: Text(
          saving ? 'Menyimpan...' : 'Simpan Perubahan',
          style: const TextStyle(fontSize: 16),
        ),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: saving ? null : _submit,
      ),
    );
  }

  Widget _dropdownId<T>({
    required String label,
    required Future<List<T>> future,
    required String? value,
    required String Function(T) getId,
    required String Function(T) getLabel,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: FutureBuilder<List<T>>(
        future: future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LinearProgressIndicator();
          }

          return DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            items: snapshot.data!
                .map(
                  (e) => DropdownMenuItem(
                    value: getId(e),
                    child: Text(getLabel(e)),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          );
        },
      ),
    );
  }
}
