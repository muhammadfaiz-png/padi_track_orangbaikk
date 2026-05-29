import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/padi_provider.dart';

class StokScreen extends StatefulWidget {
  const StokScreen({super.key});
  @override
  State<StokScreen> createState() => _StokScreenState();
}

class _StokScreenState extends State<StokScreen> {
  String _filterTab = 'Semua';

  void _showStokKeluarDialog() {
    final judulCtrl = TextEditingController();
    final jumlahCtrl = TextEditingController();
    final isDark = context.isDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      // ✅ background bottom sheet ikut dark mode
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Stok Keluar',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Input pengeluaran stok beras',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: context.textSecondary,
              ),
            ),
            const SizedBox(height: 20),

            // Keterangan
            Text(
              'Keterangan',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: judulCtrl,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: context.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Contoh: Penjualan beras',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: context.textHint,
                ),
                filled: true,
                fillColor: context.inputFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Jumlah
            Text(
              'Jumlah (Quintal)',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: jumlahCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: context.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: context.textHint,
                ),
                filled: true,
                fillColor: context.inputFillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final judul = judulCtrl.text.trim();
                  final jumlah = double.tryParse(jumlahCtrl.text.trim()) ?? 0;
                  if (judul.isEmpty || jumlah <= 0) return;

                  final now = DateTime.now();
                  const bulan = [
                    '',
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'Mei',
                    'Jun',
                    'Jul',
                    'Agu',
                    'Sep',
                    'Okt',
                    'Nov',
                    'Des',
                  ];
                  final tanggal = '${now.day} ${bulan[now.month]} ${now.year}';

                  context.read<PadiProvider>().tambahStokKeluar(
                    judul: judul,
                    jumlah: jumlah,
                    tanggal: tanggal,
                  );
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Simpan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PadiProvider>();
    final transaksi = provider.transaksi.where((t) {
      if (_filterTab == 'Masuk') return t.jumlah > 0;
      if (_filterTab == 'Keluar') return t.jumlah < 0;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === HEADER ===
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Stok Gudang',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: context.textPrimary,
                    ),
                  ),
                  Text(
                    'Pantau stok beras pabrik',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: context.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // === STOK CARD (tetap hijau gradient) ===
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.warehouse_outlined,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Stok Beras',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.85),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  provider.stokGudang.toStringAsFixed(1),
                                  style: GoogleFonts.poppins(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    'Quintal',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter tabs
                  Row(
                    children: ['Semua', 'Masuk', 'Keluar'].map((t) {
                      final active = _filterTab == t;
                      return GestureDetector(
                        onTap: () => setState(() => _filterTab = t),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: active
                                ? AppTheme.primaryGreen
                                : context.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active
                                  ? AppTheme.primaryGreen
                                  : context.borderColor,
                            ),
                          ),
                          child: Text(
                            t,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: active
                                  ? Colors.white
                                  : context.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'Aktivitas Terbaru',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: context.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // === LIST AKTIVITAS ===
            Expanded(
              child: transaksi.isEmpty
                  ? Center(
                      child: Text(
                        'Belum ada aktivitas',
                        style: GoogleFonts.poppins(
                          color: context.textSecondary,
                        ),
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
                            color: context.cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: masuk
                                      ? context.badgeBgSelesai
                                      : context.isDark
                                      ? const Color(0xFF3B0A0A)
                                      : const Color(0xFFFCE4EC),
                                  borderRadius: BorderRadius.circular(10),
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
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t.judul,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: context.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      t.subjudul,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: context.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${masuk ? '+' : ''}${t.jumlah.toStringAsFixed(0)} Q',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
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
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showStokKeluarDialog,
        backgroundColor: AppTheme.primaryGreen,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Stok Keluar',
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
