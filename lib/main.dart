import 'package:a_mng/pages/master/ruangan.dart';
import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/routes.dart';
import 'pages/splash.dart';
import 'pages/login.dart';
import 'pages/home.dart';

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
      },
    );
  }
}
