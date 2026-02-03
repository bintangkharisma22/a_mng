import 'dart:io';
import 'package:a_mng/models/barang.dart';
import 'package:a_mng/services/barang_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pengadaan.dart';
import '../../core/session.dart';
import '../../services/pengadaan_service.dart';

class PengadaanDetailPage extends StatefulWidget {
  final String id;
  const PengadaanDetailPage({super.key, required this.id});

  @override
  State<PengadaanDetailPage> createState() => _PengadaanDetailPageState();
}

class _PengadaanDetailPageState extends State<PengadaanDetailPage> {
  Pengadaan? data;
  bool loading = true;
  String? role;
  List<Barang> dataBarang = [];

  Map<String, File> gambarMapByNama = {};

  @override
  void initState() {
    super.initState();
    loadRole();
    loadData();
  }

  Future<void> loadRole() async {
    role = await SessionManager.getUserRole();
    setState(() {});
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    try {
      final result = await PengadaanService.getDetail(widget.id);
      setState(() => data = result);
      final barang = await BarangService.getByPgDetail(widget.id);
      debugPrint('✅ Barang fetched: ${barang.length} items');
      debugPrint(
        '📦 First item: ${barang.isNotEmpty ? barang[0].nama : "empty"}',
      );
      setState(() => dataBarang = barang);
    } catch (e, stackTrace) {
      debugPrint('Error: $e');
      debugPrint('$stackTrace');
    } finally {
      setState(() => loading = false);
    }
  }

  bool get isManager => role == 'manager';
  bool get isAdmin => role == 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pengadaan')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? const Center(child: Text('Data tidak ditemukan'))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final p = data!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _infoCard(p),
        const SizedBox(height: 16),
        _detailBarang(p),
        const SizedBox(height: 24),
        if ((isManager || isAdmin) && p.status == 'diajukan')
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text('Setujui'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _approvePengadaan(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('Tolak'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => _updateStatus('ditolak'),
                ),
              ),
            ],
          ),
        if ((isManager || isAdmin) && p.status == 'disetujui') ...[
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.inventory_2),
            label: const Text('FINALIZE → Buat Aset'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () => dataBarang.isEmpty ? null : _openFinalizeDialog(),
          ),
        ],
      ],
    );
  }

  Future<void> _openFinalizeDialog() async {
    final dataBarangs = dataBarang;
    final Set<String> namaBarangSet = {};

    for (final item in dataBarangs) {
      namaBarangSet.add(item.nama);
    }

    final List<String> namaBarangList = namaBarangSet.toList();

    debugPrint('🔍 Dialog opened with ${namaBarangList.length} unique items');

    await showDialog(
      context: context,
      builder: (dialogContext) {
        // ✅ StatefulBuilder untuk rebuild dialog
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Finalize Pengadaan'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: namaBarangList.map((nama) {
                    final file = gambarMapByNama[nama];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(nama),
                        subtitle: file == null
                            ? const Text('Belum ada gambar map')
                            : Text(
                                '✅ ${file.path.split('/').last}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                        trailing: IconButton(
                          icon: Icon(
                            file == null
                                ? Icons.upload_file
                                : Icons.check_circle,
                            color: file == null ? Colors.grey : Colors.green,
                            size: 28,
                          ),
                          onPressed: () async {
                            debugPrint('📸 Tombol upload ditekan untuk: $nama');

                            // ✅ Panggil pick image
                            final picked = await _pickMapImageAndReturn(nama);

                            if (picked != null) {
                              debugPrint(
                                '✅ Gambar berhasil dipilih, updating UI...',
                              );

                              // ✅ Update state dialog
                              setDialogState(() {});

                              // ✅ Update state parent
                              setState(() {});

                              // ✅ Tampilkan snackbar konfirmasi
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '✅ Gambar dipilih untuk $nama',
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _finalizePengadaan();
                  },
                  child: const Text('FINALIZE SEKARANG'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ✅ Method baru yang return File
  Future<File?> _pickMapImageAndReturn(String namaBarang) async {
    final picker = ImagePicker();

    try {
      debugPrint('🔍 Membuka galeri untuk: $namaBarang');

      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (picked != null) {
        final file = File(picked.path);

        // Cek file exists
        final exists = await file.exists();
        final size = await file.length();

        debugPrint('📸 File picked: ${picked.path}');
        debugPrint('📸 File exists: $exists');
        debugPrint('📸 File size: $size bytes');

        if (exists && size > 0) {
          // ✅ Simpan ke map
          gambarMapByNama[namaBarang] = file;

          debugPrint('✅ Gambar berhasil disimpan untuk: $namaBarang');
          debugPrint('📦 Total gambar di map: ${gambarMapByNama.length}');
          debugPrint('📦 Keys: ${gambarMapByNama.keys.toList()}');

          return file;
        } else {
          debugPrint('❌ File tidak valid atau kosong');
          return null;
        }
      } else {
        debugPrint('❌ User membatalkan pilih gambar');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Error picking image: $e');
      debugPrint('Stack: $stackTrace');
      return null;
    }
  }

  Future<void> _finalizePengadaan() async {
    debugPrint('🚀 Starting finalize...');
    debugPrint('📦 Gambar yang akan diupload: ${gambarMapByNama.length}');
    debugPrint('📦 Detail: ${gambarMapByNama.keys.toList()}');

    if (gambarMapByNama.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimal 1 gambar_map harus diupload'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await PengadaanService.finalize(widget.id, gambarMapByNama);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Finalisasi berhasil, aset telah dibuat'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // balik ke list
    } catch (e) {
      debugPrint('❌ Error finalize: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Widget _infoCard(Pengadaan p) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.kodePengadaan,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                _statusChip(p.status ?? 'draft'),
              ],
            ),
            const Divider(height: 24),
            if (p.supplier != null)
              _infoRow(Icons.business, 'Supplier', p.supplier!.nama),
            if (p.tanggalPembelian != null)
              _infoRow(
                Icons.calendar_today,
                'Tanggal Pembelian',
                DateFormat('dd MMMM yyyy', 'id_ID').format(p.tanggalPembelian!),
              ),
            if (p.catatan != null) ...[
              const SizedBox(height: 8),
              _infoRow(Icons.note, 'Catatan', p.catatan!),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Barang',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${p.totalBarang} item',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Harga',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rp ${NumberFormat('#,##0', 'id_ID').format(p.totalHarga)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'disetujui':
        color = Colors.green;
        break;
      case 'ditolak':
        color = Colors.red;
        break;
      case 'diajukan':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailBarang(Pengadaan p) {
    final details = p.pengadaanDetail ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detail Barang',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            if (details.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Tidak ada detail barang'),
                ),
              )
            else
              ...details.expand((detail) {
                // Tampilkan barang_tmp
                final barangTmpList = detail.barangTmp ?? [];
                return barangTmpList.map((tmp) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.grey.shade50,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        tmp.nama,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text('Kode: ${tmp.kode}'),
                          if (tmp.spesifikasi != null &&
                              tmp.spesifikasi!.isNotEmpty)
                            Text('Spesifikasi: ${tmp.spesifikasi}'),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Jumlah: ${tmp.jumlah} ${tmp.satuan ?? "pcs"}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              if (tmp.harga != null)
                                Text(
                                  'Rp ${NumberFormat('#,##0', 'id_ID').format(tmp.harga)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                          if (tmp.harga != null) ...[
                            const Divider(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text('Total: '),
                                Text(
                                  'Rp ${NumberFormat('#,##0', 'id_ID').format(tmp.totalHarga)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      trailing: tmp.status != 'draft'
                          ? Chip(
                              label: Text(
                                tmp.status,
                                style: const TextStyle(fontSize: 10),
                              ),
                              padding: EdgeInsets.zero,
                              backgroundColor: tmp.status == 'dipindah'
                                  ? Colors.green.shade100
                                  : Colors.blue.shade100,
                            )
                          : null,
                    ),
                  );
                });
              }),
          ],
        ),
      ),
    );
  }

  Future<void> _approvePengadaan() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Setujui Pengadaan'),
        content: const Text(
          'Barang akan dipindahkan ke master data barang. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Setujui'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await PengadaanService.approve(widget.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengadaan berhasil disetujui'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateStatus(String status) async {
    try {
      await PengadaanService.updateStatus(widget.id, status: status);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }
}
