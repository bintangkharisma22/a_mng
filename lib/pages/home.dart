import 'package:flutter/material.dart';
import '../services/dashboard_service.dart';
import '../core/session.dart';
import '../core/routes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  late Future<Map<String, dynamic>> statsFuture;
  late Future<Map<String, dynamic>> kondisiFuture;

  @override
  void initState() {
    super.initState();
    statsFuture = DashboardService.getStats();
    kondisiFuture = DashboardService.getKondisiAset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      drawer: _buildDrawer(context),
      body: currentIndex == 0 ? _dashboard(theme) : _placeholder(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (i) => setState(() => currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Aset',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }

  Widget _dashboard(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          statsFuture = DashboardService.getStats();
          kondisiFuture = DashboardService.getKondisiAset();
        });
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder(
            future: kondisiFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return _emptyInfo(
                  icon: Icons.warning_amber_rounded,
                  title: 'Gagal memuat kondisi aset',
                  subtitle: 'Silakan coba beberapa saat lagi',
                );
              }

              final kondisi = snapshot.data as Map<String, dynamic>;

              if (kondisi.isEmpty) {
                return _emptyInfo(
                  icon: Icons.info_outline,
                  title: 'Belum ada kondisi aset',
                  subtitle:
                      'Kondisi aset akan tampil setelah data aset dimasukkan ke sistem',
                );
              }

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: kondisi.entries.map<Widget>((e) {
                  return Chip(label: Text('${e.key} (${e.value})'));
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 24),

          Text(
            'Kondisi Aset',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          FutureBuilder(
            future: kondisiFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }

              final kondisi = snapshot.data!;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: kondisi.entries.map<Widget>((e) {
                  return Chip(
                    label: Text('${e.key} (${e.value})'),
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _statCard(String title, dynamic value, IconData icon) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32),
            const Spacer(),
            Text(
              value.toString(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _emptyInfo({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Asset Management',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          ),
          _drawerItem(Icons.dashboard, 'Dashboard'),
          _drawerItem(Icons.inventory_2, 'Aset'),
          _drawerItem(Icons.location_on, 'Lokasi'),
          _drawerItem(Icons.people, 'User'),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await SessionManager.clearSession();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, AppRoute.login);
              }
            },
          ),
        ],
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String label) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: () {});
  }

  Widget _placeholder() {
    return const Center(child: Text('Menu dalam pengembangan'));
  }
}
