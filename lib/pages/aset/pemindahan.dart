import 'package:flutter/material.dart';
import '../../models/pemindahan_aset.dart';
import '../../services/pemindahan_service.dart';
import '../../core/session.dart';
import 'pemindahan_form.dart';

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
    setState(() => isAdmin = role == 'admin');
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
              onPressed: () async {
                final result = await Navigator.pushNamed(
                  context,
                  AppRoute.tambahPemindahanAset,
                );
                if (result == true) _refresh();
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
              return Center(child: Text(snapshot.error.toString()));
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
                return _pemindahanCard(data[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _pemindahanCard(PemindahanAset p) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.swap_horiz),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    p.aset?.kodeAset ?? 'N/A',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isAdmin)
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PemindahanAsetFormPage(editData: p),
                        ),
                      );
                      if (result == true) _refresh();
                    },
                  ),
              ],
            ),
            const Divider(),
            if (p.dariRuangan != null || p.keRuangan != null)
              _row('Ruangan', p.dariRuangan?.nama, p.keRuangan?.nama),
            if (p.dariDivisi != null || p.keDivisi != null)
              _row('Divisi', p.dariDivisi?.nama, p.keDivisi?.nama),
            if (p.alasan != null && p.alasan!.isNotEmpty) ...[
              const Divider(),
              Text(
                p.alasan!,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String? dari, String? ke) {
    return Row(
      children: [
        Text('$label: ', style: const TextStyle(fontSize: 13)),
        Expanded(child: Text(dari ?? '-')),
        const Icon(Icons.arrow_forward, size: 14),
        Expanded(
          child: Text(
            ke ?? '-',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
