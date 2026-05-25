import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/padi_provider.dart';
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

  @override
  void initState() {
    super.initState();
    // ✅ Load semua data dari SQLite saat pertama buka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PadiProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F5),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStatGrid(),
                const SizedBox(height: 24),
                _buildAksiCepat(),
                const SizedBox(height: 24),
                _buildAktivitasTerkini(),
                const SizedBox(height: 80),
              ],
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
        return const ProfilScreen();
      default:
        return const SizedBox();
    }
  }

  // ─── HEADER ───────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            Text(
              'Kelola penggilingan padi dengan mudah',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppTheme.textGrey,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => setState(() => _selectedIndex = 4),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppTheme.primaryGreen,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  // ─── STAT GRID 2x2 — terhubung ke provider ────────────
  Widget _buildStatGrid() {
    // ✅ Ambil stats dari provider (real-time dari SQLite)
    final stats = context.watch<PadiProvider>().stats;
    final isLoading = context.watch<PadiProvider>().isLoading;

    if (isLoading) {
      return const SizedBox(
        height: 160,
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          icon: Icons.inventory_2_outlined,
          iconBg: const Color(0xFFE8F5E9),
          iconColor: AppTheme.primaryGreen,
          label: 'Total Stok Beras',
          // ✅ Data dari SQLite
          value: '${stats.stokBeras.toStringAsFixed(1)} Q',
        ),
        _StatCard(
          icon: Icons.grain,
          iconBg: const Color(0xFFFFF3E0),
          iconColor: const Color(0xFFE67E22),
          label: 'Padi Masuk Hari Ini',
          // ✅ Data dari SQLite
          value: '${stats.padiMasukHariIni} Karung',
        ),
        _StatCard(
          icon: Icons.people_outline,
          iconBg: const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF2980B9),
          label: 'Total Petani',
          // ✅ Data dari SQLite
          value: '${stats.totalPetani} Orang',
        ),
        _StatCard(
          icon: Icons.hourglass_bottom_rounded,
          iconBg: const Color(0xFFFCE4EC),
          iconColor: const Color(0xFFC0392B),
          label: 'Padi Belum Giling',
          // ✅ Data dari SQLite
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
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.8,
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
                // ✅ Refresh stats setelah tambah padi
                if (mounted) {
                  context.read<PadiProvider>().loadAll();
                }
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RiwayatScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // ─── AKTIVITAS TERKINI — dari provider ────────────────
  Widget _buildAktivitasTerkini() {
    // ✅ Ambil 3 transaksi terbaru dari provider
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
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RiwayatScreen()),
                );
              },
              child: Text(
                'Lihat Semua',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        transaksi.isEmpty
            ? Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: Center(
                  child: Text(
                    'Belum ada aktivitas',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: transaksi.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: Color(0xFFF0F0F0),
                    indent: 60,
                  ),
                  itemBuilder: (_, i) {
                    final t = transaksi[i];
                    final masuk = t.jumlah > 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: masuk
                                  ? const Color(0xFFE8F5E9)
                                  : const Color(0xFFFCE4EC),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              masuk
                                  ? Icons.check_circle_outline
                                  : Icons.arrow_upward_rounded,
                              color: masuk
                                  ? AppTheme.primaryGreen
                                  : const Color(0xFFC0392B),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.judul,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  t.subjudul,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: AppTheme.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${masuk ? '+' : ''}${t.jumlah.toStringAsFixed(1)} Q',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
      {'icon': Icons.home_outlined, 'label': 'Home'},
      {'icon': Icons.grain, 'label': 'Padi Masuk'},
      {'icon': Icons.settings_outlined, 'label': 'Giling'},
      {'icon': Icons.inventory_2_outlined, 'label': 'Stok'},
      {'icon': Icons.person_outline, 'label': 'Profil'},
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final selected = _selectedIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  items[i]['icon'] as IconData,
                  color: selected ? AppTheme.primaryGreen : AppTheme.textLight,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  items[i]['label'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: selected
                        ? AppTheme.primaryGreen
                        : AppTheme.textLight,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, color: AppTheme.textGrey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isPrimary ? AppTheme.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPrimary ? AppTheme.primaryGreen : const Color(0xFFDDDDDD),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : AppTheme.textDark,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isPrimary ? Colors.white : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
