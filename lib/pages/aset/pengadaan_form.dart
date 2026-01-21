import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/pengadaan.dart';
import '../../models/pengadaan_detail.dart';
import '../../models/supplier.dart';
import '../../models/barang.dart';
import '../../services/pengadaan_service.dart';
import '../../services/supplier_service.dart';
import '../../services/barang_service.dart';

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
  late Future<List<Barang>> barangFuture;

  List<PengadaanDetailInput> detailItems = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();

    supplierFuture = SupplierService.getSupplier();
    barangFuture = BarangService.getBarang();

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

    if (p.pengadaanDetail != null) {
      detailItems = p.pengadaanDetail!
          .map(
            (d) => PengadaanDetailInput(
              barang: d.barang,
              jumlah: d.jumlah,
              hargaSatuan: d.hargaSatuan,
            ),
          )
          .toList();
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
                          value: selectedSupplier,
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

            // Detail Items
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _sectionTitle('Detail Barang')),
                        ElevatedButton.icon(
                          onPressed: _addDetailItem,
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
                    if (detailItems.isEmpty)
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
                      ...detailItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return _buildDetailItem(item, index);
                      }),
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

  Widget _buildDetailItem(PengadaanDetailInput item, int index) {
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
                  child: Text(
                    item.barang?.nama ?? 'Pilih barang',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() {
                      detailItems.removeAt(index);
                    });
                  },
                ),
              ],
            ),
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
                        '${item.jumlah} pcs',
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
                        item.hargaSatuan != null
                            ? 'Rp ${_formatNumber(item.hargaSatuan!)}'
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
            if (item.hargaSatuan != null) ...[
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontSize: 12)),
                  Text(
                    'Rp ${_formatNumber(item.jumlah * item.hargaSatuan!)}',
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

  void _addDetailItem() {
    showDialog(
      context: context,
      builder: (_) => _DetailItemDialog(
        barangFuture: barangFuture,
        onSave: (item) {
          setState(() {
            detailItems.add(item);
          });
        },
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (detailItems.isEmpty) {
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
      final pengadaan = Pengadaan(
        id: widget.pengadaan?.id ?? '',
        kodePengadaan: kodeController.text,
        supplierId: selectedSupplier?.id,
        tanggalPembelian: tanggalPembelian,
        tanggalPengirimanRencana: tanggalPengirimanRencana,
        catatan: catatanController.text.isEmpty ? null : catatanController.text,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final detail = detailItems
          .map(
            (item) => PengadaanDetail(
              id: '',
              barangId: item.barang!.id,
              jumlah: item.jumlah,
              hargaSatuan: item.hargaSatuan,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
          )
          .toList();

      if (widget.pengadaan == null) {
        await PengadaanService.create(pengadaan: pengadaan, detail: detail);
      } else {
        await PengadaanService.update(widget.pengadaan!.id, pengadaan.toJson());
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

// Helper class
class PengadaanDetailInput {
  Barang? barang;
  int jumlah;
  double? hargaSatuan;
  PengadaanDetailInput({this.barang, this.jumlah = 1, this.hargaSatuan});
}

// Dialog untuk tambah detail
class _DetailItemDialog extends StatefulWidget {
  final Future<List<Barang>> barangFuture;
  final Function(PengadaanDetailInput) onSave;
  const _DetailItemDialog({required this.barangFuture, required this.onSave});
  @override
  State<_DetailItemDialog> createState() => _DetailItemDialogState();
}

class _DetailItemDialogState extends State<_DetailItemDialog> {
  final jumlahController = TextEditingController(text: '1');
  final hargaController = TextEditingController();
  Barang? selectedBarang;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Barang'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<List<Barang>>(
              future: widget.barangFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
                }
                return DropdownButtonFormField<Barang>(
                  value: selectedBarang,
                  decoration: const InputDecoration(labelText: 'Barang'),
                  items: snapshot.data!
                      .map(
                        (b) => DropdownMenuItem(value: b, child: Text(b.nama)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedBarang = v),
                  validator: (v) => v == null ? 'Pilih barang' : null,
                );
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: jumlahController,
              decoration: const InputDecoration(labelText: 'Jumlah'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            if (selectedBarang == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pilih barang terlebih dahulu')),
              );
              return;
            }

            final item = PengadaanDetailInput(
              barang: selectedBarang,
              jumlah: int.tryParse(jumlahController.text) ?? 1,
              hargaSatuan: hargaController.text.isEmpty
                  ? null
                  : double.tryParse(hargaController.text),
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
