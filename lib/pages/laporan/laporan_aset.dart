import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/laporan_aset.dart';
import '../../services/kategori_service.dart';
import '../../services/divisi_service.dart';
import '../../services/ruangan_service.dart';
import '../../services/kondisi_service.dart';
import '../../models/kategori.dart';
import '../../models/divisi.dart';
import '../../models/ruangan.dart';
import '../../models/kondisi_aset.dart';

class LaporanAsetPage extends StatefulWidget {
  const LaporanAsetPage({super.key});

  @override
  State<LaporanAsetPage> createState() => _LaporanAsetPageState();
}

class _LaporanAsetPageState extends State<LaporanAsetPage> {
  List<dynamic> _laporanData = [];
  bool _isLoading = false;

  // Filter options
  List<Kategori> _kategoriList = [];
  List<Divisi> _divisiList = [];
  List<Ruangan> _ruanganList = [];
  List<KondisiAset> _kondisiList = [];

  // Selected filters
  String? _selectedKategoriId;
  String? _selectedDivisiId;
  String? _selectedRuanganId;
  String? _selectedKondisiId;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _statusOptions = [
    'Tersedia',
    'Dipinjam',
    'Dalam Perbaikan',
    'Rusak',
    'Dihapus',
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
      final divisi = await DivisiService.getDivisi();
      final ruangan = await RuanganService.getRuangan();
      final kondisi = await KondisiService.getKondisi();

      setState(() {
        _kategoriList = kategori;
        _divisiList = divisi;
        _ruanganList = ruangan;
        _kondisiList = kondisi;
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
      final data = await LaporanAsetService.getLaporan(
        kategoriId: _selectedKategoriId,
        divisiId: _selectedDivisiId,
        ruanganId: _selectedRuanganId,
        kondisiId: _selectedKondisiId,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
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
      await LaporanAsetService.export(
        kategoriId: _selectedKategoriId,
        divisiId: _selectedDivisiId,
        ruanganId: _selectedRuanganId,
        kondisiId: _selectedKondisiId,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
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
      _selectedDivisiId = null;
      _selectedRuanganId = null;
      _selectedKondisiId = null;
      _selectedStatus = null;
      _startDate = null;
      _endDate = null;
    });
    _loadLaporan();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Aset'),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filter',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Scrollable filter row
          SizedBox(
            height: 65,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterDropdown(
                  label: 'Kategori',
                  value: _selectedKategoriId,
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
                const SizedBox(width: 12),
                _buildFilterDropdown(
                  label: 'Divisi',
                  value: _selectedDivisiId,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Semua Divisi'),
                    ),
                    ..._divisiList.map(
                      (d) => DropdownMenuItem<String>(
                        value: d.id,
                        child: Text(d.nama),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedDivisiId = value);
                  },
                ),
                const SizedBox(width: 12),
                _buildFilterDropdown(
                  label: 'Ruangan',
                  value: _selectedRuanganId,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Semua Ruangan'),
                    ),
                    ..._ruanganList.map(
                      (r) => DropdownMenuItem<String>(
                        value: r.id,
                        child: Text(r.nama),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedRuanganId = value);
                  },
                ),
                const SizedBox(width: 12),
                _buildFilterDropdown(
                  label: 'Kondisi',
                  value: _selectedKondisiId,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Semua Kondisi'),
                    ),
                    ..._kondisiList.map(
                      (k) => DropdownMenuItem<String>(
                        value: k.id,
                        child: Text(k.nama),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedKondisiId = value);
                  },
                ),
                const SizedBox(width: 12),
                _buildFilterDropdown(
                  label: 'Status',
                  value: _selectedStatus,
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
                const SizedBox(width: 12),
                _buildDatePicker(
                  label: 'Tanggal Mulai',
                  date: _startDate,
                  onTap: () => _selectDate(context, true),
                ),
                const SizedBox(width: 12),
                _buildDatePicker(
                  label: 'Tanggal Akhir',
                  date: _endDate,
                  onTap: () => _selectDate(context, false),
                ),
              ],
            ),
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

  Widget _buildFilterDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        value: value,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 200,
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  date != null
                      ? DateFormat('dd/MM/yyyy').format(date)
                      : 'Pilih tanggal',
                  style: TextStyle(
                    color: date != null ? Colors.black : Colors.grey,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.calendar_today, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          columnSpacing: 20,
          horizontalMargin: 16,
          columns: const [
            DataColumn(label: Text('Kode Aset')),
            DataColumn(label: Text('Nomor Seri')),
            DataColumn(label: Text('Kategori')),
            DataColumn(label: Text('Divisi')),
            DataColumn(label: Text('Ruangan')),
            DataColumn(label: Text('Kondisi')),
            DataColumn(label: Text('Harga')),
            DataColumn(label: Text('Tgl Terima')),
            DataColumn(label: Text('Akhir Garansi')),
            DataColumn(label: Text('Status')),
          ],
          rows: _laporanData.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item['kode_aset'] ?? '-')),
                DataCell(Text(item['nomor_seri'] ?? '-')),
                DataCell(Text(item['kategori']?['nama'] ?? '-')),
                DataCell(Text(item['divisi']?['nama'] ?? '-')),
                DataCell(Text(item['ruangan']?['nama'] ?? '-')),
                DataCell(Text(item['kondisi']?['nama'] ?? '-')),
                DataCell(
                  Text(
                    item['harga_pembelian'] != null
                        ? 'Rp ${NumberFormat('#,###').format(item['harga_pembelian'])}'
                        : '-',
                  ),
                ),
                DataCell(
                  Text(
                    item['tanggal_penerimaan'] != null
                        ? DateFormat(
                            'dd/MM/yyyy',
                          ).format(DateTime.parse(item['tanggal_penerimaan']))
                        : '-',
                  ),
                ),
                DataCell(
                  Text(
                    item['tanggal_akhir_garansi'] != null
                        ? DateFormat('dd/MM/yyyy').format(
                            DateTime.parse(item['tanggal_akhir_garansi']),
                          )
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
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Tersedia':
        return Colors.green;
      case 'Dipinjam':
        return Colors.blue;
      case 'Dalam Perbaikan':
        return Colors.orange;
      case 'Rusak':
        return Colors.red;
      case 'Dihapus':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
