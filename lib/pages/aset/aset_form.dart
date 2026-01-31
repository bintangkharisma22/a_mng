import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/ruangan.dart';
import '../../models/divisi.dart';
import '../../models/kondisi_aset.dart';
import '../../models/barang.dart';
import '../../models/pengadaan_detail.dart';

import '../../services/aset_service.dart';
import '../../services/ruangan_service.dart';
import '../../services/divisi_service.dart';
import '../../services/kondisi_service.dart';
import '../../services/pengadaan_service.dart';
import '../../services/barang_service.dart';

class AsetFormPage extends StatefulWidget {
  const AsetFormPage({super.key});

  @override
  State<AsetFormPage> createState() => _AsetFormPageState();
}

/* =======================
   MODEL FORM PER BARANG
======================= */
class AsetFormItem {
  Barang barang;
  File? gambar;
  Ruangan? ruangan;
  Divisi? divisi;
  KondisiAset? kondisi;
  String? nomorSeri;
  DateTime? tanggalAkhirGaransi;

  AsetFormItem({required this.barang});
}

class _AsetFormPageState extends State<AsetFormPage> {
  PengadaanDetail? selectedDetail;

  List<AsetFormItem> asetForms = [];

  bool loading = false;
  bool loadingBarang = false;

  late Future<List<Ruangan>> ruanganFuture;
  late Future<List<Divisi>> divisiFuture;
  late Future<List<KondisiAset>> kondisiFuture;
  late Future<List<PengadaanDetail>> pengadaanDetailFuture;

  @override
  void initState() {
    super.initState();

    ruanganFuture = RuanganService.getRuangan();
    divisiFuture = DivisiService.getDivisi();
    kondisiFuture = KondisiService.getKondisi();
    pengadaanDetailFuture = PengadaanService.getDetailApproved();
  }

  /* =======================
     LOAD BARANG PER DETAIL
  ======================= */
  Future<void> _loadBarangByDetail(String detailId) async {
    setState(() {
      loadingBarang = true;
      asetForms = [];
    });

    try {
      final list = await BarangService.getByPengadaanDetail(detailId);

      setState(() {
        asetForms = list.map((b) => AsetFormItem(barang: b)).toList();
      });
    } catch (e) {
      _showError('Gagal memuat barang: $e');
    } finally {
      setState(() => loadingBarang = false);
    }
  }

  /* =======================
     PICK IMAGE
  ======================= */
  Future<void> _pickImage(AsetFormItem item) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => item.gambar = File(picked.path));
    }
  }

  /* =======================
     SUBMIT SEMUA ASET
  ======================= */
  Future<void> _submit() async {
    if (selectedDetail == null) {
      _showError('Pengadaan detail wajib dipilih');
      return;
    }

    if (asetForms.isEmpty) {
      _showError('Tidak ada barang');
      return;
    }

    // validasi
    for (final item in asetForms) {
      if (item.gambar == null ||
          item.ruangan == null ||
          item.divisi == null ||
          item.kondisi == null ||
          item.nomorSeri == null) {
        _showError('Semua aset wajib lengkap');
        return;
      }
    }

    setState(() => loading = true);

    try {
      for (final item in asetForms) {
        final kode = 'AST-${DateTime.now().millisecondsSinceEpoch}';

        final body = {
          'kode_aset': kode,
          'nomor_seri': item.nomorSeri,
          'kategori_id': item.barang.kategoriId,
          'ruangan_id': item.ruangan!.id,
          'divisi_id': item.divisi!.id,
          'kondisi_id': item.kondisi!.id,
          'pengadaan_detail_id': item.barang.pengadaanDetailId,
          'harga_pembelian': item.barang.harga,
          'tanggal_akhir_garansi': item.tanggalAkhirGaransi != null
              ? DateFormat('yyyy-MM-dd').format(item.tanggalAkhirGaransi!)
              : null,
          'status': 'Tersedia',
        };

        await AsetService.create(body, gambar: item.gambar);
      }

      await PengadaanService.updateStatus(
        selectedDetail!.pengadaanId!,
        status: 'selesai',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua aset berhasil disimpan & pengadaan selesai'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      _showError('Gagal menyimpan aset: $e');
    } finally {
      setState(() => loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  /* =======================
            UI
  ======================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Aset dari Pengadaan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _title('Pilih Pengadaan Detail'),

            const SizedBox(height: 12),

            FutureBuilder<List<PengadaanDetail>>(
              future: pengadaanDetailFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Tidak ada pengadaan detail disetujui');
                }

                final details = snapshot.data!;

                return DropdownButtonFormField<PengadaanDetail>(
                  decoration: const InputDecoration(
                    labelText: 'Pengadaan Detail',
                    border: OutlineInputBorder(),
                  ),
                  items: details.map((d) {
                    final kode = d.pengadaanId ?? '-';
                    return DropdownMenuItem(value: d, child: Text(kode));
                  }).toList(),
                  onChanged: (val) {
                    setState(() => selectedDetail = val);

                    if (val != null) {
                      _loadBarangByDetail(val.id);
                    }
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            if (loadingBarang) const LinearProgressIndicator(),

            if (asetForms.isNotEmpty) ...[
              _title('Data Aset (${asetForms.length} Unit)'),
              const SizedBox(height: 12),

              ...List.generate(asetForms.length, (index) {
                final item = asetForms[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Aset ${index + 1} - ${item.barang.nama} (${item.barang.kode})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 12),

                        // FOTO
                        InkWell(
                          onTap: () => _pickImage(item),
                          child: Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                              image: item.gambar != null
                                  ? DecorationImage(
                                      image: FileImage(item.gambar!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: item.gambar == null
                                ? const Center(child: Text('Pilih Foto'))
                                : null,
                          ),
                        ),

                        const SizedBox(height: 12),

                        _dropdown<KondisiAset>(
                          label: 'Kondisi',
                          future: kondisiFuture,
                          value: item.kondisi,
                          getLabel: (e) => e.nama,
                          onChanged: (val) =>
                              setState(() => item.kondisi = val),
                        ),

                        _dropdown<Ruangan>(
                          label: 'Ruangan',
                          future: ruanganFuture,
                          value: item.ruangan,
                          getLabel: (e) => e.nama,
                          onChanged: (val) =>
                              setState(() => item.ruangan = val),
                        ),

                        _dropdown<Divisi>(
                          label: 'Divisi',
                          future: divisiFuture,
                          value: item.divisi,
                          getLabel: (e) => e.nama,
                          onChanged: (val) => setState(() => item.divisi = val),
                        ),

                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Nomor Seri',
                            border: OutlineInputBorder(),
                            hintText: 'Masukkan nomor seri aset',
                          ),
                          initialValue: item.nomorSeri,
                          onChanged: (val) =>
                              setState(() => item.nomorSeri = val),
                        ),
                        const SizedBox(height: 12),
                        InputDatePickerFormField(
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          fieldLabelText: 'Tanggal Akhir Garansi',
                          initialDate:
                              item.tanggalAkhirGaransi ?? DateTime.now(),
                          onDateSubmitted: (date) {
                            setState(() {
                              item.tanggalAkhirGaransi = date;
                            });
                          },
                          onDateSaved: (date) {
                            setState(() {
                              item.tanggalAkhirGaransi = date;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : _submit,
                  icon: const Icon(Icons.save),
                  label: loading
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Text('Simpan Semua Aset'),
                ),
              ),
            ],
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
            initialValue: value,
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
