import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/padi_model.dart';
import '../providers/padi_provider.dart';
import '../widgets/primary_button.dart';

class TambahPadiScreen extends StatefulWidget {
  const TambahPadiScreen({super.key});
  @override
  State<TambahPadiScreen> createState() => _TambahPadiScreenState();
}

class _TambahPadiScreenState extends State<TambahPadiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _karungCtrl = TextEditingController();
  final _catatanCtrl = TextEditingController();
  DateTime? _tanggal;
  bool _isLoading = false;

  Future<void> _pickTanggal() async {
    final isDark = context.isDark;
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: isDark
              ? const ColorScheme.dark(primary: AppTheme.primaryGreenLight)
              : const ColorScheme.light(primary: AppTheme.primaryGreen),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  String _formatTanggal(DateTime dt) {
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
    return '${dt.day} ${bulan[dt.month]} ${dt.year}';
  }

  Future<void> _handleSimpan() async {
    if (!_formKey.currentState!.validate()) return;
    if (_tanggal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pilih tanggal terlebih dahulu',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final newPadi = PadiModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      namaPetani: _namaCtrl.text.trim(),
      tanggal: _formatTanggal(_tanggal!),
      jumlahKarung: int.parse(_karungCtrl.text.trim()),
      catatan: _catatanCtrl.text.trim(),
      status: 'Menunggu Giling',
    );

    await context.read<PadiProvider>().tambahPadi(newPadi);

    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Data padi berhasil disimpan!',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
          backgroundColor: AppTheme.primaryGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _karungCtrl.dispose();
    _catatanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Penyesuaian tema warna baru yang lebih soft & netral
    final fieldBgColor = context.isDark
        ? const Color(0xFF1E2820) // Netral gelap dengan sedikit tint hijau
        : const Color(0xFFF4F6F4); // Abu-abu bersih yang nyaman di mata

    final activeColor = context.isDark
        ? AppTheme.primaryGreenLight
        : AppTheme.primaryGreen;

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
                      width: 40, // Sedikit diperbesar agar lebih mudah ditekan
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.borderColor.withOpacity(0.6),
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        color: context.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tambah Padi Masuk',
                        style: GoogleFonts.poppins(
                          fontSize: 18, // Ukuran teks proporsional
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Input data petani yg masuk',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // === FORM (SCROLLABLE AREA) ===
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Petani
                      _buildFieldLabel('Nama Petani'),
                      TextFormField(
                        controller: _namaCtrl,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: _inputDeco(
                          hint: 'Masukkan nama petani',
                          icon: Icons.person_outline,
                          bgColor: fieldBgColor,
                          activeColor: activeColor,
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Nama tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 18),

                      // Tanggal
                      _buildFieldLabel('Tanggal Masuk'),
                      FormField<DateTime>(
                        validator: (_) =>
                            _tanggal == null ? 'Tanggal belum dipilih' : null,
                        builder: (formFieldState) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  await _pickTanggal();
                                  formFieldState.didChange(_tanggal);
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 15,
                                  ),
                                  decoration: BoxDecoration(
                                    color: fieldBgColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: formFieldState.hasError
                                          ? Colors.red.shade400
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        color: _tanggal != null
                                            ? activeColor
                                            : context.textSecondary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        _tanggal != null
                                            ? _formatTanggal(_tanggal!)
                                            : 'Pilih tanggal masuk pabrik',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: _tanggal != null
                                              ? context.textPrimary
                                              : context.textSecondary
                                                    .withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (formFieldState.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 14,
                                    top: 6,
                                  ),
                                  child: Text(
                                    formFieldState.errorText!,
                                    style: GoogleFonts.poppins(
                                      color: Colors.red.shade400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 18),

                      // Jumlah Karung
                      _buildFieldLabel('Jumlah Karung'),
                      TextFormField(
                        controller: _karungCtrl,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: _inputDeco(
                          hint: 'Contoh: 50',
                          icon: Icons.inventory_2_outlined,
                          bgColor: fieldBgColor,
                          activeColor: activeColor,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Jumlah karung tidak boleh kosong';
                          }
                          if (int.tryParse(v) == null) {
                            return 'Masukkan angka yang valid';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Catatan
                      _buildFieldLabel('Catatan Tambahan (Opsional)'),
                      TextFormField(
                        controller: _catatanCtrl,
                        maxLines: 3,
                        style: GoogleFonts.poppins(fontSize: 14),
                        decoration: _inputDeco(
                          hint: 'Tambahkan catatan jika ada...',
                          icon: Icons.chat_bubble_outline,
                          bgColor: fieldBgColor,
                          activeColor: activeColor,
                          isMultiline: true,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // === STICKY BUTTON (TETAP DI BAWAH) ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: PrimaryButton(
                text: 'SIMPAN DATA PADI',
                isLoading: _isLoading,
                onPressed: _handleSimpan,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pembantu untuk Label di atas Form Field
  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.textPrimary.withOpacity(0.8),
        ),
      ),
    );
  }

  // Generator Dekorasi Input Modern bawaan Flutter
  InputDecoration _inputDeco({
    required String hint,
    required IconData icon,
    required Color bgColor,
    required Color activeColor,
    bool isMultiline = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: context.textSecondary.withOpacity(0.6),
      ),
      fillColor: bgColor,
      filled: true,
      prefixIcon: Padding(
        padding: EdgeInsets.only(bottom: isMultiline ? 45 : 0),
        child: Icon(icon, size: 20),
      ),
      prefixIconColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.focused)) return activeColor;
        return context.textSecondary;
      }),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: activeColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
      ),
      errorStyle: GoogleFonts.poppins(fontSize: 12),
    );
  }
}
