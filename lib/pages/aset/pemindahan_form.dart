import 'package:flutter/material.dart';
import '../../models/ruangan.dart';
import '../../models/divisi.dart';
import '../../models/aset.dart';
import '../../services/pemindahan_service.dart';
import '../../services/ruangan_service.dart';
import '../../services/divisi_service.dart';
import '../../services/aset_service.dart';

class PemindahanAsetFormPage extends StatefulWidget {
  final String? asetId; // Optional: jika dari detail aset

  const PemindahanAsetFormPage({super.key, this.asetId});

  @override
  State<PemindahanAsetFormPage> createState() => _PemindahanAsetFormPageState();
}

class _PemindahanAsetFormPageState extends State<PemindahanAsetFormPage> {
  final _formKey = GlobalKey<FormState>();

  Aset? selectedAset;
  Ruangan? selectedRuangan;
  Divisi? selectedDivisi;

  final _alasanController = TextEditingController();

  bool loading = false;
  bool loadingAset = true;

  late Future<List<Aset>> asetFuture;
  late Future<List<Ruangan>> ruanganFuture;
  late Future<List<Divisi>> divisiFuture;

  @override
  void initState() {
    super.initState();
    asetFuture = AsetService.getAset();
    ruanganFuture = RuanganService.getRuangan();
    divisiFuture = DivisiService.getDivisi();

    if (widget.asetId != null) {
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
        loadingAset = false;
      });
    } catch (e) {
      setState(() => loadingAset = false);
      _showError('Gagal memuat data aset: $e');
    }
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedAset == null) {
      _showError('Pilih aset terlebih dahulu');
      return;
    }

    if (selectedRuangan == null && selectedDivisi == null) {
      _showError('Pilih minimal satu tujuan (Ruangan atau Divisi)');
      return;
    }

    setState(() => loading = true);

    try {
      await PemindahanService.createPemindahan(
        asetId: selectedAset!.id,
        keRuanganId: selectedRuangan?.id,
        keDivisiId: selectedDivisi?.id,
        alasan: _alasanController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pemindahan aset berhasil'),
          backgroundColor: Colors.green,
        ),
      );

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
      appBar: AppBar(title: const Text('Pindahkan Aset')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Pilih Aset (jika tidak dari detail aset)
            if (widget.asetId == null) _dropdownAset() else _asetInfoCard(),

            const SizedBox(height: 16),

            // Info Lokasi Saat Ini
            if (selectedAset != null) _currentLocationCard(),

            const SizedBox(height: 24),
            const Text(
              'Pindahkan ke:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Pilih Ruangan Tujuan
            _dropdownRuangan(),

            // Pilih Divisi Tujuan
            _dropdownDivisi(),

            // Alasan
            TextFormField(
              controller: _alasanController,
              decoration: const InputDecoration(
                labelText: 'Alasan Pemindahan',
                hintText: 'Opsional',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: loading ? null : _submit,
                icon: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.swap_horiz),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                label: const Text('Pindahkan Aset'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _asetInfoCard() {
    if (selectedAset == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aset yang Dipindahkan',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text(
              selectedAset!.kodeAset ?? 'N/A',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
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
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text(
                  'Lokasi Saat Ini',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                const Icon(Icons.meeting_room, size: 16),
                const SizedBox(width: 8),
                Text('Ruangan: ${selectedAset!.ruangan?.nama ?? '-'}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.business, size: 16),
                const SizedBox(width: 8),
                Text('Divisi: ${selectedAset!.divisi?.nama ?? '-'}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropdownAset() {
    return FutureBuilder<List<Aset>>(
      future: asetFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LinearProgressIndicator();
        }

        final items = snapshot.data!;

        return DropdownButtonFormField<Aset>(
          initialValue: selectedAset,
          decoration: const InputDecoration(
            labelText: 'Pilih Aset',
            border: OutlineInputBorder(),
          ),
          validator: (value) => value == null ? 'Pilih aset' : null,
          items: items
              .map(
                (e) => DropdownMenuItem<Aset>(
                  value: e,
                  child: Text(e.kodeAset ?? 'N/A'),
                ),
              )
              .toList(),
          onChanged: (val) => setState(() => selectedAset = val),
        );
      },
    );
  }

  Widget _dropdownRuangan() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FutureBuilder<List<Ruangan>>(
        future: ruanganFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LinearProgressIndicator();
          }

          final items = snapshot.data!;

          return DropdownButtonFormField<Ruangan>(
            initialValue: selectedRuangan,
            decoration: const InputDecoration(
              labelText: 'Ruangan Tujuan',
              hintText: 'Opsional',
              border: OutlineInputBorder(),
            ),
            items: items
                .map(
                  (e) =>
                      DropdownMenuItem<Ruangan>(value: e, child: Text(e.nama)),
                )
                .toList(),
            onChanged: (val) => setState(() => selectedRuangan = val),
          );
        },
      ),
    );
  }

  Widget _dropdownDivisi() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: FutureBuilder<List<Divisi>>(
        future: divisiFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LinearProgressIndicator();
          }

          final items = snapshot.data!;

          return DropdownButtonFormField<Divisi>(
            initialValue: selectedDivisi,
            decoration: const InputDecoration(
              labelText: 'Divisi Tujuan',
              hintText: 'Opsional',
              border: OutlineInputBorder(),
            ),
            items: items
                .map(
                  (e) =>
                      DropdownMenuItem<Divisi>(value: e, child: Text(e.nama)),
                )
                .toList(),
            onChanged: (val) => setState(() => selectedDivisi = val),
          );
        },
      ),
    );
  }
}
