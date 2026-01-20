import 'package:flutter/material.dart';
import 'package:a_mng/models/aset.dart';
import 'package:a_mng/services/aset_service.dart';

class AsetPage extends StatefulWidget {
  const AsetPage({super.key});

  @override
  State<AsetPage> createState() => _AsetPageState();
}

class _AsetPageState extends State<AsetPage> {
  late Future<List<Aset>> future;
  String search = '';

  @override
  void initState() {
    super.initState();
    future = AsetService.getAset();
  }

  void _refresh() {
    setState(() {
      future = AsetService.getAset(search: search.isNotEmpty ? search : null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Aset'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
      ),
      body: Column(
        children: [
          _searchBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: FutureBuilder<List<Aset>>(
                future: future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Gagal memuat data aset',
                        style: theme.textTheme.bodyLarge,
                      ),
                    );
                  }

                  final data = snapshot.data!;

                  if (data.isEmpty) {
                    return const Center(child: Text('Data aset masih kosong'));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final aset = data[index];
                      return _asetCard(aset);
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

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari kode aset...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onSubmitted: (value) {
          search = value;
          _refresh();
        },
      ),
    );
  }

  Widget _asetCard(Aset aset) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: () {
          // Navigator.pushNamed(context, AppRoute.asetDetail, arguments: aset.id);
        },
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          child: const Icon(Icons.inventory_2),
        ),
        title: Text(
          aset.kodeAset,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Kategori : ${aset.kategori.nama}'),
            Text('Ruangan  : ${aset.ruangan.nama}'),
            Text('Divisi   : ${aset.divisi.nama}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _statusBadge(aset.status),
            const SizedBox(height: 6),
            _kondisiBadge(aset.kondisi.nama),
          ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _kondisiBadge(String kondisi) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        kondisi,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
