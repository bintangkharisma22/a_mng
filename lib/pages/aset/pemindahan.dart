import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pemindahan_aset.dart';
import '../../services/pemindahan_service.dart';
import '../../core/session.dart';

import '../../core/routes.dart';

class PemindahanAsetPage extends StatefulWidget {
  const PemindahanAsetPage({super.key});

  @override
  State<PemindahanAsetPage> createState() => _PemindahanAsetPageState();
}

class _PemindahanAsetPageState extends State<PemindahanAsetPage> {
  late Future<List<PemindahanAset>> future;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
    _refresh();
  }

  Future<void> _checkRole() async {
    final role = await SessionManager.getUserRole();
    setState(() {
      isAdmin = role == 'admin';
    });
  }

  void _refresh() {
    setState(() {
      future = PemindahanService.getAllPemindahan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pemindahan Aset')),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoute.tambahPemindahanAset,
                ).then((_) => _refresh());
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: FutureBuilder<List<PemindahanAset>>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refresh,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data ?? [];

            if (data.isEmpty) {
              return const Center(child: Text('Belum ada riwayat pemindahan'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: data.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final pemindahan = data[index];
                return _pemindahanCard(pemindahan);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _pemindahanCard(PemindahanAset pemindahan) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.swap_horiz, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    pemindahan.aset?.kodeAset ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (pemindahan.tanggalPemindahan != null)
                  Text(
                    DateFormat(
                      'dd MMM yyyy',
                      'id_ID',
                    ).format(pemindahan.tanggalPemindahan!),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
            const Divider(height: 20),

            // Ruangan
            if (pemindahan.dariRuangan != null || pemindahan.keRuangan != null)
              _moveRow(
                icon: Icons.meeting_room,
                label: 'Ruangan',
                dari: pemindahan.dariRuangan?.nama ?? '-',
                ke: pemindahan.keRuangan?.nama ?? '-',
              ),

            const SizedBox(height: 8),

            // Divisi
            if (pemindahan.dariDivisi != null || pemindahan.keDivisi != null)
              _moveRow(
                icon: Icons.business,
                label: 'Divisi',
                dari: pemindahan.dariDivisi?.nama ?? '-',
                ke: pemindahan.keDivisi?.nama ?? '-',
              ),

            if (pemindahan.alasan != null && pemindahan.alasan!.isNotEmpty) ...[
              const Divider(height: 20),
              Row(
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pemindahan.alasan!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        fontStyle: FontStyle.italic,
                      ),
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

  Widget _moveRow({
    required IconData icon,
    required String label,
    required String dari,
    required String ke,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  dari,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.arrow_forward, size: 16),
              ),
              Expanded(
                child: Text(
                  ke,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
