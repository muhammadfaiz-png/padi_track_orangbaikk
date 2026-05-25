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
    // ✅ Load data dari SQLite saat screen dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PadiProvider>().loadPadi();
    });
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

  Color _statusBgColor(String status) {
    switch (status) {
      case 'Dalam Proses':
        return const Color(0xFFE3F2FD);
      case 'Selesai':
        return const Color(0xFFE8F5E9);
      default:
        return const Color(0xFFFFF3E0);
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
      backgroundColor: const Color(0xFFF7F7F5),
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
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    'Data padi petani yang masuk ke pabrik',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEEEEEE)),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: GoogleFonts.poppins(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Cari nama petani atau ID...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textLight,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.textGrey,
                          size: 20,
                        ),
                        suffixIcon: const Icon(
                          Icons.tune,
                          color: AppTheme.textGrey,
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
                          const Icon(
                            Icons.inbox_outlined,
                            size: 60,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Belum ada data padi',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textGrey,
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
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
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
                                        color: const Color(0xFFE8F5E9),
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
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_today,
                                                size: 11,
                                                color: AppTheme.textGrey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                padi.tanggal,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 11,
                                                  color: AppTheme.textGrey,
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
                                        color: _statusBgColor(padi.status),
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
                                const Divider(
                                  height: 1,
                                  color: Color(0xFFF0F0F0),
                                ),
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
                                            color: AppTheme.textGrey,
                                          ),
                                        ),
                                        Text(
                                          '${padi.jumlahKarung} Karung',
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.textDark,
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
                                        // ✅ Refresh setelah kembali
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

      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TambahPadiScreen()),
          );
          // ✅ Refresh setelah tambah
          if (mounted) {
            context.read<PadiProvider>().loadPadi();
          }
        },
        backgroundColor: AppTheme.primaryGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
