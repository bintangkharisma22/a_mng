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

      body: _dashboard(theme),
      bottomNavigationBar: _buildBottomBar(context),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fitur Scan QR segera hadir')),
          );
        },
        child: const Icon(Icons.qr_code_scanner),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
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
          Text(
            'Ringkasan Kondisi Aset',
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

  Drawer _buildDrawer(BuildContext context) {
    return Drawer(
      child: SafeArea(
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

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _drawerItem(Icons.dashboard, 'Dashboard', () {
                      Navigator.pop(context);
                    }),

                    _drawerItem(Icons.inventory_2, 'Aset', () {
                      Navigator.pushNamed(context, AppRoute.aset);
                    }),

                    _drawerItem(Icons.local_shipping, 'Pengadaan', () {
                      Navigator.pushNamed(context, AppRoute.pengadaan);
                    }),

                    ExpansionTile(
                      leading: const Icon(Icons.storage),
                      title: const Text('Master Data'),
                      children: [
                        _subDrawerItem('Ruangan', () {
                          Navigator.pushNamed(context, AppRoute.ruangan);
                        }),
                        _subDrawerItem('Divisi', () {
                          Navigator.pushNamed(context, AppRoute.divisi);
                        }),
                        _subDrawerItem('Kategori', () {
                          Navigator.pushNamed(context, AppRoute.kategori);
                        }),
                        _subDrawerItem('Supplier', () {
                          Navigator.pushNamed(context, AppRoute.supplier);
                        }),
                      ],
                    ),

                    _drawerItem(Icons.people, 'User', () {}),
                  ],
                ),
              ),
            ),

            const Divider(),

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
      ),
    );
  }

  ListTile _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(label), onTap: onTap);
  }

  ListTile _subDrawerItem(String label, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 72),
      title: Text(label),
      onTap: onTap,
    );
  }
}
