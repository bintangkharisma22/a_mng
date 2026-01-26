import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/pengadaan.dart';
import '../../models/supplier.dart';
import '../../models/kategori.dart';
import '../../services/pengadaan_service.dart';
import '../../services/supplier_service.dart';
import '../../services/kategori_service.dart';

class PengadaanFormPage extends StatefulWidget {
  final Pengadaan? pengadaan;

  const PengadaanFormPage({super.key, this.pengadaan});

  @override
  State<PengadaanFormPage> createState() => _PengadaanFormPageState();
}

class _PengadaanFormPageState extends State<PengadaanFormPage> {
  final _formKey = GlobalKey<FormState>();

  final kodeController = TextEditingController();
  final catatanController = TextEditingController();

  Supplier? selectedSupplier;
  DateTime? tanggalPembelian;
  DateTime? tanggalPengirimanRencana;

  late Future<List<Supplier>> supplierFuture;
  late Future<List<Kategori>> kategoriFuture;

  // Sekarang barang adalah list BarangTmpInput (multiple barang)
  List<BarangTmpInput> barangList = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();

    supplierFuture = SupplierService.getSupplier();
    kategoriFuture = KategoriService.getKategori();

    if (widget.pengadaan != null) {
      _loadExistingData();
    }
  }

  void _loadExistingData() {
    final p = widget.pengadaan!;
    kodeController.text = p.kodePengadaan;
    catatanController.text = p.catatan ?? '';
    tanggalPembelian = p.tanggalPembelian;
    tanggalPengirimanRencana = p.tanggalPengirimanRencana;

    // Load barang dari barang_tmp
    if (p.pengadaanDetail != null) {
      for (var detail in p.pengadaanDetail!) {
        if (detail.barangTmp != null) {
          for (var tmp in detail.barangTmp!) {
            barangList.add(
              BarangTmpInput(
                nama: tmp.nama,
                kode: tmp.kode,
                kategoriId: tmp.kategoriId,
                spesifikasi: tmp.spesifikasi,
                satuan: tmp.satuan,
                jumlah: tmp.jumlah,
                harga: tmp.harga,
              ),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.pengadaan != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Pengadaan' : 'Tambah Pengadaan'),
      ),
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
                    _sectionTitle('Informasi Pengadaan'),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: kodeController,
                      decoration: const InputDecoration(
                        labelText: 'Kode Pengadaan',
                        prefixIcon: Icon(Icons.qr_code),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Kode wajib diisi' : null,
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Supplier>>(
                      future: supplierFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const LinearProgressIndicator();
                        }

                        final suppliers = snapshot.data!;

                        return DropdownButtonFormField<Supplier>(
                          initialValue: selectedSupplier,
                          decoration: const InputDecoration(
                            labelText: 'Supplier',
                            prefixIcon: Icon(Icons.business),
                          ),
                          items: suppliers
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s.nama),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => selectedSupplier = v),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Tanggal Pembelian',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          tanggalPembelian != null
                              ? DateFormat(
                                  'dd MMMM yyyy',
                                  'id_ID',
                                ).format(tanggalPembelian!)
                              : 'Pilih tanggal',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Rencana Pengiriman',
                          prefixIcon: Icon(Icons.local_shipping),
                        ),
                        child: Text(
                          tanggalPengirimanRencana != null
                              ? DateFormat(
                                  'dd MMMM yyyy',
                                  'id_ID',
                                ).format(tanggalPengirimanRencana!)
                              : 'Pilih tanggal',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: catatanController,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (opsional)',
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // List Barang
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _sectionTitle('Daftar Barang')),
                        ElevatedButton.icon(
                          onPressed: _addBarang,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Tambah'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (barangList.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Belum ada barang',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...barangList.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return _buildBarangCard(item, index);
                      }),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Summary
            if (barangList.isNotEmpty)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Barang:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${barangList.length} item',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Jumlah:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${_getTotalJumlah()} pcs',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Harga:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Rp ${_formatNumber(_getTotalHarga())}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

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
                    : const Icon(Icons.save),
                label: Text(
                  loading
                      ? 'Menyimpan...'
                      : (isEdit ? 'Update Pengadaan' : 'Simpan Pengadaan'),
                ),
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

  Widget _buildBarangCard(BarangTmpInput item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kode: ${item.kode}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                  onPressed: () => _editBarang(index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      barangList.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            if (item.spesifikasi != null && item.spesifikasi!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.spesifikasi!,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
            const Divider(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Jumlah', style: TextStyle(fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        '${item.jumlah} ${item.satuan ?? "pcs"}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Harga Satuan',
                        style: TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.harga != null
                            ? 'Rp ${_formatNumber(item.harga!)}'
                            : '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (item.harga != null) ...[
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 12)),
                  Text(
                    'Rp ${_formatNumber(item.jumlah * item.harga!)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatNumber(double number) {
    final formatter = NumberFormat('#,##0', 'id_ID');
    return formatter.format(number);
  }

  int _getTotalJumlah() {
    return barangList.fold(0, (sum, item) => sum + item.jumlah);
  }

  double _getTotalHarga() {
    return barangList.fold(
      0.0,
      (sum, item) => sum + (item.harga != null ? item.jumlah * item.harga! : 0),
    );
  }

  void _selectDate(BuildContext context, bool isPembelian) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (date != null) {
      setState(() {
        if (isPembelian) {
          tanggalPembelian = date;
        } else {
          tanggalPengirimanRencana = date;
        }
      });
    }
  }

  void _addBarang() {
    showDialog(
      context: context,
      builder: (_) => _BarangDialog(
        kategoriFuture: kategoriFuture,
        onSave: (item) {
          setState(() {
            barangList.add(item);
          });
        },
      ),
    );
  }

  void _editBarang(int index) {
    showDialog(
      context: context,
      builder: (_) => _BarangDialog(
        kategoriFuture: kategoriFuture,
        initialData: barangList[index],
        onSave: (item) {
          setState(() {
            barangList[index] = item;
          });
        },
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (barangList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal harus ada 1 barang'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final body = {
        'pengadaan': {
          'kode_pengadaan': kodeController.text,
          if (selectedSupplier != null) 'supplier_id': selectedSupplier!.id,
          if (tanggalPembelian != null)
            'tanggal_pembelian': tanggalPembelian!.toIso8601String().split(
              'T',
            )[0],
          if (tanggalPengirimanRencana != null)
            'tanggal_pengiriman_rencana': tanggalPengirimanRencana!
                .toIso8601String()
                .split('T')[0],
          if (catatanController.text.isNotEmpty)
            'catatan': catatanController.text,
        },
        'detail': [
          {'items': barangList.map((b) => b.toJson()).toList()},
        ],
      };

      if (widget.pengadaan == null) {
        await PengadaanService.create(body);
      } else {
        // Cast ke Map<String, dynamic>
        final pengadaanData = body['pengadaan'] as Map<String, dynamic>;
        await PengadaanService.update(widget.pengadaan!.id, pengadaanData);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengadaan berhasil disimpan'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => loading = false);
    }
  }
}

// Helper class untuk input barang
class BarangTmpInput {
  String nama;
  String kode;
  String? kategoriId;
  String? spesifikasi;
  String? satuan;
  int jumlah;
  double? harga;

  BarangTmpInput({
    required this.nama,
    required this.kode,
    this.kategoriId,
    this.spesifikasi,
    this.satuan,
    this.jumlah = 1,
    this.harga,
  });

  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'kode': kode,
      if (kategoriId != null) 'kategori_id': kategoriId,
      if (spesifikasi != null) 'spesifikasi': spesifikasi,
      if (satuan != null) 'satuan': satuan,
      'jumlah': jumlah,
      if (harga != null) 'harga': harga,
    };
  }
}

// Dialog untuk tambah/edit barang
class _BarangDialog extends StatefulWidget {
  final Future<List<Kategori>> kategoriFuture;
  final BarangTmpInput? initialData;
  final Function(BarangTmpInput) onSave;

  const _BarangDialog({
    required this.kategoriFuture,
    this.initialData,
    required this.onSave,
  });

  @override
  State<_BarangDialog> createState() => _BarangDialogState();
}

class _BarangDialogState extends State<_BarangDialog> {
  final formKey = GlobalKey<FormState>();
  final namaController = TextEditingController();
  final kodeController = TextEditingController();
  final spesifikasiController = TextEditingController();
  final satuanController = TextEditingController();
  final jumlahController = TextEditingController();
  final hargaController = TextEditingController();

  String? selectedKategoriId;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      final data = widget.initialData!;
      namaController.text = data.nama;
      kodeController.text = data.kode;
      spesifikasiController.text = data.spesifikasi ?? '';
      satuanController.text = data.satuan ?? '';
      jumlahController.text = data.jumlah.toString();
      hargaController.text = data.harga?.toString() ?? '';
      selectedKategoriId = data.kategoriId;
    } else {
      jumlahController.text = '1';
      satuanController.text = 'unit';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialData == null ? 'Tambah Barang' : 'Edit Barang'),
      content: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(labelText: 'Nama Barang'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: kodeController,
                decoration: const InputDecoration(labelText: 'Kode Barang'),
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Kategori>>(
                future: widget.kategoriFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator();
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: selectedKategoriId,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: snapshot.data!
                        .map(
                          (k) => DropdownMenuItem(
                            value: k.id,
                            child: Text(k.nama),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => selectedKategoriId = v),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: spesifikasiController,
                decoration: const InputDecoration(labelText: 'Spesifikasi'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: satuanController,
                decoration: const InputDecoration(labelText: 'Satuan'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: jumlahController,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  if (int.tryParse(v) == null || int.parse(v) <= 0) {
                    return 'Harus angka > 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: hargaController,
                decoration: const InputDecoration(
                  labelText: 'Harga Satuan (opsional)',
                  prefixText: 'Rp ',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!formKey.currentState!.validate()) return;

            final item = BarangTmpInput(
              nama: namaController.text,
              kode: kodeController.text,
              kategoriId: selectedKategoriId,
              spesifikasi: spesifikasiController.text.isEmpty
                  ? null
                  : spesifikasiController.text,
              satuan: satuanController.text.isEmpty
                  ? null
                  : satuanController.text,
              jumlah: int.parse(jumlahController.text),
              harga: hargaController.text.isEmpty
                  ? null
                  : double.parse(hargaController.text),
            );

            widget.onSave(item);
            Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
