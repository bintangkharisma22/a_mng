import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/laporan_maintenance.dart';
import '../../services/kategori_service.dart';
import '../../models/kategori.dart';

class LaporanMaintenancePage extends StatefulWidget {
  const LaporanMaintenancePage({super.key});

  @override
  State<LaporanMaintenancePage> createState() => _LaporanMaintenancePageState();
}

class _LaporanMaintenancePageState extends State<LaporanMaintenancePage> {
  List<dynamic> _laporanData = [];
  bool _isLoading = false;

  // Filter options
  List<Kategori> _kategoriList = [];

  // Selected filters
  String? _selectedKategoriId;
  String? _selectedStatus;

  final List<String> _statusOptions = [
    'Dijadwalkan',
    'Sedang Dikerjakan',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    _loadFilterOptions();
    _loadLaporan();
  }

  Future<void> _loadFilterOptions() async {
    try {
      final kategori = await KategoriService.getKategori();

      setState(() {
        _kategoriList = kategori;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat opsi filter: $e')));
      }
    }
  }

  Future<void> _loadLaporan() async {
    setState(() => _isLoading = true);

    try {
      final data = await LaporanMaintenanceService.getLaporan(
        kategoriId: _selectedKategoriId,
        status: _selectedStatus,
      );

      setState(() {
        _laporanData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal memuat laporan: $e')));
      }
    }
  }

  Future<void> _exportExcel() async {
    try {
      await LaporanMaintenanceService.exportExcel(
        kategoriId: _selectedKategoriId,
        status: _selectedStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil diexport')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal export laporan: $e')));
      }
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedKategoriId = null;
      _selectedStatus = null;
    });
    _loadLaporan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Maintenance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: _exportExcel,
            tooltip: 'Export Excel',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _laporanData.isEmpty
                ? const Center(child: Text('Tidak ada data'))
                : _buildDataTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  initialValue: _selectedKategoriId,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Semua Kategori'),
                    ),
                    ..._kategoriList.map(
                      (k) => DropdownMenuItem<String>(
                        value: k.id,
                        child: Text(k.nama),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedKategoriId = value);
                  },
                ),
              ),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  initialValue: _selectedStatus,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Semua Status'),
                    ),
                    ..._statusOptions.map(
                      (s) => DropdownMenuItem<String>(value: s, child: Text(s)),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStatus = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _loadLaporan,
                icon: const Icon(Icons.search),
                label: const Text('Terapkan Filter'),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Reset'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Kode Aset')),
            DataColumn(label: Text('Jenis')),
            DataColumn(label: Text('Teknisi')),
            DataColumn(label: Text('Tgl Jadwal')),
            DataColumn(label: Text('Tgl Selesai')),
            DataColumn(label: Text('Biaya')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Catatan')),
          ],
          rows: _laporanData.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item['aset']?['kode_aset'] ?? '-')),
                DataCell(Text(item['jenis_maintenance'] ?? '-')),
                DataCell(Text(item['teknisi'] ?? '-')),
                DataCell(
                  Text(
                    item['tanggal_dijadwalkan'] != null
                        ? DateFormat(
                            'dd/MM/yyyy',
                          ).format(DateTime.parse(item['tanggal_dijadwalkan']))
                        : '-',
                  ),
                ),
                DataCell(
                  Text(
                    item['tanggal_selesai'] != null
                        ? DateFormat(
                            'dd/MM/yyyy',
                          ).format(DateTime.parse(item['tanggal_selesai']))
                        : '-',
                  ),
                ),
                DataCell(
                  Text(
                    item['biaya'] != null
                        ? 'Rp ${NumberFormat('#,###').format(item['biaya'])}'
                        : '-',
                  ),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(item['status']),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['status'] ?? '-',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: 150,
                    child: Text(
                      item['catatan'] ?? '-',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Dijadwalkan':
        return Colors.blue;
      case 'Sedang Dikerjakan':
        return Colors.orange;
      case 'Selesai':
        return Colors.green;
      case 'Dibatalkan':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
