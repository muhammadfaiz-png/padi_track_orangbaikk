import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/padi_provider.dart';
import '../services/auth_service.dart';
import 'padi_masuk_screen.dart';
import 'tambah_padi_screen.dart';
import 'hasil_giling_list_screen.dart';
import 'stok_screen.dart';
import 'riwayat_screen.dart';
import 'profil_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  File? _profileImageFile;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PadiProvider>().loadAll();
    });
  }

  Future<void> _loadProfileImage() async {
    final userData = await AuthService.getUserData();
    if (userData['foto_profil'] != null &&
        userData['foto_profil']!.isNotEmpty) {
      if (mounted) {
        setState(() {
          _profileImageFile = File(userData['foto_profil']!);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return SafeArea(
          child: RefreshIndicator(
            color: AppTheme.primaryGreen,
            onRefresh: () async {
              await context.read<PadiProvider>().loadAll();
              await _loadProfileImage();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildStatGrid(),
                  const SizedBox(height: 28),
                  _buildAksiCepat(),
                  const SizedBox(height: 28),
                  _buildAktivitasTerkini(),
                  const SizedBox(height: 40), // Ruang aman bawah yang pas
                ],
              ),
            ),
          ),
        );
      case 1:
        return const PadiMasukScreen();
      case 2:
        return const HasilGilingListScreen();
      case 3:
        return const StokScreen();
      case 4:
        // Navigasi profil dengan mendengarkan callback saat kembali untuk cegah loop bug
        return ProfilScreen(onProfileUpdated: () => _loadProfileImage());
      default:
        return const SizedBox();
    }
  }

  // ─── HEADER ───────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang',
                style: GoogleFonts.poppins(
                  fontSize: 22, // Skala font dipertegas
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kelola penggilingan padi dengan mudah',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: context.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => setState(() => _selectedIndex = 4),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: context.highlightColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.2),
                  width: 1.5,
                ),
                image: _profileImageFile != null
                    ? DecorationImage(
                        image: FileImage(_profileImageFile!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _profileImageFile == null
                  ? const Icon(
                      Icons.person_outline,
                      color: AppTheme.primaryGreen,
                      size: 24,
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  // ─── STAT GRID 2x2 ────────────────────────────────────
  Widget _buildStatGrid() {
    final stats = context.watch<PadiProvider>().stats;
    final isLoading = context.watch<PadiProvider>().isLoading;

    if (isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio:
          1.35, // Rasio disesuaikan agar tidak gampang luapan teks
      children: [
        _StatCard(
          icon: Icons.inventory_2_outlined,
          iconBg: context.isDark
              ? const Color(0xFF143E17)
              : const Color(0xFFE8F5E9),
          iconColor: AppTheme.primaryGreen,
          label: 'Total Stok Beras',
          value: '${stats.stokBeras.toStringAsFixed(1)} Q',
        ),
        _StatCard(
          icon: Icons.grain,
          iconBg: context.isDark
              ? const Color(0xFF4A320A)
              : const Color(0xFFFFF3E0),
          iconColor: const Color(0xFFE67E22),
          label: 'Padi Masuk Hari Ini',
          value: '${stats.padiMasukHariIni} Karung',
        ),
        _StatCard(
          icon: Icons.people_outline,
          iconBg: context.isDark
              ? const Color(0xFF0F2B48)
              : const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF2980B9),
          label: 'Total Petani',
          value: '${stats.totalPetani} Orang',
        ),
        _StatCard(
          icon: Icons.hourglass_bottom_rounded,
          iconBg: context.isDark
              ? const Color(0xFF4A1212)
              : const Color(0xFFFCE4EC),
          iconColor: const Color(0xFFC0392B),
          label: 'Padi Belum Giling',
          value: '${stats.padiBelumGiling} Karung',
        ),
      ],
    );
  }

  // ─── AKSI CEPAT ───────────────────────────────────────
  Widget _buildAksiCepat() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.6,
          children: [
            _QuickAction(
              icon: Icons.add_circle_outline,
              label: 'Tambah Padi',
              isPrimary: true,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TambahPadiScreen()),
                );
                if (mounted) context.read<PadiProvider>().loadAll();
              },
            ),
            _QuickAction(
              icon: Icons.settings_outlined,
              label: 'Proses Giling',
              isPrimary: false,
              onTap: () => setState(() => _selectedIndex = 1),
            ),
            _QuickAction(
              icon: Icons.output_rounded,
              label: 'Stok Keluar',
              isPrimary: false,
              onTap: () => setState(() => _selectedIndex = 3),
            ),
            _QuickAction(
              icon: Icons.history,
              label: 'Riwayat',
              isPrimary: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RiwayatScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── AKTIVITAS TERKINI ────────────────────────────────
  Widget _buildAktivitasTerkini() {
    final transaksi = context.watch<PadiProvider>().transaksi.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Terkini',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.textPrimary,
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RiwayatScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        transaksi.isEmpty
            ? Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.borderColor.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_late_outlined,
                      size: 36,
                      color: context.textSecondary.withOpacity(0.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Belum ada aktivitas',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: context.textSecondary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: context.borderColor.withOpacity(0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        context.isDark ? 0.2 : 0.03,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transaksi.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: context.dividerColor.withOpacity(0.4),
                    indent: 68,
                  ),
                  itemBuilder: (_, i) {
                    final t = transaksi[i];
                    final masuk = t.jumlah > 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: masuk
                                  ? context.badgeBgSelesai
                                  : (context.isDark
                                        ? const Color(0xFF4A1212)
                                        : const Color(0xFFFCE4EC)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              masuk
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              color: masuk
                                  ? AppTheme.primaryGreen
                                  : const Color(0xFFC0392B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.judul,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: context.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  t.subjudul,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: context.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${masuk ? '+' : ''}${t.jumlah.toStringAsFixed(1)} Q',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: masuk
                                  ? AppTheme.primaryGreen
                                  : const Color(0xFFC0392B),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  // ─── BOTTOM NAV ───────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {
        'icon': Icons.home_rounded,
        'activeIcon': Icons.home_rounded,
        'label': 'Home',
      },
      {
        'icon': Icons.grain_outlined,
        'activeIcon': Icons.grain,
        'label': 'Padi Masuk',
      },
      {
        'icon': Icons.settings_outlined,
        'activeIcon': Icons.settings,
        'label': 'Giling',
      },
      {
        'icon': Icons.inventory_2_outlined,
        'activeIcon': Icons.inventory_2,
        'label': 'Stok',
      },
      {
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
        'label': 'Profil',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(
          top: BorderSide(
            color: context.borderColor.withOpacity(0.4),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.isDark ? 0.15 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.only(top: 10, bottom: Platform.isIOS ? 24 : 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = _selectedIndex == i;
          return Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedIndex = i),
                highlightColor: Colors.transparent,
                splashColor: AppTheme.primaryGreen.withOpacity(0.1),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      (selected ? items[i]['activeIcon'] : items[i]['icon'])
                          as IconData,
                      color: selected
                          ? AppTheme.primaryGreen
                          : context.textHint.withOpacity(0.7),
                      size: 24,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      items[i]['label'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: selected
                            ? AppTheme.primaryGreen
                            : context.textHint.withOpacity(0.7),
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── SUB-WIDGETS ──────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(context.isDark ? 0.1 : 0.01),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: context.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: context.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            color: isPrimary ? AppTheme.primaryGreen : context.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isPrimary
                  ? AppTheme.primaryGreen
                  : context.borderColor.withOpacity(0.5),
            ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : context.textPrimary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPrimary ? Colors.white : context.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
