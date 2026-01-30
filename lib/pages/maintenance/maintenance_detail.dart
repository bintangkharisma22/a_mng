import 'package:a_mng/pages/maintenance/maintenance_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/maintenance_aset.dart';
import '../../services/maintenance_service.dart';
import '../../core/session.dart';
import '../../core/config.dart';

class MaintenanceDetailPage extends StatefulWidget {
  final String maintenanceId;

  const MaintenanceDetailPage({
    super.key,
    required this.maintenanceId,
    required String id,
  });

  @override
  State<MaintenanceDetailPage> createState() => _MaintenanceDetailPageState();
}

class _MaintenanceDetailPageState extends State<MaintenanceDetailPage> {
  MaintenanceAset? data;
  bool loading = true;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
    _loadData();
  }

  Future<void> _checkRole() async {
    final role = await SessionManager.getUserRole();
    setState(() {
      isAdmin = role == 'admin';
    });
  }

  Future<void> _loadData() async {
    setState(() => loading = true);
    try {
      final result = await MaintenanceService.getDetail(widget.maintenanceId);
      setState(() {
        data = result;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      _showError('Gagal memuat data: $e');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  Future<void> _confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Maintenance'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteData();
    }
  }

  Future<void> _deleteData() async {
    try {
      await MaintenanceService.delete(widget.maintenanceId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maintenance berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      _showError('Gagal menghapus: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Maintenance'),
        actions: [
          if (isAdmin && data != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MaintenanceFormPage(
                      maintenanceId: widget.maintenanceId,
                    ),
                  ),
                ).then((_) => _loadData());
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
          ],
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data == null
          ? const Center(child: Text('Data tidak ditemukan'))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final m = data!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Status Badge
        Center(child: _statusBadge(m.status ?? 'N/A')),
        const SizedBox(height: 24),

        // Info Aset
        _sectionTitle('Informasi Aset'),
        _infoCard([
          _infoRow(Icons.qr_code, 'Kode Aset', m.aset?.kodeAset ?? 'N/A'),
          _infoRow(Icons.category, 'Kategori', m.aset?.kategori?.nama ?? 'N/A'),
          _infoRow(
            Icons.meeting_room,
            'Ruangan',
            m.aset?.ruangan?.nama ?? 'N/A',
          ),
          _infoRow(Icons.business, 'Divisi', m.aset?.divisi?.nama ?? 'N/A'),
        ]),

        const SizedBox(height: 24),

        // Info Maintenance
        _sectionTitle('Detail Maintenance'),
        _infoCard([
          _infoRow(
            Icons.build,
            'Jenis Maintenance',
            m.jenisMaintenance ?? 'N/A',
          ),
          if (m.teknisi != null) _infoRow(Icons.person, 'Teknisi', m.teknisi!),
          _infoRow(
            Icons.calendar_today,
            'Tanggal Dijadwalkan',
            m.tanggalDijadwalkan != null
                ? DateFormat(
                    'dd MMMM yyyy',
                    'id_ID',
                  ).format(m.tanggalDijadwalkan!)
                : 'Belum ditentukan',
          ),
          if (m.tanggalSelesai != null)
            _infoRow(
              Icons.event_available,
              'Tanggal Selesai',
              DateFormat('dd MMMM yyyy', 'id_ID').format(m.tanggalSelesai!),
            ),
          if (m.biaya != null)
            _infoRow(
              Icons.attach_money,
              'Biaya',
              'Rp ${NumberFormat('#,##0', 'id_ID').format(m.biaya)}',
              valueColor: Colors.green,
            ),
        ]),

        if (m.catatan != null && m.catatan!.isNotEmpty) ...[
          const SizedBox(height: 24),
          _sectionTitle('Catatan'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(m.catatan!, style: const TextStyle(fontSize: 14)),
            ),
          ),
        ],

        // Gambar Aset (jika ada)
        if (m.aset?.gambar != null) ...[
          const SizedBox(height: 24),
          _sectionTitle('Foto Aset'),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              '${Config.bucketUrl}/${m.aset!.gambar}',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 200,
                color: Colors.grey.shade200,
                child: const Icon(Icons.broken_image, size: 64),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'Dijadwalkan':
        color = Colors.blue;
        icon = Icons.schedule;
        break;
      case 'Sedang Dikerjakan':
        color = Colors.orange;
        icon = Icons.engineering;
        break;
      case 'Selesai':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'Dibatalkan':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
