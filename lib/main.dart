import 'package:flutter/material.dart';
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

void main() {
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
      },
    );
  }
}
