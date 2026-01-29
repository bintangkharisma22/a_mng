import 'package:a_mng/pages/aset/aset_update_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme.dart';
import 'core/routes.dart';

import 'pages/splash.dart';
import 'pages/login.dart';
import 'pages/home.dart';

import 'pages/master/divisi.dart';
import 'pages/master/ruangan.dart';
import 'pages/master/kategori.dart';
import 'pages/master/supplier.dart';
import 'pages/master/barang.dart';

import 'pages/aset/aset.dart';
import 'pages/aset/aset_detail.dart';
import 'pages/aset/aset_form.dart';

import 'package:a_mng/pages/aset/pengadaan.dart';
import 'package:a_mng/pages/aset/pengadaan_detail.dart';
import 'package:a_mng/pages/aset/pengadaan_form.dart';

import 'package:a_mng/pages/aset/peminjaman_aset.dart';
import 'package:a_mng/pages/aset/peminjaman_detail.dart';
import 'package:a_mng/pages/aset/peminjaman_form.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoute.splash,
      routes: {
        AppRoute.splash: (_) => const SplashPage(),
        AppRoute.login: (_) => const LoginPage(),
        AppRoute.home: (_) => const HomePage(),

        AppRoute.ruangan: (_) => const RuanganPage(),
        AppRoute.divisi: (_) => const DivisiPage(),
        AppRoute.kategori: (_) => const KategoriPage(),
        AppRoute.supplier: (_) => const SupplierPage(),
        AppRoute.barang: (_) => const BarangPage(),

        AppRoute.aset: (_) => const AsetPage(),
        AppRoute.asetDetail: (_) => const DetailAsetPage(),
        AppRoute.tambahAset: (_) => const AsetFormPage(),
        AppRoute.editAset: (_) => const AsetEditPage(asetId: ''),

        AppRoute.pengadaan: (_) => const PengadaanPage(),
        AppRoute.tambahPengadaaan: (_) => const PengadaanFormPage(),
        AppRoute.pengadaanDetail: (_) => const PengadaanDetailPage(id: ''),
        AppRoute.peminjamanAset: (_) => const PeminjamanPage(),
        AppRoute.peminjamanDetail: (_) => const PeminjamanDetailPage(id: ''),
        AppRoute.tambahPeminjamanAset: (_) => const PeminjamanFormPage(),
      },
    );
  }
}
