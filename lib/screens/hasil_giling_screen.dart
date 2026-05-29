import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/padi_model.dart';
import '../providers/padi_provider.dart';
import '../widgets/primary_button.dart';

class HasilGilingScreen extends StatefulWidget {
  final PadiModel padi;
  const HasilGilingScreen({super.key, required this.padi});
  @override
  State<HasilGilingScreen> createState() => _HasilGilingScreenState();
}

class _HasilGilingScreenState extends State<HasilGilingScreen> {
  final _totalBerasCtrl = TextEditingController(text: '0');
  final _diambilPetaniCtrl = TextEditingController(text: '0');
  final _dijualPabrikCtrl = TextEditingController(text: '0');
  bool _isLoading = false;

  int get _totalBerasAwal => widget.padi.jumlahKarung * 35;
  int get _totalBeras => int.tryParse(_totalBerasCtrl.text) ?? 0;

  int get _biayaGiling {
    if (_totalBeras <= 0) return 0;
    return (_totalBeras / 13).floor();
  }

  int get _diambilPetani => int.tryParse(_diambilPetaniCtrl.text) ?? 0;
  int get _dijualPabrik => int.tryParse(_dijualPabrikCtrl.text) ?? 0;
  int get _sisaPetani => _totalBeras - _biayaGiling - _diambilPetani;
  int get _masukStok => _dijualPabrik;

  Future<void> _handleSelesaikan() async {
    if (_totalBeras == 0) {
      _showSnackbar('Isi total hasil beras terlebih dahulu', Colors.orange);
      return;
    }
    if (_dijualPabrik == 0) {
      _showSnackbar('Isi jumlah yang dijual ke pabrik', Colors.orange);
      return;
    }
    final sisaSetelahBiaya = _totalBeras - _biayaGiling;
    if (_diambilPetani + _dijualPabrik > sisaSetelahBiaya) {
      _showSnackbar(
        'Jumlah diambil + dijual melebihi sisa ($sisaSetelahBiaya KG)',
        Colors.red,
      );
      return;
    }

    setState(() => _isLoading = true);

    await context.read<PadiProvider>().selesaikanGiling(
      id: widget.padi.id,
      totalBeras: _totalBeras,
      diambilPetani: _diambilPetani,
      dijualPabrik: _dijualPabrik,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      _showSnackbar('Proses giling selesai!', AppTheme.primaryGreen);
      Navigator.pop(context);
    }
  }

  void _showSnackbar(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.poppins(fontSize: 13)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _totalBerasCtrl.dispose();
    _diambilPetaniCtrl.dispose();
    _dijualPabrikCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // === HEADER ===
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: context.textPrimary,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Input Hasil Giling',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        'Kelola hasil penggilingan padi',
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
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // === INFO PETANI ===
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.padi.namaPetani,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: context.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 12,
                                color: context.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.padi.tanggal,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: context.cardColorElevated,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Estimasi Beras (${widget.padi.jumlahKarung} karung)',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: context.textSecondary,
                                  ),
                                ),
                                Text(
                                  '$_totalBerasAwal Kg',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: context.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // === TOTAL HASIL BERAS ===
                    _buildInputCard(
                      label: 'Total Hasil Beras',
                      controller: _totalBerasCtrl,
                      unit: 'KG',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),

                    // === BIAYA GILING AUTO ===
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: context.isDark
                            ? const Color(0xFF2C2200)
                            : const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: context.isDark
                              ? const Color(0xFF5C4400)
                              : const Color(0xFFFFE082),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Biaya Giling (Auto)',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$_biayaGiling',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFE67E22),
                                ),
                              ),
                              Text(
                                'KG',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: context.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: context.cardColorElevated,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ⓘ Setiap kelipatan 13 KG = 1 KG biaya',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: context.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Perhitungan: $_totalBeras KG ÷ 13 = $_biayaGiling KG biaya',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: const Color(0xFFE67E22),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // === DIAMBIL PETANI ===
                    _buildInputCard(
                      label: 'Diambil Petani',
                      controller: _diambilPetaniCtrl,
                      unit: 'KG',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),

                    // === DIJUAL KE PABRIK ===
                    _buildInputCard(
                      label: 'Dijual ke Pabrik',
                      controller: _dijualPabrikCtrl,
                      unit: 'KG',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // === RINGKASAN ===
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.summarize_outlined,
                                color: AppTheme.primaryGreen,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Ringkasan Hasil',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: context.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _summaryRow('Total hasil', '$_totalBeras KG'),
                          _summaryRow(
                            'Biaya giling',
                            '- $_biayaGiling KG',
                            valueColor: const Color(0xFFE67E22),
                          ),
                          _summaryRow(
                            'Sisa setelah biaya',
                            '${_totalBeras - _biayaGiling} KG',
                          ),
                          _summaryRow('Diambil petani', '- $_diambilPetani KG'),
                          _summaryRow('Sisa petani', '$_sisaPetani KG'),
                          Divider(height: 20, color: context.dividerColor),
                          _summaryRow(
                            'Masuk stok pabrik',
                            '$_masukStok KG',
                            isBold: true,
                            valueColor: AppTheme.primaryGreen,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '≈ ${(_dijualPabrik / 100).toStringAsFixed(2)} Quintal',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    PrimaryButton(
                      text: '✓  Selesaikan Proses',
                      isLoading: _isLoading,
                      onPressed: _handleSelesaikan,
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard({
    required String label,
    required TextEditingController controller,
    required String unit,
    void Function(String)? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: context.textSecondary,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  onChanged: onChanged,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              Text(
                unit,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: context.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
