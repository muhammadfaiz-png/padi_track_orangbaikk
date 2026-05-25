import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyUsername = 'username';
  static const _keyRole = 'role';
  static const _keyNama = 'nama';

  // ── Login ────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    Map<String, String>? userData;

    if (username == 'admin' && password == 'admin123') {
      userData = {
        'username': 'admin',
        'nama': 'Administrator',
        'role': 'Administrator',
      };
    } else if (username == 'operator' && password == 'op123') {
      userData = {
        'username': 'operator',
        'nama': 'Operator Pabrik',
        'role': 'Operator',
      };
    }

    if (userData != null) {
      await _saveSession(userData);
      return {'success': true, 'data': userData};
    }
    return {'success': false, 'message': 'Username atau password salah'};
  }

  // ── Save session ─────────────────────────────────────
  static Future<void> _saveSession(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUsername, data['username'] ?? '');
    await prefs.setString(_keyRole, data['role'] ?? '');
    await prefs.setString(_keyNama, data['nama'] ?? '');
  }

  // ── Cek apakah sudah login ───────────────────────────
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // ── Ambil data user ──────────────────────────────────
  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString(_keyUsername) ?? '',
      'nama': prefs.getString(_keyNama) ?? '',
      'role': prefs.getString(_keyRole) ?? '',
    };
  }

  // ── Logout ───────────────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
