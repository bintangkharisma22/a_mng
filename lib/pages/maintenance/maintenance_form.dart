import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/maintenance_aset.dart';
import '../../models/aset.dart';
import '../../services/maintenance_service.dart';
import '../../services/aset_service.dart';

class MaintenanceFormPage extends StatefulWidget {
  final String? maintenanceId;
  final String? asetId;

  const MaintenanceFormPage({super.key, this.maintenanceId, this.asetId});

  @override
  State<MaintenanceFormPage> createState() => _MaintenanceFormPageState();
}

class _MaintenanceFormPageState extends State<MaintenanceFormPage> {
  final _formKey = GlobalKey<FormState>();

  /// DROPDOWN STATE (ID BASED)
  String? selectedAsetId;
  String? selectedJenis;
  String? selectedStatus;

  /// DATA LIST
  List<Aset> asetList = [];

  /// FORM CONTROLLER
  final _teknisiController = TextEditingController();
  final _biayaController = TextEditingController();
  final _catatanController = TextEditingController();

  DateTime? tanggalDijadwalkan;
  DateTime? tanggalSelesai;

  bool loading = true;
  bool saving = false;

  late Future<List<Aset>> asetFuture;

  final List<String> jenisOptions = ['Rutin', 'Perbaikan', 'Inspeksi'];
  final List<String> statusOptions = [
    'Dijadwalkan',
    'Sedang Dikerjakan',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    asetFuture = AsetService.getAset();

    if (widget.maintenanceId != null) {
      _loadData();
    } else {
      loading = false;
      if (widget.asetId != null) {
        selectedAsetId = widget.asetId;
      }
    }
  }

  Future<void> _loadData() async {
    try {
      final data = await MaintenanceService.getDetail(widget.maintenanceId!);

      setState(() {
        selectedAsetId = data.asetId;
        selectedJenis = data.jenisMaintenance;
        selectedStatus = data.status;
        _teknisiController.text = data.teknisi ?? '';
        _biayaController.text = data.biaya != null ? data.biaya.toString() : '';
        _catatanController.text = data.catatan ?? '';
        tanggalDijadwalkan = data.tanggalDijadwalkan;
        tanggalSelesai = data.tanggalSelesai;
        loading = false;
      });
    } catch (e) {
      loading = false;
      _showError('Gagal memuat data: $e');
    }
  }

  @override
  void dispose() {
    _teknisiController.dispose();
    _biayaController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedAsetId == null) {
      _showError('Pilih aset');
      return;
    }

    if (tanggalDijadwalkan == null) {
      _showError('Pilih tanggal dijadwalkan');
      return;
    }

    setState(() => saving = true);

    try {
      final maintenance = MaintenanceAset(
        id: widget.maintenanceId ?? '',
        asetId: selectedAsetId!,
        jenisMaintenance: selectedJenis,
        teknisi: _teknisiController.text.trim().isEmpty
            ? null
            : _teknisiController.text.trim(),
        tanggalDijadwalkan: tanggalDijadwalkan,
        tanggalSelesai: tanggalSelesai,
        biaya: _biayaController.text.trim().isEmpty
            ? null
            : double.tryParse(_biayaController.text.trim()),
        status: selectedStatus ?? 'Dijadwalkan',
        catatan: _catatanController.text.trim().isEmpty
            ? null
            : _catatanController.text.trim(),
      );

      if (widget.maintenanceId != null) {
        await MaintenanceService.update(widget.maintenanceId!, maintenance);
      } else {
        await MaintenanceService.create(maintenance);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.maintenanceId != null
                ? 'Maintenance berhasil diperbarui'
                : 'Maintenance berhasil ditambahkan',
          ),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      _showError(e.toString());
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
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.maintenanceId != null
              ? 'Edit Maintenance'
              : 'Tambah Maintenance',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// PILIH ASET
            if (widget.asetId == null)
              FutureBuilder<List<Aset>>(
                future: asetFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }

                  asetList = snapshot.data!;

                  return DropdownButtonFormField<String>(
                    initialValue: selectedAsetId,
                    decoration: const InputDecoration(
                      labelText: 'Aset *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null ? 'Pilih aset' : null,
                    items: asetList
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e.id,
                            child: Text(e.kodeAset ?? '-'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedAsetId = v),
                  );
                },
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Aset ID: $selectedAsetId',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            /// JENIS
            DropdownButtonFormField<String>(
              initialValue: selectedJenis,
              decoration: const InputDecoration(
                labelText: 'Jenis Maintenance *',
                border: OutlineInputBorder(),
              ),
              validator: (v) => v == null ? 'Pilih jenis maintenance' : null,
              items: jenisOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedJenis = v),
            ),

            const SizedBox(height: 16),

            /// STATUS
            DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: statusOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => selectedStatus = v),
            ),

            const SizedBox(height: 16),

            /// TEKNISI
            TextFormField(
              controller: _teknisiController,
              decoration: const InputDecoration(
                labelText: 'Teknisi',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// TANGGAL DIJADWALKAN
            _dateField(
              label: 'Tanggal Dijadwalkan *',
              value: tanggalDijadwalkan,
              onPick: (d) => setState(() => tanggalDijadwalkan = d),
            ),

            const SizedBox(height: 16),

            /// TANGGAL SELESAI
            _dateField(
              label: 'Tanggal Selesai',
              value: tanggalSelesai,
              onPick: (d) => setState(() => tanggalSelesai = d),
            ),

            const SizedBox(height: 16),

            /// BIAYA
            TextFormField(
              controller: _biayaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Biaya',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            /// CATATAN
            TextFormField(
              controller: _catatanController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: saving ? null : _submit,
                icon: saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  widget.maintenanceId != null ? 'Perbarui' : 'Simpan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateField({
    required String label,
    required DateTime? value,
    required Function(DateTime) onPick,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) onPick(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          value != null
              ? DateFormat('dd MMMM yyyy', 'id_ID').format(value)
              : 'Pilih tanggal',
        ),
      ),
    );
  }
}
