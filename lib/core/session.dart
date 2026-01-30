import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _tokenKey = 'access_token';
  static const _roleKey = 'user_role';
  static const _emailKey = 'user_email';

  static Future<void> saveSession(
    String token,
    String role,
    String email,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
    await prefs.setString(_emailKey, email);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_tokenKey);
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  static Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'admin';
  }

  static Future<bool> isManager() async {
    final role = await getUserRole();
    return role == 'manager';
  }

  static Future<bool> isStaff() async {
    final role = await getUserRole();
    return role == 'staff';
  }

  static Future<String> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_email') ?? '';
  }

  static Future<bool> isAdminOrManager() async {
    final role = await getUserRole();
    return role?.toLowerCase() == 'admin' || role?.toLowerCase() == 'manager';
  }
}
