import 'package:a_mng/pages/maintenance/maintenance_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/maintenance_aset.dart';
import '../../services/maintenance_service.dart';
import '../../core/session.dart';
import '../../core/routes.dart';

class MaintenancePage extends StatefulWidget {
  const MaintenancePage({super.key});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  late Future<List<MaintenanceAset>> future;
  bool isAdmin = false;

  String? filterStatus;
  String? filterJenis;

  final List<String> statusOptions = [
    'Semua',
    'Dijadwalkan',
    'Sedang Dikerjakan',
    'Selesai',
    'Dibatalkan',
  ];

  final List<String> jenisOptions = ['Semua', 'Rutin', 'Perbaikan', 'Inspeksi'];

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
      future = MaintenanceService.getAll(
        status: filterStatus == 'Semua' ? null : filterStatus,
        jenisMaintenance: filterJenis == 'Semua' ? null : filterJenis,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Aset'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoute.maintenanceForm,
                ).then((_) => _refresh());
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          if (filterStatus != null || filterJenis != null) _filterChips(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: FutureBuilder<List<MaintenanceAset>>(
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
                    return const Center(
                      child: Text('Belum ada data maintenance'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final maintenance = data[index];
                      return _maintenanceCard(maintenance);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          if (filterStatus != null && filterStatus != 'Semua')
            Chip(
              label: Text('Status: $filterStatus'),
              onDeleted: () {
                setState(() => filterStatus = null);
                _refresh();
              },
            ),
          if (filterJenis != null && filterJenis != 'Semua')
            Chip(
              label: Text('Jenis: $filterJenis'),
              onDeleted: () {
                setState(() => filterJenis = null);
                _refresh();
              },
            ),
        ],
      ),
    );
  }

  Widget _maintenanceCard(MaintenanceAset maintenance) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MaintenanceDetailPage(
                maintenanceId: maintenance.id,
                id: maintenance.id,
              ),
            ),
          ).then((_) => _refresh());
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      maintenance.aset?.kodeAset ?? 'N/A',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _statusBadge(maintenance.status ?? 'N/A'),
                ],
              ),
              const Divider(height: 16),
              Row(
                children: [
                  Icon(Icons.build, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    maintenance.jenisMaintenance ?? 'N/A',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (maintenance.teknisi != null)
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 8),
                    Text('Teknisi: ${maintenance.teknisi}'),
                  ],
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    maintenance.tanggalDijadwalkan != null
                        ? DateFormat(
                            'dd MMM yyyy',
                            'id_ID',
                          ).format(maintenance.tanggalDijadwalkan!)
                        : 'Belum dijadwalkan',
                  ),
                ],
              ),
              if (maintenance.biaya != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Rp ${NumberFormat('#,##0', 'id_ID').format(maintenance.biaya)}',
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
        ),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'Dijadwalkan':
        color = Colors.blue;
        break;
      case 'Sedang Dikerjakan':
        color = Colors.orange;
        break;
      case 'Selesai':
        color = Colors.green;
        break;
      case 'Dibatalkan':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Maintenance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: filterStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: statusOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => filterStatus = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: filterJenis,
              decoration: const InputDecoration(
                labelText: 'Jenis Maintenance',
                border: OutlineInputBorder(),
              ),
              items: jenisOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => filterJenis = val),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                filterStatus = null;
                filterJenis = null;
              });
              Navigator.pop(context);
              _refresh();
            },
            child: const Text('Reset'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _refresh();
            },
            child: const Text('Terapkan'),
          ),
        ],
      ),
    );
  }
}
