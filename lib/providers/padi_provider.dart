import 'package:flutter/material.dart';
import '../models/padi_model.dart';
import '../database/database_helper.dart';

class TransaksiModel {
  final String id;
  final String judul;
  final String subjudul;
  final String tanggal;
  final double jumlah;
  final String tipe;
  final String status;

  TransaksiModel({
    required this.id,
    required this.judul,
    required this.subjudul,
    required this.tanggal,
    required this.jumlah,
    required this.tipe,
    this.status = '',
  });
}

class DashboardStats {
  final double stokBeras;
  final int padiMasukHariIni;
  final int totalPetani;
  final int padiBelumGiling;

  DashboardStats({
    this.stokBeras = 0,
    this.padiMasukHariIni = 0,
    this.totalPetani = 0,
    this.padiBelumGiling = 0,
  });
}

class PadiProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<PadiModel> _dataPadi      = [];
  List<TransaksiModel> _transaksi = [];
  double _stokGudang             = 0.0;
  DashboardStats _stats          = DashboardStats();
  bool isLoading                 = false;

  List<PadiModel> get dataPadi       => _dataPadi;
  List<TransaksiModel> get transaksi => _transaksi;
  double get stokGudang              => _stokGudang;
  DashboardStats get stats           => _stats;
  List<PadiModel> get hasilGiling    =>
      _dataPadi.where((p) => p.status == 'Selesai').toList();

  // ── Load semua data dari SQLite ───────────────────────
  Future<void> loadAll() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _db.getAllPadi(),
        _db.getAllTransaksi(),
        _db.getStats(),
      ]);

      _dataPadi = results[0] as List<PadiModel>;

      final rawTransaksi = results[1] as List<Map<String, dynamic>>;
      _transaksi = rawTransaksi.map((m) => TransaksiModel(
        id:       m['id'] as String,
        judul:    m['judul'] as String,
        subjudul: m['subjudul'] as String,
        tanggal:  m['tanggal'] as String,
        jumlah:   (m['jumlah'] as num).toDouble(),
        tipe:     m['tipe'] as String,
        status:   m['status'] as String? ?? '',
      )).toList();

      final statsMap = results[2] as Map<String, dynamic>;
      _stokGudang = statsMap['stokBeras'] as double;
      _stats = DashboardStats(
        stokBeras:        _stokGudang,
        padiMasukHariIni: statsMap['padiMasukHariIni'] as int,
        totalPetani:      statsMap['totalPetani'] as int,
        padiBelumGiling:  statsMap['padiBelumGiling'] as int,
      );
    } catch (e) {
      debugPrint('Error loadAll: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Alias
  Future<void> loadPadi() => loadAll();

  // ── Tambah padi ───────────────────────────────────────
  Future<void> tambahPadi(PadiModel padi) async {
    await _db.insertPadi(padi);
    await loadAll();
  }

  // ✅ BARU: Selesaikan giling dengan nilai input user
  Future<void> selesaikanGiling({
    required String id,
    required int totalBeras,
    required int diambilPetani,
    required int dijualPabrik,
  }) async {
    try {
      // ✅ Simpan hasil giling yang diinput user ke SQLite
      await _db.updateHasilGiling(
        id:            id,
        totalBeras:    totalBeras,
        diambilPetani: diambilPetani,
        dijualPabrik:  dijualPabrik,
      );

      // ✅ Stok berdasarkan dijualPabrik saja (bukan total beras)
      final dijualQuintal = dijualPabrik / 100;
      final stokBaru = _stokGudang + dijualQuintal;
      await _db.updateStok(stokBaru);

      // Simpan ke tabel transaksi
      final now = DateTime.now();
      const bln = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final tanggal = '${now.day} ${bln[now.month]} ${now.year}';
      final padi = _dataPadi.firstWhere((p) => p.id == id);

      await _db.insertTransaksi({
        'id':       '${DateTime.now().millisecondsSinceEpoch}',
        'judul':    'Hasil Giling ${padi.namaPetani}',
        'subjudul': 'Dijual: $dijualPabrik KG | Diambil: $diambilPetani KG',
        'tanggal':  tanggal,
        // ✅ Jumlah transaksi = dijual ke pabrik dalam quintal
        'jumlah':   dijualQuintal,
        'tipe':     'Giling',
        'status':   'Selesai',
      });
    } catch (e) {
      debugPrint('Error selesaikanGiling: $e');
    }

    await loadAll();
  }

  // ── updateStatus (tetap ada untuk kompatibilitas) ─────
  Future<void> updateStatus(String id, String statusBaru) async {
    await _db.updateStatus(id, statusBaru);
    await loadAll();
  }

  // ── Stok keluar ───────────────────────────────────────
  Future<void> tambahStokKeluar({
    required String judul,
    required double jumlah,
    required String tanggal,
  }) async {
    try {
      final stokBaru = _stokGudang - jumlah;
      await _db.updateStok(stokBaru);
      await _db.insertTransaksi({
        'id':       '${DateTime.now().millisecondsSinceEpoch}',
        'judul':    judul,
        'subjudul': tanggal,
        'tanggal':  tanggal,
        'jumlah':   -jumlah,
        'tipe':     'Stok Keluar',
        'status':   '',
      });
    } catch (e) {
      debugPrint('Error tambahStokKeluar: $e');
    }

    await loadAll();
  }

  // ── Hapus padi ────────────────────────────────────────
  Future<void> hapusPadi(String id) async {
    await _db.deletePadi(id);
    await loadAll();
  }
}