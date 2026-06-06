import 'dart:io'; //  untuk membaca file gambar
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; //  untuk fungsi galeri
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../providers/padi_provider.dart';

class ProfilScreen extends StatefulWidget {
  // 1. Tambahkan parameter callback di sini agar bisa dipanggil dari luar
  final VoidCallback? onProfileUpdated;

  // 2. Masukkan parameter ke dalam konstruktor
  const ProfilScreen({super.key, this.onProfileUpdated});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  Map<String, String> _userData = {};
  bool _loading = true;
  bool _notifikasi = true;
  bool _suara = true;

  //  Variabel tambahan untuk menampung gambar dari galeri
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  //  Sinkronisasi Load Data dengan AuthService yang Baru
  Future<void> _loadUser() async {
    final data = await AuthService.getUserData();
    setState(() {
      _userData = data;
      // Membaca simpanan path foto profil dari session lokal
      if (data['foto_profil'] != null && data['foto_profil']!.isNotEmpty) {
        _imageFile = File(data['foto_profil']!);
      }
      _loading = false;
    });
  }

  //  Sinkronisasi Simpan Data Permanen saat Ambil Gambar dari Galeri
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        // Simpan alamat file foto ke penyimpanan lokal lewat AuthService
        await AuthService.updateProfileData(
          nama: _userData['nama'] ?? '-',
          role: _userData['role'] ?? '-',
          fotoPath: pickedFile.path,
        );

        // 3. Pemicu REFRESH FOTO DI HOME: Panggil callback setelah berhasil ganti foto
        if (widget.onProfileUpdated != null) {
          widget.onProfileUpdated!();
        }
      }
    } catch (e) {
      debugPrint("Gagal mengambil foto: $e");
    }
  }

  // === DIALOG EDIT PROFIL ===
  Future<void> _showEditDialog() async {
    final nameController = TextEditingController(text: _userData['nama'] ?? '');
    final roleController = TextEditingController(text: _userData['role'] ?? '');

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = nameController.text.trim();
                final newRole = roleController.text.trim();

                // Simpan ke SharedPreferences
                await AuthService.updateProfileData(
                  nama: newName.isEmpty ? (_userData['nama'] ?? '') : newName,
                  role: newRole.isEmpty ? (_userData['role'] ?? '') : newRole,
                  fotoPath: _userData['foto_profil'] ?? '',
                );

                if (!mounted) return;
                // Refresh lokal
                await _loadUser();

                // 4. Pemicu REFRESH NAMA DI HOME: Panggil callback setelah edit teks profil sukses
                if (widget.onProfileUpdated != null) {
                  widget.onProfileUpdated!();
                }

                // Refresh juga state Provider agar UI lain ikut ter-update
                try {
                  context.read<PadiProvider>().loadAll();
                } catch (_) {}
                Navigator.of(context).pop();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi Logout',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Apakah kamu yakin ingin keluar?',
          style: GoogleFonts.poppins(fontSize: 13, color: AppTheme.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: AppTheme.textGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (konfirmasi == true && mounted) {
      await AuthService.logout();
      Navigator.pushNamedAndRemoveUntil(context, '/register', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF7F7F5);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFEEEEEE);
    final iconBgColor = isDark
        ? const Color(0xFF1B5E20)
        : const Color(0xFFE8F5E9);
    final textColor = isDark ? Colors.white : AppTheme.textDark;
    final subTextColor = isDark ? Colors.grey.shade400 : AppTheme.textGrey;
    final labelColor = isDark ? Colors.grey.shade500 : AppTheme.textGrey;

    if (_loading) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // === HEADER PROFIL ===
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Profil & Pengaturan',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // === BAGIAN FOTO PROFIL ===
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5),
                                width: 2,
                              ),
                              image: _imageFile != null
                                  ? DecorationImage(
                                      image: FileImage(_imageFile!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _imageFile == null
                                ? const Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 44,
                                  )
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFF2E7D32),
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // === AKHIR BAGIAN FOTO PROFIL ===
                    const SizedBox(height: 12),
                    Text(
                      _userData['nama'] ?? '-',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _userData['role'] ?? '-',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // === INFO AKUN ===
              _buildSection(
                title: 'Informasi Akun',
                trailing: IconButton(
                  onPressed: _showEditDialog,
                  icon: const Icon(Icons.edit, color: AppTheme.primaryGreen),
                  tooltip: 'Edit Informasi Akun',
                ),
                cardColor: cardColor,
                borderColor: borderColor,
                labelColor: labelColor,
                children: [
                  _buildInfoTile(
                    icon: Icons.person_outline,
                    label: 'Nama Lengkap',
                    value: _userData['nama'] ?? '-',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  _buildDivider(borderColor),
                  _buildInfoTile(
                    icon: Icons.account_circle_outlined,
                    label: 'Username',
                    value: _userData['username'] ?? '-',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  _buildDivider(borderColor),
                  _buildInfoTile(
                    icon: Icons.badge_outlined,
                    label: 'Role',
                    value: _userData['role'] ?? '-',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // === PENGATURAN ===
              _buildSection(
                title: 'Pengaturan',
                cardColor: cardColor,
                borderColor: borderColor,
                labelColor: labelColor,
                children: [
                  _buildToggleTile(
                    icon: Icons.notifications_outlined,
                    label: 'Notifikasi',
                    value: _notifikasi,
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    onChanged: (v) => setState(() => _notifikasi = v),
                  ),
                  _buildDivider(borderColor),
                  _buildToggleTile(
                    icon: Icons.volume_up_outlined,
                    label: 'Suara',
                    value: _suara,
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    onChanged: (v) => setState(() => _suara = v),
                  ),
                  _buildDivider(borderColor),
                  _buildToggleTile(
                    icon: isDark ? Icons.dark_mode : Icons.dark_mode_outlined,
                    label: 'Mode Gelap',
                    value: isDark,
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    onChanged: (v) {
                      themeProvider.toggleDarkMode(v);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // === TENTANG APP ===
              _buildSection(
                title: 'Tentang Aplikasi',
                cardColor: cardColor,
                borderColor: borderColor,
                labelColor: labelColor,
                children: [
                  _buildInfoTile(
                    icon: Icons.info_outline,
                    label: 'Versi Aplikasi',
                    value: '1.0.0',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  _buildDivider(borderColor),
                  _buildInfoTile(
                    icon: Icons.business_outlined,
                    label: 'Nama Aplikasi',
                    value: 'PadiTrack',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  _buildDivider(borderColor),
                  _buildInfoTile(
                    icon: Icons.description_outlined,
                    label: 'Deskripsi',
                    value: 'Smart Rice Mill Management',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // === TOMBOL LOGOUT ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? Colors.red.shade900.withValues(alpha: 0.4)
                          : Colors.red.shade50,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.red.shade200),
                      ),
                    ),
                    icon: const Icon(Icons.logout, size: 20),
                    label: Text(
                      'Keluar dari Akun',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    Widget? trailing,
    required List<Widget> children,
    required Color cardColor,
    required Color borderColor,
    required Color labelColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color color) =>
      Divider(height: 1, color: color, indent: 64);

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBgColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(fontSize: 11, color: subTextColor),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String label,
    required bool value,
    required Color iconBgColor,
    required Color textColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryGreen, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primaryGreen,
          ),
        ],
      ),
    );
  }
}
