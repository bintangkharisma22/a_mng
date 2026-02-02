import 'package:a_mng/core/fcm_service.dart';
import 'package:a_mng/services/notification_service.dart';
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
  late Future<int> _unreadCountFuture;
  String? userName;
  String? userRole;
  bool isAdminOrManager = false;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _refresh();
    _loadUnreadCount();
  }

  void _loadUnreadCount() {
    setState(() {
      _unreadCountFuture = NotificationService.getUnreadCount();
    });
  }

  Future<void> _loadUserInfo() async {
    final email = await SessionManager.getUserEmail();
    final role = await SessionManager.getUserRole();
    final adminOrManager =
        await SessionManager.isAdminOrManager(); // ✅ Cek role
    final admin = await SessionManager.isAdmin();
    setState(() {
      userName = email.split('@')[0];
      userRole = role ?? 'Staff';
      isAdminOrManager = adminOrManager; // ✅ Set state
      isAdmin = admin;
    });
  }

  void _refresh() {
    setState(() {
      statsFuture = DashboardService.getStats();
      kondisiFuture = DashboardService.getKondisiAset();
      _loadUnreadCount();
    });
  }

  void _logout() async {
    await FcmService.deleteTokenFromServer();
    await SessionManager.clearSession();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, AppRoute.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          FutureBuilder<int>(
            future: _unreadCountFuture,
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () async {
                      await Navigator.pushNamed(
                        context,
                        AppRoute.notificationPage,
                      );
                      _loadUnreadCount();
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          count > 99 ? '99+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, theme),
      body: _buildDashboard(theme),
      floatingActionButton: isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.pushNamed(context, AppRoute.scanQr);
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scan QR'),
              backgroundColor: theme.colorScheme.secondary,
            )
          : null,
    );
  }

  Widget _buildDashboard(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async => _refresh(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _greetingCard(theme),
          const SizedBox(height: 20),
          _sectionTitle('Aksi Cepat', theme),
          const SizedBox(height: 12),
          _quickActions(theme),
          const SizedBox(height: 24),
          _sectionTitle('Statistik Aset', theme),
          const SizedBox(height: 12),
          _statisticsCards(theme),
          const SizedBox(height: 24),
          _sectionTitle('Ringkasan Kondisi', theme),
          const SizedBox(height: 12),
          _kondisiSection(theme),
        ],
      ),
    );
  }

  Widget _greetingCard(ThemeData theme) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Selamat Pagi';
      greetingIcon = Icons.wb_sunny;
    } else if (hour < 15) {
      greeting = 'Selamat Siang';
      greetingIcon = Icons.wb_sunny_outlined;
    } else if (hour < 18) {
      greeting = 'Selamat Sore';
      greetingIcon = Icons.wb_twilight;
    } else {
      greeting = 'Selamat Malam';
      greetingIcon = Icons.nightlight_round;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(greetingIcon, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  userName ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userRole?.toUpperCase() ?? 'STAFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, size: 40, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _quickActions(ThemeData theme) {
    final actions = [
      {
        'icon': Icons.inventory_2,
        'label': 'Aset',
        'color': Colors.blue,
        'route': AppRoute.aset,
      },
      {
        'icon': Icons.assignment,
        'label': 'Peminjaman',
        'color': Colors.orange,
        'route': AppRoute.peminjamanAset,
      },
      {
        'icon': Icons.local_shipping,
        'label': 'Pengadaan',
        'color': Colors.green,
        'route': AppRoute.pengadaan,
      },
      {
        'icon': Icons.build_circle,
        'label': 'Maintenance',
        'color': Colors.purple,
        'route': AppRoute.maintenancePage,
      },
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: actions.map((action) {
        return _quickActionCard(
          icon: action['icon'] as IconData,
          label: action['label'] as String,
          color: action['color'] as Color,
          onTap: () {
            Navigator.pushNamed(context, action['route'] as String);
          },
        );
      }).toList(),
    );
  }

  Widget _quickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statisticsCards(ThemeData theme) {
    // Jika bukan admin atau manager, tampilkan pesan
    if (!isAdminOrManager) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.lock_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Statistik Aset',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hanya dapat diakses oleh Admin & Manager',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    // Untuk admin dan manager, tampilkan statistik normal
    return FutureBuilder<Map<String, dynamic>>(
      future: statsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gagal memuat statistik',
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${snapshot.error}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final stats = snapshot.data ?? {};

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons.inventory_2,
                    label: 'Total Aset',
                    value: '${stats['total_aset'] ?? 0}',
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    icon: Icons.check_circle,
                    label: 'Tersedia',
                    value: '${stats['aset_tersedia'] ?? 0}',
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    icon: Icons.assignment_return,
                    label: 'Dipinjam',
                    value: '${stats['aset_dipinjam'] ?? 0}',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    icon: Icons.build,
                    label: 'Maintenance',
                    value: '${stats['maintenance_aktif'] ?? 0}',
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _kondisiSection(ThemeData theme) {
    return FutureBuilder<Map<String, dynamic>>(
      future: kondisiFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final kondisi = snapshot.data ?? {};

        if (kondisi.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Tidak ada data kondisi')),
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: kondisi.entries.map((e) {
              final total = kondisi.values.fold(0, (a, b) => a + (b as int));
              final percentage = total > 0 ? (e.value / total * 100) : 0.0;

              Color barColor;
              switch (e.key.toLowerCase()) {
                case 'baik':
                  barColor = Colors.green;
                  break;
                case 'rusak ringan':
                  barColor = Colors.orange;
                  break;
                case 'rusak berat':
                  barColor = Colors.red;
                  break;
                default:
                  barColor = Colors.blue;
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          e.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${e.value} (${percentage.toStringAsFixed(1)}%)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: barColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation(barColor),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Drawer _buildDrawer(BuildContext context, ThemeData theme) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.business, size: 32, color: Colors.blue),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Asset Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'v1.0.0',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(
                  Icons.dashboard,
                  'Dashboard',
                  () => Navigator.pop(context),
                ),
                _drawerItem(
                  Icons.inventory_2,
                  'Aset',
                  () => Navigator.pushNamed(context, AppRoute.aset),
                ),
                _drawerItem(
                  Icons.assignment,
                  'Peminjaman Aset',
                  () => Navigator.pushNamed(context, AppRoute.peminjamanAset),
                ),
                _drawerItem(
                  Icons.swap_horiz,
                  'Pemindahan Aset',
                  () => Navigator.pushNamed(context, AppRoute.pemindahanAset),
                ),
                _drawerItem(
                  Icons.build_circle,
                  'Maintenance',
                  () => Navigator.pushNamed(context, AppRoute.maintenancePage),
                ),
                _drawerItem(
                  Icons.local_shipping,
                  'Pengadaan',
                  () => Navigator.pushNamed(context, AppRoute.pengadaan),
                ),
                const Divider(),
                ExpansionTile(
                  leading: const Icon(Icons.storage),
                  title: const Text('Master Data'),
                  children: [
                    _subDrawerItem('Ruangan', () {
                      Navigator.pushNamed(context, AppRoute.ruangan);
                    }),
                    _subDrawerItem('Barang', () {
                      Navigator.pushNamed(context, AppRoute.barang);
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
                if (isAdmin) 
                _drawerItem(Icons.people, 'User', () {
                  Navigator.pushNamed(context, AppRoute.userListPage);
                }),
                if (isAdminOrManager)
                  _drawerItem(
                    Icons.report,
                    'Laporan',
                    () => Navigator.pushNamed(context, AppRoute.laporan),
                  ),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    ElevatedButton(
                      onPressed: () => _logout(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await SessionManager.clearSession();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, AppRoute.login);
                }
              }
            },
          ),
          const SizedBox(height: 8),
        ],
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
      dense: true,
      onTap: onTap,
    );
  }
}
