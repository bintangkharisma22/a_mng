import 'package:flutter/material.dart';
import '../../models/pemindahan_aset.dart';
import '../../models/ruangan.dart';
import '../../models/divisi.dart';
import '../../models/aset.dart';
import '../../services/pemindahan_service.dart';
import '../../services/ruangan_service.dart';
import '../../services/divisi_service.dart';
import '../../services/aset_service.dart';

class PemindahanAsetFormPage extends StatefulWidget {
  final String? asetId;
  final PemindahanAset? editData;

  const PemindahanAsetFormPage({super.key, this.asetId, this.editData});

  @override
  State<PemindahanAsetFormPage> createState() => _PemindahanAsetFormPageState();
}

class _PemindahanAsetFormPageState extends State<PemindahanAsetFormPage> {
  final _formKey = GlobalKey<FormState>();

  /// ======================
  /// VALUE DROPDOWN (PAKAI ID)
  /// ======================
  String? selectedAsetId;
  String? selectedRuanganId;
  String? selectedDivisiId;

  Aset? selectedAset;

  final _alasanController = TextEditingController();

  bool loading = false;
  bool loadingAset = true;

  late Future<List<Aset>> asetFuture;
  late Future<List<Ruangan>> ruanganFuture;
  late Future<List<Divisi>> divisiFuture;

  bool get isEdit => widget.editData != null;

  @override
  void initState() {
    super.initState();

    asetFuture = AsetService.getAset();
    ruanganFuture = RuanganService.getRuangan();
    divisiFuture = DivisiService.getDivisi();

    if (isEdit) {
      final e = widget.editData!;
      selectedAset = e.aset;
      selectedAsetId = e.aset?.id;
      selectedRuanganId = e.keRuangan?.id;
      selectedDivisiId = e.keDivisi?.id;
      _alasanController.text = e.alasan ?? '';
      loadingAset = false;
    } else if (widget.asetId != null) {
      _loadAset();
    } else {
      loadingAset = false;
    }
  }

  Future<void> _loadAset() async {
    try {
      final aset = await AsetService.getDetail(widget.asetId!);
      setState(() {
        selectedAset = aset;
        selectedAsetId = aset.id;
        loadingAset = false;
      });
    } catch (e) {
      loadingAset = false;
      _showError('Gagal memuat aset');
    }
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedAsetId == null) {
      _showError('Aset wajib dipilih');
      return;
    }

    if (selectedRuanganId == null && selectedDivisiId == null) {
      _showError('Pilih minimal ruangan atau divisi tujuan');
      return;
    }

    setState(() => loading = true);

    try {
      if (isEdit) {
        await PemindahanService.updatePemindahan(
          id: widget.editData!.id,
          keRuanganId: selectedRuanganId,
          keDivisiId: selectedDivisiId,
          alasan: _alasanController.text.trim(),
        );
      } else {
        await PemindahanService.createPemindahan(
          asetId: selectedAsetId!,
          keRuanganId: selectedRuanganId,
          keDivisiId: selectedDivisiId,
          alasan: _alasanController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showError(e.toString());
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
    if (loadingAset) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Pemindahan Aset' : 'Pindahkan Aset'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!isEdit && widget.asetId == null) _dropdownAset(),
            if (selectedAset != null) ...[
              const SizedBox(height: 16),
              _asetInfoCard(),
              const SizedBox(height: 16),
              _currentLocationCard(),
            ],
            const SizedBox(height: 24),
            const Text(
              'Tujuan Pemindahan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _dropdownRuangan(),
            const SizedBox(height: 16),
            _dropdownDivisi(),
            const SizedBox(height: 24),
            TextFormField(
              controller: _alasanController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Alasan',
                hintText: 'Opsional',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _submit,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(isEdit ? 'Simpan Perubahan' : 'Pindahkan Aset'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _asetInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aset', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Text(selectedAset!.kodeAset ?? '-'),
            Text('Kategori: ${selectedAset!.kategori?.nama ?? '-'}'),
          ],
        ),
      ),
    );
  }

  Widget _currentLocationCard() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lokasi Saat Ini',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text('Ruangan: ${selectedAset!.ruangan?.nama ?? '-'}'),
            Text('Divisi: ${selectedAset!.divisi?.nama ?? '-'}'),
          ],
        ),
      ),
    );
  }

  Widget _dropdownAset() {
    return FutureBuilder<List<Aset>>(
      future: asetFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();

        return DropdownButtonFormField<String>(
          initialValue: selectedAsetId,
          validator: (v) => v == null ? 'Pilih aset' : null,
          decoration: const InputDecoration(
            labelText: 'Aset',
            border: OutlineInputBorder(),
          ),
          items: snapshot.data!
              .map(
                (e) => DropdownMenuItem(
                  value: e.id,
                  child: Text(e.kodeAset ?? '-'),
                ),
              )
              .toList(),
          onChanged: (v) {
            setState(() {
              selectedAsetId = v;
              selectedAset = snapshot.data!.firstWhere((e) => e.id == v);
            });
          },
        );
      },
    );
  }

  Widget _dropdownRuangan() {
    return FutureBuilder<List<Ruangan>>(
      future: ruanganFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();

        return DropdownButtonFormField<String>(
          initialValue: selectedRuanganId,
          decoration: const InputDecoration(
            labelText: 'Ruangan Tujuan',
            border: OutlineInputBorder(),
          ),
          items: snapshot.data!
              .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nama)))
              .toList(),
          onChanged: (v) => setState(() => selectedRuanganId = v),
        );
      },
    );
  }

  Widget _dropdownDivisi() {
    return FutureBuilder<List<Divisi>>(
      future: divisiFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();

        return DropdownButtonFormField<String>(
          initialValue: selectedDivisiId,
          decoration: const InputDecoration(
            labelText: 'Divisi Tujuan',
            border: OutlineInputBorder(),
          ),
          items: snapshot.data!
              .map((e) => DropdownMenuItem(value: e.id, child: Text(e.nama)))
              .toList(),
          onChanged: (v) => setState(() => selectedDivisiId = v),
        );
      },
    );
  }
}
