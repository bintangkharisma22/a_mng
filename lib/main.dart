import 'package:a_mng/core/fcm_service.dart';
import 'package:a_mng/core/session.dart';
import 'package:a_mng/pages/laporan/laporan.dart';
import 'package:a_mng/pages/maintenance/maintenance.dart';
import 'package:a_mng/pages/maintenance/maintenance_detail.dart';
import 'package:a_mng/pages/maintenance/maintenance_form.dart';
import 'package:a_mng/pages/notification.dart';
import 'package:a_mng/pages/qr_result.dart';
import 'package:a_mng/pages/scan_qr.dart';
import 'package:a_mng/pages/user/user.dart';
import 'package:a_mng/pages/user/user_form.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme.dart';
import 'core/routes.dart';
import 'core/app_navigator.dart';

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
import 'package:a_mng/pages/aset/aset_update_form.dart';

import 'package:a_mng/pages/aset/pengadaan.dart';
import 'package:a_mng/pages/aset/pengadaan_detail.dart';
import 'package:a_mng/pages/aset/pengadaan_form.dart';

import 'package:a_mng/pages/aset/peminjaman_aset.dart';
import 'package:a_mng/pages/aset/peminjaman_detail.dart';
import 'package:a_mng/pages/aset/peminjaman_form.dart';

import 'package:a_mng/pages/aset/pemindahan.dart';
import 'package:a_mng/pages/aset/pemindahan_form.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize date formatting
  await initializeDateFormatting('id_ID', null);

  // Initialize Firebase ONCE
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Setup FCM after app is initialized
    _setupFCMAfterLogin();
  }

  /// Setup FCM when user is already logged in
  Future<void> _setupFCMAfterLogin() async {
    // Wait a bit for the app to fully initialize
    await Future.delayed(const Duration(milliseconds: 500));

    final isLoggedIn = await SessionManager.isLoggedIn();

    if (isLoggedIn) {
      debugPrint("🔐 User is logged in, setting up FCM...");
      final token = await FcmService.init();

      if (token != null && token.isNotEmpty) {
        await FcmService.sendTokenToServer(token);
      } else {
        debugPrint("⚠️ FCM token is null or empty");
      }
    } else {
      debugPrint("🔓 User not logged in, skipping FCM setup");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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

        AppRoute.pemindahanAset: (_) => const PemindahanAsetPage(),
        AppRoute.tambahPemindahanAset: (_) => const PemindahanAsetFormPage(),

        AppRoute.maintenancePage: (_) => const MaintenancePage(),
        AppRoute.maintenanceDetail: (_) =>
            const MaintenanceDetailPage(maintenanceId: '', id: ''),
        AppRoute.maintenanceForm: (_) => const MaintenanceFormPage(),
        AppRoute.laporan: (_) => const LaporanMenuPage(),
        AppRoute.scanQr: (_) => const ScanQrPage(),
        AppRoute.scanResult: (_) => const AsetDetailByQrPage(),
        AppRoute.notificationPage: (_) => const NotificationPage(),
        AppRoute.userListPage: (_) => const UserListPage(),
        AppRoute.userForm: (_) => const UserFormPage(),
      },
    );
  }
}
