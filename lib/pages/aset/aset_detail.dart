import 'package:flutter/material.dart';
import 'package:a_mng/models/aset.dart';
import 'package:a_mng/services/aset_service.dart';
import 'package:a_mng/core/config.dart';

class DetailAsetPage extends StatefulWidget {
  const DetailAsetPage({super.key});

  @override
  State<DetailAsetPage> createState() => _DetailAsetPageState();
}

class _DetailAsetPageState extends State<DetailAsetPage> {
  late Future<Aset> future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as String;
    future = AsetService.getDetail(id);
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Aset')),
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
              aset.kodeAset,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _statusBadge(aset.status as String),
                const SizedBox(width: 10),
                _kondisiBadge(aset.kondisi.nama),
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
            _row('Kategori', aset.kategori.nama),
            _row('Ruangan', aset.ruangan.nama),
            _row('Divisi', aset.divisi.nama),
            _row('Harga', aset.hargaPembelian?.toString() ?? '-'),
            _row(
              'Tgl Beli',
              aset.tanggalPembelian != null
                  ? aset.tanggalPembelian!.toIso8601String().substring(0, 10)
                  : '-',
            ),
            _row(
              'Garansi',
              aset.tanggalAkhirGaransi != null
                  ? aset.tanggalAkhirGaransi!.toIso8601String().substring(0, 10)
                  : '-',
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
                // Navigator.push ke riwayat kondisi
              },
            ),
            _actionButton(
              icon: Icons.build,
              label: 'Maintenance',
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _actionButton(
              icon: Icons.swap_horiz,
              label: 'Pindah',
              onTap: () {},
            ),
            _actionButton(icon: Icons.person, label: 'Pinjam', onTap: () {}),
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
        color: color.withOpacity(0.15),
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

  Widget _kondisiBadge(String kondisi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.15),
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
