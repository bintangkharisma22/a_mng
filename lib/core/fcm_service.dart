import 'dart:developer';
import 'package:a_mng/core/config.dart';
import 'package:a_mng/core/session.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'routes.dart';
import 'app_navigator.dart';

// Handler untuk background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("🔔 Background Message: ${message.messageId}");
  log("📦 Data: ${message.data}");
  log("📬 Notification: ${message.notification?.title}");
}

class FcmService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize FCM and request permissions
  static Future<String?> init() async {
    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint("📱 FCM Permission: ${settings.authorizationStatus}");

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint("❌ FCM Permission denied by user");
        return null;
      }

      // Get FCM token
      final token = await _messaging.getToken();
      debugPrint("🔑 FCM Token: $token");

      // Set foreground notification presentation options
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Register background message handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Initialize listeners
      _initListeners();

      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        debugPrint("🔄 FCM Token refreshed: $newToken");
        sendTokenToServer(newToken);
      });

      return token;
    } catch (e) {
      debugPrint("❌ FCM Init Error: $e");
      return null;
    }
  }

  /// Initialize message listeners
  static void _initListeners() {
    // Foreground messages (app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("🔔 Foreground message received");
      log("📬 Title: ${message.notification?.title}");
      log("📝 Body: ${message.notification?.body}");
      log("📦 Data: ${message.data}");

      // Hanya show notification, TIDAK auto navigate
      _showInAppNotification(message);
    });

    // Background messages (app is in background, notification tapped)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("🔔 Background notification tapped");
      log("📦 Data: ${message.data}");

      _handleMessage(message);
    });

    // Terminated state (app was closed, notification tapped to open)
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        log("🔔 Terminated notification tapped");
        log("📦 Data: ${message.data}");

        // Delay to ensure app is fully initialized
        Future.delayed(const Duration(seconds: 1), () {
          _handleMessage(message);
        });
      }
    });
  }

  /// Show in-app notification for foreground messages with better design
  static void _showInAppNotification(RemoteMessage message) {
    final context = navigatorKey.currentContext;
    if (context == null) return;

    final notification = message.notification;
    if (notification == null) return;

    // Tentukan icon dan warna berdasarkan tipe notifikasi
    IconData notifIcon;
    Color notifColor;

    final type = message.data['type'];
    switch (type) {
      case 'pengadaan':
      case 'pengadaan_detail':
        notifIcon = Icons.local_shipping;
        notifColor = Colors.green;
        break;
      case 'maintenance':
        notifIcon = Icons.build_circle;
        notifColor = Colors.purple;
        break;
      case 'peminjaman':
        notifIcon = Icons.assignment;
        notifColor = Colors.orange;
        break;
      default:
        notifIcon = Icons.notifications_active;
        notifColor = Colors.blue;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            // Icon dengan background berwarna
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: notifColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(notifIcon, color: notifColor, size: 28),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title ?? 'Notifikasi',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                  if (notification.body != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification.body!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2D3142),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        action: SnackBarAction(
          label: 'Lihat',
          textColor: notifColor,
          onPressed: () {
            // Navigate HANYA saat tombol "Lihat" ditekan
            _handleMessage(message);
          },
        ),
      ),
    );
  }

  /// Handle notification data and navigate
  static void _handleMessage(RemoteMessage message) {
    final data = message.data;
    if (data.isEmpty) {
      log("⚠️ No data in notification");
      return;
    }

    final type = data['type'];
    log("🎯 Handling notification type: $type");

    switch (type) {
      case 'pengadaan':
        _goToPengadaan(data);
        break;

      case 'pengadaan_detail':
        final pengadaanId = data['pengadaan_id'] ?? data['id'];
        if (pengadaanId != null && pengadaanId.isNotEmpty) {
          _goToPengadaanDetail(pengadaanId);
        } else {
          log("⚠️ No pengadaan_id in data");
          _goToPengadaan(data);
        }
        break;

      case 'maintenance':
        _goToMaintenance();
        break;

      case 'peminjaman':
        _goToPeminjaman();
        break;

      default:
        log("⚠️ Unknown notification type: $type");
    }
  }

  static void _goToPengadaan(Map<String, dynamic> data) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      log("❌ Navigator not available");
      return;
    }

    log("🚀 Navigating to Pengadaan");
    navigator.pushNamed(AppRoute.pengadaan);
  }

  static void _goToPengadaanDetail(String id) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      log("❌ Navigator not available");
      return;
    }

    log("🚀 Navigating to Pengadaan Detail: $id");
    navigator.pushNamed(AppRoute.pengadaanDetail, arguments: id);
  }

  static void _goToMaintenance() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      log("❌ Navigator not available");
      return;
    }

    log("🚀 Navigating to Maintenance");
    navigator.pushNamed(AppRoute.maintenancePage);
  }

  static void _goToPeminjaman() {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      log("❌ Navigator not available");
      return;
    }

    log("🚀 Navigating to Peminjaman");
    navigator.pushNamed(AppRoute.peminjamanAset);
  }

  static Future<void> sendTokenToServer(String token) async {
    try {
      final authToken = await SessionManager.getToken();
      if (authToken == null || authToken.isEmpty) {
        debugPrint("❌ No auth token available");
        return;
      }

      final uri = Uri.parse('${Config.baseUrl}/api/user/fcm-token');

      debugPrint("📤 Sending FCM token to server...");
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ FCM token sent successfully");
      } else {
        debugPrint("❌ Failed to send FCM token: ${response.statusCode}");
        debugPrint("Response: ${response.body}");
      }
    } catch (e) {
      debugPrint("❌ Error sending FCM token: $e");
    }
  }

  static Future<void> deleteTokenFromServer() async {
    try {
      final authToken = await SessionManager.getToken();
      if (authToken == null || authToken.isEmpty) {
        return;
      }

      final uri = Uri.parse('${Config.baseUrl}/api/user/fcm-token');

      debugPrint("🗑️ Deleting FCM token from server...");
      final response = await http.delete(
        uri,
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        debugPrint("✅ FCM token deleted successfully");
      } else {
        debugPrint("⚠️ Failed to delete FCM token: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Error deleting FCM token: $e");
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint("❌ Error getting FCM token: $e");
      return null;
    }
  }

  static Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }
}
