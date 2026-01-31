import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/laporan_peminjaman.dart';
import '../../services/kategori_service.dart';
import '../../models/kategori.dart';

class LaporanPeminjamanPage extends StatefulWidget {
  const LaporanPeminjamanPage({super.key});

  @override
  State<LaporanPeminjamanPage> createState() => _LaporanPeminjamanPageState();
}

class _LaporanPeminjamanPageState extends State<LaporanPeminjamanPage> {
  List<dynamic> _laporanData = [];
  bool _isLoading = false;

  // Filter options
  List<Kategori> _kategoriList = [];

  // Selected filters
  String? _selectedKategoriId;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _statusOptions = ['Dipinjam', 'Dikembalikan', 'Terlambat'];

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
      final data = await LaporanPeminjamanService.getLaporan(
        kategoriId: _selectedKategoriId,
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
      await LaporanPeminjamanService.exportExcel(
        kategoriId: _selectedKategoriId,
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
        title: const Text('Laporan Peminjaman'),
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
              SizedBox(
                width: 200,
                child: InkWell(
                  onTap: () => _selectDate(context, true),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Mulai',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _startDate != null
                              ? DateFormat('dd/MM/yyyy').format(_startDate!)
                              : 'Pilih tanggal',
                          style: TextStyle(
                            color: _startDate != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 200,
                child: InkWell(
                  onTap: () => _selectDate(context, false),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Akhir',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _endDate != null
                              ? DateFormat('dd/MM/yyyy').format(_endDate!)
                              : 'Pilih tanggal',
                          style: TextStyle(
                            color: _endDate != null
                                ? Colors.black
                                : Colors.grey,
                          ),
                        ),
                        const Icon(Icons.calendar_today, size: 16),
                      ],
                    ),
                  ),
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
            DataColumn(label: Text('Nama Peminjam')),
            DataColumn(label: Text('Tgl Pinjam')),
            DataColumn(label: Text('Rencana Kembali')),
            DataColumn(label: Text('Kembali Aktual')),
            DataColumn(label: Text('Kondisi Sebelum')),
            DataColumn(label: Text('Kondisi Sesudah')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Catatan')),
          ],
          rows: _laporanData.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item['aset']?['kode_aset'] ?? '-')),
                DataCell(Text(item['nama_peminjam'] ?? '-')),
                DataCell(
                  Text(
                    item['tanggal_pinjam'] != null
                        ? DateFormat(
                            'dd/MM/yyyy',
                          ).format(DateTime.parse(item['tanggal_pinjam']))
                        : '-',
                  ),
                ),
                DataCell(
                  Text(
                    item['tanggal_kembali_rencana'] != null
                        ? DateFormat('dd/MM/yyyy').format(
                            DateTime.parse(item['tanggal_kembali_rencana']),
                          )
                        : '-',
                  ),
                ),
                DataCell(
                  Text(
                    item['tanggal_kembali_aktual'] != null
                        ? DateFormat('dd/MM/yyyy').format(
                            DateTime.parse(item['tanggal_kembali_aktual']),
                          )
                        : '-',
                  ),
                ),
                DataCell(Text(item['kondisi_sebelum']?['nama'] ?? '-')),
                DataCell(Text(item['kondisi_sesudah']?['nama'] ?? '-')),
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
      case 'Dipinjam':
        return Colors.blue;
      case 'Dikembalikan':
        return Colors.green;
      case 'Terlambat':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
