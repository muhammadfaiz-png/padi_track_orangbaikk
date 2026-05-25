import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/padi_provider.dart';
import '../models/padi_model.dart';

class HasilGilingListScreen extends StatefulWidget {
  const HasilGilingListScreen({super.key});
  @override
  State<HasilGilingListScreen> createState() => _HasilGilingListScreenState();
}

class _HasilGilingListScreenState extends State<HasilGilingListScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _filter = 'Semua';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PadiProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // Filter berdasarkan chip yang dipilih
  List<PadiModel> _applyFilter(List<PadiModel> data) {
    final now = DateTime.now();
    const bln = [
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
    final tanggalHariIni = '${now.day} ${bln[now.month]} ${now.year}';

    List<PadiModel> filtered = data;

    // Filter chip
    if (_filter == 'Hari ini') {
      filtered = filtered.where((p) => p.tanggal == tanggalHariIni).toList();
    }
    // 'Semua' dan 'Selesai' sudah difilter dari hasilGiling (status = Selesai)

    // Filter pencarian
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.namaPetani.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PadiProvider>();
    final data = _applyFilter(provider.hasilGiling);

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
                    'Hasil Giling',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    'Daftar hasil penggilingan yang telah selesai',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppTheme.textGrey,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Search bar
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
                        hintText: 'Cari nama petani...',
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

                  // Filter chips
                  Row(
                    children: ['Semua', 'Selesai', 'Hari ini'].map((f) {
                      final active = _filter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
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
                            f,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: active ? Colors.white : AppTheme.textGrey,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
                  : data.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.hourglass_empty,
                            size: 60,
                            color: AppTheme.textLight,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Hasil pencarian tidak ditemukan'
                                : 'Belum ada hasil giling',
                            style: GoogleFonts.poppins(
                              color: AppTheme.textGrey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: data.length,
                      itemBuilder: (_, i) {
                        final padi = data[i];

                        // ✅ Gunakan data real dari SQLite
                        // Jika totalBeras 0 berarti belum diisi
                        final totalBeras = padi.totalBeras > 0
                            ? padi.totalBeras
                            : padi.jumlahKarung * 35;
                        final biayaGiling = padi.totalBeras > 0
                            ? (padi.totalBeras / 13).floor()
                            : (totalBeras / 13).floor();
                        // ✅ Pakai nilai yang diinput user
                        final diAmbil = padi.diambilPetani;
                        final dijual = padi.dijualPabrik;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
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
                                // Header kartu
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          padi.namaPetani,
                                          style: GoogleFonts.poppins(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
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
                                    // Badge selesai
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8F5E9),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Selesai',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.primaryGreen,
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

                                // ✅ Detail rows pakai data real SQLite
                                _detailRow(
                                  'Total Gabah',
                                  '${padi.jumlahKarung} Karung',
                                ),
                                _detailRow('Total Beras', '$totalBeras Kg'),
                                _detailRow('Biaya Giling', '$biayaGiling Kg'),
                                _detailRow('Di ambil petani', '$diAmbil Kg'),
                                _detailRow('Di jual ke pabrik', '$dijual Kg'),
                                // Konversi quintal
                                _detailRow(
                                  'Masuk stok',
                                  '${(dijual / 100).toStringAsFixed(2)} Q',
                                  isHighlight: true,
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
    );
  }

  Widget _detailRow(String label, String value, {bool isHighlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFFE8F5E9) : const Color(0xFFF7F7F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: isHighlight ? AppTheme.primaryGreen : AppTheme.textGrey,
              fontWeight: isHighlight ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isHighlight ? AppTheme.primaryGreen : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
