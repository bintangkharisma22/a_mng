import 'package:flutter/material.dart';
import 'package:a_mng/models/aset.dart';
import 'package:a_mng/services/aset_service.dart';
import 'package:a_mng/core/routes.dart';
import 'package:a_mng/core/session.dart';

class AsetPage extends StatefulWidget {
  const AsetPage({super.key});

  @override
  State<AsetPage> createState() => _AsetPageState();
}

class _AsetPageState extends State<AsetPage> {
  late Future<List<Aset>> future;
  String search = '';
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    future = AsetService.getAset();
    _checkRole();
  }

  void _refresh() {
    setState(() {
      future = AsetService.getAset(search: search.isNotEmpty ? search : null);
    });
  }

  Future<void> _checkRole() async {
    final role = await SessionManager.getUserRole();
    setState(() {
      isAdmin = role == 'admin';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Data Aset')),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                //
              },
              child: const Icon(Icons.add),
            )
          : null,
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
          Navigator.pushNamed(context, AppRoute.asetDetail, arguments: aset.id);
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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _smallBadge(aset.status, isStatus: true),
            const SizedBox(height: 4),
            _smallBadge(aset.kondisi.nama),
          ],
        ),
      ),
    );
  }

  Widget _smallBadge(String text, {bool isStatus = false}) {
    Color color;

    if (isStatus) {
      switch (text.toLowerCase()) {
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
    } else {
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
