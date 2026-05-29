import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/padi_provider.dart';
import 'tambah_padi_screen.dart';
import 'hasil_giling_screen.dart';

class PadiMasukScreen extends StatefulWidget {
  const PadiMasukScreen({super.key});
  @override
  State<PadiMasukScreen> createState() => _PadiMasukScreenState();
}

class _PadiMasukScreenState extends State<PadiMasukScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PadiProvider>().loadPadi();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Dalam Proses':
        return const Color(0xFF2980B9);
      case 'Selesai':
        return AppTheme.primaryGreen;
      default:
        return const Color(0xFFE67E22);
    }
  }

  Color _statusBgColor(String status, bool isDark) {
    switch (status) {
      case 'Dalam Proses':
        return isDark ? const Color(0xFF0D2137) : const Color(0xFFE3F2FD);
      case 'Selesai':
        return isDark ? const Color(0xFF0D2E12) : const Color(0xFFE8F5E9);
      default:
        return isDark ? const Color(0xFF3E2800) : const Color(0xFFFFF3E0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PadiProvider>();
    final filtered = provider.dataPadi
        .where(
          (p) =>
              p.namaPetani.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === HEADER ===
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Padi Masuk',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    'Data padi petani yang masuk ke pabrik',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: context.searchBgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.borderColor),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: context.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Cari nama petani atau ID...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          color: context.textHint,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: context.textSecondary,
                          size: 20,
                        ),
                        suffixIcon: Icon(
                          Icons.tune,
                          color: context.textSecondary,
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // === LIST ===
            Expanded(
              child: provider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryGreen,
                      ),
                    )
                  : filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 60,
                            color: context.textHint,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada data padi',
                            style: GoogleFonts.poppins(
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final padi = filtered[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: context.iconBgColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.agriculture,
                                        color: AppTheme.primaryGreen,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            padi.namaPetani,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: context.textPrimary,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 11,
                                                color: context.textSecondary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                padi.tanggal,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: context.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Status badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusBgColor(
                                          padi.status,
                                          context.isDark,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        padi.status,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          color: _statusColor(padi.status),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Divider(height: 1, color: context.dividerColor),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Total Volume',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: context.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          '${padi.jumlahKarung} Karung',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: context.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                HasilGilingScreen(padi: padi),
                                          ),
                                        );
                                        if (mounted) {
                                          context
                                              .read<PadiProvider>()
                                              .loadPadi();
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            'Detail',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              color: AppTheme.primaryGreen,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.chevron_right,
                                            color: AppTheme.primaryGreen,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahPadiScreen()),
          );
          if (mounted) context.read<PadiProvider>().loadPadi();
        },
        backgroundColor: AppTheme.primaryGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
