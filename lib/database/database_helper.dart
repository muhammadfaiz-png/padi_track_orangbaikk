import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/padi_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('paditrack.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 2, // ✅ versi naik karena ada kolom baru
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE padi (
        id            TEXT PRIMARY KEY,
        namaPetani    TEXT NOT NULL,
        tanggal       TEXT NOT NULL,
        jumlahKarung  INTEGER NOT NULL,
        catatan       TEXT DEFAULT '',
        status        TEXT NOT NULL DEFAULT 'Menunggu Giling',
        totalBeras    INTEGER DEFAULT 0,
        diambilPetani INTEGER DEFAULT 0,
        dijualPabrik  INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE stok (
        id      INTEGER PRIMARY KEY,
        jumlah  REAL NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE transaksi (
        id        TEXT PRIMARY KEY,
        judul     TEXT NOT NULL,
        subjudul  TEXT NOT NULL,
        tanggal   TEXT NOT NULL,
        jumlah    REAL NOT NULL,
        tipe      TEXT NOT NULL,
        status    TEXT DEFAULT ''
      )
    ''');

    final batch = db.batch();
    batch.insert('padi', {
      'id': '1',
      'namaPetani': 'Budi Santoso',
      'tanggal': '12 Mei 2026',
      'jumlahKarung': 10,
      'catatan': '',
      'status': 'Menunggu Giling',
      'totalBeras': 0,
      'diambilPetani': 0,
      'dijualPabrik': 0,
    });
    batch.insert('padi', {
      'id': '2',
      'namaPetani': 'Siti Rahma',
      'tanggal': '12 Mei 2026',
      'jumlahKarung': 25,
      'catatan': '',
      'status': 'Dalam Proses',
      'totalBeras': 0,
      'diambilPetani': 0,
      'dijualPabrik': 0,
    });
    batch.insert('padi', {
      'id': '3',
      'namaPetani': 'Agus Pratama',
      'tanggal': '11 Mei 2026',
      'jumlahKarung': 8,
      'catatan': '',
      'status': 'Menunggu Giling',
      'totalBeras': 0,
      'diambilPetani': 0,
      'dijualPabrik': 0,
    });
    batch.insert('stok', {'id': 1, 'jumlah': 0.0});
    batch.insert('transaksi', {
      'id': 't1',
      'judul': 'Hasil Giling Budi',
      'subjudul': '12 Mei 2026',
      'tanggal': '12 Mei 2026',
      'jumlah': 5.0,
      'tipe': 'Giling',
      'status': 'Selesai',
    });
    batch.insert('transaksi', {
      'id': 't2',
      'judul': 'Penjualan Beras',
      'subjudul': '13 Mei 2026',
      'tanggal': '13 Mei 2026',
      'jumlah': -3.0,
      'tipe': 'Stok Keluar',
      'status': '',
    });
    await batch.commit(noResult: true);
  }

  // ✅ Upgrade database jika versi lama
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE padi ADD COLUMN totalBeras INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE padi ADD COLUMN diambilPetani INTEGER DEFAULT 0',
      );
      await db.execute(
        'ALTER TABLE padi ADD COLUMN dijualPabrik INTEGER DEFAULT 0',
      );
    }
  }

  // ── PADI ─────────────────────────────────────────────
  Future<int> insertPadi(PadiModel padi) async {
    final db = await database;
    return await db.insert(
      'padi',
      padi.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<PadiModel>> getAllPadi() async {
    final db = await database;
    final result = await db.query('padi', orderBy: 'rowid DESC');
    return result.map((m) => PadiModel.fromMap(m)).toList();
  }

  Future<int> updateStatus(String id, String status) async {
    final db = await database;
    return await db.update(
      'padi',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✅ Update hasil giling (simpan nilai yang diinput user)
  Future<void> updateHasilGiling({
    required String id,
    required int totalBeras,
    required int diambilPetani,
    required int dijualPabrik,
  }) async {
    final db = await database;
    await db.update(
      'padi',
      {
        'status': 'Selesai',
        'totalBeras': totalBeras,
        'diambilPetani': diambilPetani,
        'dijualPabrik': dijualPabrik,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePadi(String id) async {
    final db = await database;
    return await db.delete('padi', where: 'id = ?', whereArgs: [id]);
  }

  // ── STATS ────────────────────────────────────────────
  Future<Map<String, dynamic>> getStats() async {
    final db = await database;

    // ✅ Padi masuk hari ini berdasarkan tanggal hari ini
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

    final statsResult = await db.rawQuery(
      '''
      SELECT
        COUNT(DISTINCT namaPetani) AS totalPetani,
        COALESCE(SUM(CASE WHEN status = 'Menunggu Giling'
                     THEN jumlahKarung ELSE 0 END), 0) AS padiBelumGiling,
        COALESCE(SUM(CASE WHEN tanggal = ?
                     THEN jumlahKarung ELSE 0 END), 0) AS padiMasukHariIni
      FROM padi
    ''',
      [tanggalHariIni],
    );

    final stokResult = await db.query('stok', where: 'id = ?', whereArgs: [1]);
    final stok = stokResult.isEmpty
        ? 0.0
        : (stokResult.first['jumlah'] as num).toDouble();

    final row = statsResult.first;
    return {
      'totalPetani': row['totalPetani'] ?? 0,
      'padiBelumGiling': row['padiBelumGiling'] ?? 0,
      'padiMasukHariIni': row['padiMasukHariIni'] ?? 0,
      'stokBeras': stok,
    };
  }

  // ── STOK ─────────────────────────────────────────────
  Future<double> getStok() async {
    final db = await database;
    final result = await db.query('stok', where: 'id = ?', whereArgs: [1]);
    if (result.isEmpty) return 0.0;
    return (result.first['jumlah'] as num).toDouble();
  }

  Future<void> updateStok(double jumlah) async {
    final db = await database;
    await db.update(
      'stok',
      {'jumlah': jumlah},
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  // ── TRANSAKSI ─────────────────────────────────────────
  Future<void> insertTransaksi(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(
      'transaksi',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAllTransaksi() async {
    final db = await database;
    return await db.query('transaksi', orderBy: 'rowid DESC');
  }
}
