import 'package:flutter/material.dart';
import '../services/aset_service.dart';
import './aset/aset_detail.dart';

class AsetDetailByQrPage extends StatelessWidget {
  const AsetDetailByQrPage({super.key});

  @override
  Widget build(BuildContext context) {
    final kodeAset = ModalRoute.of(context)!.settings.arguments as String;

    return FutureBuilder(
      future: AsetService.getByQqrCode(kodeAset),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final aset = snapshot.data!;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const DetailAsetPage(),
              settings: RouteSettings(arguments: aset.id),
            ),
          );
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
