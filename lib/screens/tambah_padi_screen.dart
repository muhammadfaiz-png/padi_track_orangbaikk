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
    // Warna field hijau adaptif dark mode
    final fieldBgColor = context.isDark
        ? const Color(0xFF1B3A1E)
        : const Color(0xFFD4EDDA);
    final fieldTextColor = context.isDark
        ? Colors.white
        : AppTheme.primaryGreenDark;
    final fieldHintColor = context.isDark
        ? Colors.green.shade300
        : AppTheme.primaryGreenDark;

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
                        'Tambah Padi Masuk',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        'Input data petani yg masuk',
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
            const SizedBox(height: 24),

            // === FORM ===
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Nama Petani
                      _buildField(
                        icon: Icons.person_outline,
                        fieldBgColor: fieldBgColor,
                        fieldTextColor: fieldTextColor,
                        child: TextFormField(
                          controller: _namaCtrl,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: fieldTextColor,
                          ),
                          decoration: _inputDeco(
                            'Masukan nama petani',
                            fieldHintColor,
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Nama tidak boleh kosong'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tanggal
                      _buildField(
                        icon: Icons.calendar_month_outlined,
                        fieldBgColor: fieldBgColor,
                        fieldTextColor: fieldTextColor,
                        child: GestureDetector(
                          onTap: _pickTanggal,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Text(
                              _tanggal != null
                                  ? _formatTanggal(_tanggal!)
                                  : 'Tanggal masuk pabrik',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: _tanggal != null
                                    ? fieldTextColor
                                    : fieldHintColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Jumlah Karung
                      _buildField(
                        icon: Icons.inventory_2_outlined,
                        fieldBgColor: fieldBgColor,
                        fieldTextColor: fieldTextColor,
                        child: TextFormField(
                          controller: _karungCtrl,
                          keyboardType: TextInputType.number,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: fieldTextColor,
                          ),
                          decoration: _inputDeco(
                            'Jumlah karung',
                            fieldHintColor,
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
                      ),
                      const SizedBox(height: 12),

                      // Catatan
                      _buildField(
                        icon: Icons.mail_outline,
                        fieldBgColor: fieldBgColor,
                        fieldTextColor: fieldTextColor,
                        isMultiline: true,
                        child: TextFormField(
                          controller: _catatanCtrl,
                          maxLines: 3,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: fieldTextColor,
                          ),
                          decoration: _inputDeco(
                            'Catatan (opsional)',
                            fieldHintColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      PrimaryButton(
                        text: 'SIMPAN',
                        isLoading: _isLoading,
                        onPressed: _handleSimpan,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required IconData icon,
    required Widget child,
    required Color fieldBgColor,
    required Color fieldTextColor,
    bool isMultiline = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fieldBgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 14, top: isMultiline ? 14 : 0),
            child: Icon(icon, color: fieldTextColor, size: 20),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint, Color hintColor) => InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(fontSize: 13.5, color: hintColor),
    border: InputBorder.none,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}
