import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

class AuthService {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyUsername = 'username';
  static const _keyRole = 'role';
  static const _keyNama = 'nama';

  // ── Register ──────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String nama,
    required String username,
    required String password,
  }) async {
    try {
      // Cek apakah username sudah ada
      final exist = await DatabaseHelper.instance.isUsernameExist(
        username.trim(),
      );
      if (exist) {
        return {
          'success': false,
          'message': 'Username sudah digunakan, coba yang lain',
        };
      }

      // Simpan user baru ke SQLite
      final success = await DatabaseHelper.instance.insertUser({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'nama': nama.trim(),
        'username': username.trim(),
        'password': password.trim(),
        'role': 'Operator',
      });

      if (success) {
        return {'success': true, 'message': 'Akun berhasil dibuat!'};
      }
      return {'success': false, 'message': 'Gagal membuat akun'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ── Login ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      // Cari user di SQLite
      final user = await DatabaseHelper.instance.getUserByUsername(
        username.trim(),
      );

      if (user == null) {
        return {'success': false, 'message': 'Username tidak ditemukan'};
      }

      // Cek password
      if (user['password'] != password.trim()) {
        return {'success': false, 'message': 'Password salah'};
      }

      // Simpan session
      await _saveSession(
        username: user['username'] as String,
        nama: user['nama'] as String,
        role: user['role'] as String,
      );

      return {'success': true, 'message': 'Login berhasil'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi kesalahan: $e'};
    }
  }

  // ── Save session ───────────────────────────────────────
  static Future<void> _saveSession({
    required String username,
    required String nama,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyNama, nama);
    await prefs.setString(_keyRole, role);
  }

  // ── Cek login ──────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // ── Ambil data user ────────────────────────────────────
  static Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString(_keyUsername) ?? '',
      'nama': prefs.getString(_keyNama) ?? '',
      'role': prefs.getString(_keyRole) ?? '',
    };
  }

  // ── Logout ─────────────────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
