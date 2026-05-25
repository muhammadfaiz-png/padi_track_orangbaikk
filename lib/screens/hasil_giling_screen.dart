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
  final _totalBerasCtrl    = TextEditingController(text: '0');
  final _diambilPetaniCtrl = TextEditingController(text: '0');
  final _dijualPabrikCtrl  = TextEditingController(text: '0');
  bool _isLoading          = false;

  int get _totalBerasAwal => widget.padi.jumlahKarung * 35;
  int get _totalBeras     => int.tryParse(_totalBerasCtrl.text) ?? 0;

  int get _biayaGiling {
    if (_totalBeras <= 0) return 0;
    return (_totalBeras / 13).floor();
  }

  int get _diambilPetani => int.tryParse(_diambilPetaniCtrl.text) ?? 0;
  int get _dijualPabrik  => int.tryParse(_dijualPabrikCtrl.text) ?? 0;
  int get _sisaPetani    => _totalBeras - _biayaGiling - _diambilPetani;
  int get _masukStok     => _dijualPabrik;

  Future<void> _handleSelesaikan() async {
    // Validasi total beras
    if (_totalBeras == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Isi total hasil beras terlebih dahulu',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Validasi dijual ke pabrik
    if (_dijualPabrik == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Isi jumlah yang dijual ke pabrik',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Validasi diambil + dijual tidak melebihi sisa
    final sisaSetelahBiaya = _totalBeras - _biayaGiling;
    if (_diambilPetani + _dijualPabrik > sisaSetelahBiaya) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Jumlah diambil + dijual melebihi sisa ($sisaSetelahBiaya KG)',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // ✅ DIPERBAIKI: pakai selesaikanGiling bukan updateStatus
    // Nilai yang diinput user langsung disimpan ke SQLite
    await context.read<PadiProvider>().selesaikanGiling(
      id:            widget.padi.id,
      totalBeras:    _totalBeras,
      diambilPetani: _diambilPetani,
      dijualPabrik:  _dijualPabrik,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Proses giling selesai!',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
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
      backgroundColor: const Color(0xFFF7F7F5),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        color: AppTheme.textDark,
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
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        'Kelola hasil penggilingan padi',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppTheme.textGrey),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.padi.namaPetani,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.calendar_today,
                                size: 12, color: AppTheme.textGrey),
                            const SizedBox(width: 4),
                            Text(widget.padi.tanggal,
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: AppTheme.textGrey)),
                          ]),
                          const SizedBox(height: 12),
                          // Info karung & estimasi
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Estimasi Beras (${widget.padi.jumlahKarung} karung)',
                                  style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: AppTheme.textGrey),
                                ),
                                Text(
                                  '$_totalBerasAwal Kg',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // === TOTAL HASIL BERAS (input user) ===
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
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFFFE082)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Biaya Giling (Auto)',
                              style: GoogleFonts.poppins(
                                  fontSize: 13, color: AppTheme.textGrey)),
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
                              Text('KG',
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: AppTheme.textGrey)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ⓘ Setiap kelipatan 13 KG = 1 KG biaya',
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: AppTheme.textGrey,
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

                    // === DIAMBIL PETANI (input user) ===
                    _buildInputCard(
                      label: 'Diambil Petani',
                      controller: _diambilPetaniCtrl,
                      unit: 'KG',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),

                    // === DIJUAL KE PABRIK (input user) ===
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEEEEEE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            const Icon(Icons.summarize_outlined,
                                color: AppTheme.primaryGreen, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Ringkasan Hasil',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ]),
                          const SizedBox(height: 14),
                          _summaryRow(
                              'Total hasil', '$_totalBeras KG'),
                          _summaryRow(
                              'Biaya giling', '- $_biayaGiling KG',
                              valueColor: const Color(0xFFE67E22)),
                          _summaryRow(
                              'Sisa setelah biaya',
                              '${_totalBeras - _biayaGiling} KG'),
                          _summaryRow(
                              'Diambil petani', '- $_diambilPetani KG'),
                          _summaryRow(
                              'Sisa petani', '$_sisaPetani KG'),
                          const Divider(
                              height: 20, color: Color(0xFFF0F0F0)),
                          // ✅ Stok pabrik = dijual ke pabrik
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
                              color: AppTheme.textGrey,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppTheme.textGrey)),
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
                    color: AppTheme.textDark,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
              Text(unit,
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppTheme.textGrey)),
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
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppTheme.textGrey)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}