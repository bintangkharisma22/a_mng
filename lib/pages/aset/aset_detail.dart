import 'package:a_mng/models/riwayat_kondisi_aset.dart';
import 'package:a_mng/pages/aset/aset_update_form.dart';
import 'package:a_mng/pages/aset/pemindahan.dart';
import 'package:a_mng/pages/aset/peminjaman_aset.dart';
import 'package:a_mng/pages/maintenance/maintenance.dart';
import 'package:a_mng/services/aset_detail_service.dart';
import 'package:flutter/material.dart';
import 'package:a_mng/models/aset.dart';
import 'package:a_mng/services/aset_service.dart';
import 'package:a_mng/core/config.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

import '../../core/session.dart';

class DetailAsetPage extends StatefulWidget {
  const DetailAsetPage({super.key});

  @override
  State<DetailAsetPage> createState() => _DetailAsetPageState();
}

class _DetailAsetPageState extends State<DetailAsetPage> {
  late Future<Aset> future;
  String? role;
  bool _isDownloading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as String;
    future = AsetService.getDetail(id);
    _checkRole();
  }

  void _checkRole() async {
    final r = await SessionManager.getUserRole();
    setState(() {
      role = r;
    });
  }

  bool isAdmin() {
    return role == 'admin';
  }

  Future<void> _downloadQrCode(String? qrCodePath, String kodeAset) async {
    if (qrCodePath == null || qrCodePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code tidak tersedia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      // URL lengkap QR code
      final qrUrl = '${Config.bucketUrl}$qrCodePath';

      // Download file
      final response = await http.get(Uri.parse(qrUrl));

      if (response.statusCode == 200) {
        // Dapatkan direktori temporary
        final directory = await getTemporaryDirectory();

        // Buat nama file dengan kode aset
        final fileName = 'QR_${kodeAset.replaceAll('/', '_')}.png';
        final filePath = '${directory.path}/$fileName';

        // Simpan file
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        await Share.shareXFiles([
          XFile(filePath),
        ], text: 'QR Code Aset: $kodeAset');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('QR Code berhasil diunduh'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Gagal mengunduh QR Code');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengunduh QR Code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Aset')),
      floatingActionButton: isAdmin()
          ? FloatingActionButton(
              onPressed: () {
                final asetId =
                    ModalRoute.of(context)!.settings.arguments as String;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AsetEditPage(asetId: asetId),
                  ),
                ).then((_) {
                  setState(() {
                    final id =
                        ModalRoute.of(context)!.settings.arguments as String;
                    future = AsetService.getDetail(id);
                  });
                });
              },
              child: const Icon(Icons.edit),
            )
          : null,
      body: FutureBuilder<Aset>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat detail aset'));
          }

          final aset = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                future = AsetService.getDetail(aset.id);
              });
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _header(aset),
                const SizedBox(height: 16),
                _infoCard(aset),
                const SizedBox(height: 16),
                _menuAksi(aset),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _header(Aset aset) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // FOTO ASET
            if (aset.gambar != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  '${Config.bucketUrl}${aset.gambar}',
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.inventory_2, size: 64, color: Colors.grey),
                ),
              ),

            const SizedBox(height: 12),

            // KODE ASET
            Text(
              aset.kodeAset ?? '-',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statusBadge(aset.status ?? '-'),
                const SizedBox(width: 10),
                _kondisiBadge(aset.kondisi?.nama ?? '-'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(Aset aset) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row('Nomor Seri', aset.nomorSeri ?? '-'),
            _row('Kategori', aset.kategori?.nama ?? '-'),
            _row('Ruangan', aset.ruangan?.nama ?? '-'),
            _row('Divisi', aset.divisi?.nama ?? '-'),
            _row('Harga', aset.hargaPembelian?.toString() ?? '-'),
            _row(
              'Tgl Penerimaan',
              aset.tanggalPenerimaan != null
                  ? aset.tanggalPenerimaan!.toIso8601String().substring(0, 10)
                  : '-',
            ),
            _row(
              'Garansi',
              aset.tanggalAkhirGaransi != null
                  ? aset.tanggalAkhirGaransi!.toIso8601String().substring(0, 10)
                  : '-',
            ),
            const SizedBox(height: 16),

            // QR Code Preview (jika ada)
            if (aset.qrCode != null && aset.qrCode!.isNotEmpty)
              Column(
                children: [
                  const Text(
                    'QR Code Aset',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Image.network(
                      '${Config.bucketUrl}${aset.qrCode}',
                      height: 150,
                      width: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 150,
                          width: 150,
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.qr_code,
                            size: 64,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),

            // Download QR Code Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isDownloading
                    ? null
                    : () =>
                          _downloadQrCode(aset.qrCode, aset.kodeAset ?? 'aset'),
                icon: _isDownloading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(
                  _isDownloading ? 'Mengunduh...' : 'Download QR Code',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          const Text(':  '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuAksi(Aset aset) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Aset',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            _actionButton(
              icon: Icons.history,
              label: 'Riwayat',
              onTap: () {
                _showRiwayatKondisiModal(aset.id);
              },
            ),
            _actionButton(
              icon: Icons.build,
              label: 'Maintenance',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MaintenancePage()),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _actionButton(
              icon: Icons.swap_horiz,
              label: 'Pindah',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PemindahanAsetPage()),
                );
              },
            ),
            _actionButton(
              icon: Icons.person,
              label: 'Pinjam',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PeminjamanPage()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, size: 28),
                const SizedBox(height: 8),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;

    switch (status.toLowerCase()) {
      case 'aktif':
      case 'tersedia':
        color = Colors.green;
        break;
      case 'rusak':
        color = Colors.red;
        break;
      case 'dipinjam':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  void _showRiwayatKondisiModal(String asetId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Column(
              children: [
                // HEADER
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [Icon(Icons.drag_handle)],
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Riwayat Kondisi Aset',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const Divider(),

                // CONTENT
                Expanded(
                  child: FutureBuilder(
                    future: AsetDetailService.getRiwayatKondisi(asetId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return const Center(
                          child: Text('Gagal memuat riwayat kondisi'),
                        );
                      }

                      final data = snapshot.data as List<RiwayatKondisiAset>;

                      if (data.isEmpty) {
                        return const Center(
                          child: Text('Belum ada riwayat kondisi'),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: data.length,
                        itemBuilder: (context, i) {
                          final r = data[i];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: _kondisiIcon(r.kondisi?.nama),
                              title: Text(
                                r.kondisi?.nama ?? '-',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.tanggalPerubahan
                                        .toIso8601String()
                                        .substring(0, 10),
                                  ),
                                  if (r.catatan != null &&
                                      r.catatan!.isNotEmpty)
                                    Text('Catatan: ${r.catatan}'),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _kondisiIcon(String? kondisi) {
    IconData icon;
    Color color;

    switch (kondisi?.toLowerCase()) {
      case 'baik':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'rusak':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case 'perlu perbaikan':
        icon = Icons.build;
        color = Colors.orange;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color),
    );
  }

  Widget _kondisiBadge(String kondisi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        kondisi,
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
