import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/padi_provider.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});
  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  String _filterTab = 'Semua';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PadiProvider>();

    var transaksi = provider.transaksi.where((t) {
      final matchTab =
          _filterTab == 'Semua' ||
          (_filterTab == 'Giling' && t.tipe == 'Giling') ||
          (_filterTab == 'Stok Masuk' && t.tipe == 'Stok Masuk') ||
          (_filterTab == 'Stok Keluar' && t.tipe == 'Stok Keluar');
      final matchSearch = t.judul.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      return matchTab && matchSearch;
    }).toList();

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
                    'Riwayat Transaksi',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    'Riwayat aktivitas penggilingan dan stok',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                    ),
                  ),
                  const SizedBox(height: 14),

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
                        hintText: 'Cari transaksi...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppTheme.textLight,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
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
                  const SizedBox(height: 12),

                  // Filter tabs - scrollable
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['Semua', 'Giling', 'Stok Masuk', 'Stok Keluar']
                          .map((t) {
                            final active = _filterTab == t;
                            return GestureDetector(
                              onTap: () => setState(() => _filterTab = t),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppTheme.primaryGreen
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: active
                                        ? AppTheme.primaryGreen
                                        : const Color(0xFFDDDDDD),
                                  ),
                                ),
                                child: Text(
                                  t,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: active
                                        ? Colors.white
                                        : AppTheme.textGrey,
                                  ),
                                ),
                              ),
                            );
                          })
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            // === LIST ===
            Expanded(
              child: transaksi.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada riwayat',
                        style: GoogleFonts.poppins(color: AppTheme.textGrey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: transaksi.length,
                      itemBuilder: (_, i) {
                        final t = transaksi[i];
                        final masuk = t.jumlah > 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                          ),
                          child: Row(
                            children: [
                              // Icon
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: masuk
                                      ? const Color(0xFFE8F5E9)
                                      : const Color(0xFFFCE4EC),
                                  shape: BoxShape.circle,
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

                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            t.judul,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                        ),
                                        if (t.status.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F5E9),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              t.status,
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.primaryGreen,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    Text(
                                      t.subjudul,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: AppTheme.textGrey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.calendar_today,
                                          size: 11,
                                          color: AppTheme.textGrey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          t.tanggal,
                                          style: GoogleFonts.poppins(
                                            fontSize: 10,
                                            color: AppTheme.textGrey,
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${masuk ? '+' : ''}${t.jumlah.toStringAsFixed(0)} Quintal',
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
