import 'package:flutter/material.dart';
import 'laporan_aset.dart';
import 'laporan_peminjaman.dart';
import 'laporan_maintenance.dart';

class LaporanMenuPage extends StatelessWidget {
  const LaporanMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laporan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.65,
          children: [
            _buildMenuCard(
              context,
              title: 'Laporan Aset',
              icon: Icons.inventory_2,
              color: Colors.blue,
              description:
                  'Laporan data aset dengan filter kategori, divisi, ruangan, kondisi, dan status',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaporanAsetPage(),
                  ),
                );
              },
            ),
            _buildMenuCard(
              context,
              title: 'Laporan Peminjaman',
              icon: Icons.book_outlined,
              color: Colors.green,
              description:
                  'Laporan peminjaman aset dengan filter kategori, status, dan rentang tanggal',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaporanPeminjamanPage(),
                  ),
                );
              },
            ),
            _buildMenuCard(
              context,
              title: 'Laporan Maintenance',
              icon: Icons.build,
              color: Colors.orange,
              description:
                  'Laporan maintenance aset dengan filter kategori dan status',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaporanMaintenancePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
