class PadiModel {
  final String id;
  final String namaPetani;
  final String tanggal;
  final int jumlahKarung;
  final String catatan;
  final String status;
  // ✅ Field baru untuk simpan hasil giling
  final int totalBeras;
  final int diambilPetani;
  final int dijualPabrik;

  PadiModel({
    required this.id,
    required this.namaPetani,
    required this.tanggal,
    required this.jumlahKarung,
    this.catatan = '',
    this.status = 'Menunggu Giling',
    this.totalBeras = 0,
    this.diambilPetani = 0,
    this.dijualPabrik = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaPetani': namaPetani,
      'tanggal': tanggal,
      'jumlahKarung': jumlahKarung,
      'catatan': catatan,
      'status': status,
      'totalBeras': totalBeras,
      'diambilPetani': diambilPetani,
      'dijualPabrik': dijualPabrik,
    };
  }

  factory PadiModel.fromMap(Map<String, dynamic> map) {
    return PadiModel(
      id: map['id'] as String,
      namaPetani: map['namaPetani'] as String,
      tanggal: map['tanggal'] as String,
      jumlahKarung: map['jumlahKarung'] as int,
      catatan: map['catatan'] as String? ?? '',
      status: map['status'] as String,
      totalBeras: map['totalBeras'] as int? ?? 0,
      diambilPetani: map['diambilPetani'] as int? ?? 0,
      dijualPabrik: map['dijualPabrik'] as int? ?? 0,
    );
  }

  PadiModel copyWith({
    String? id,
    String? namaPetani,
    String? tanggal,
    int? jumlahKarung,
    String? catatan,
    String? status,
    int? totalBeras,
    int? diambilPetani,
    int? dijualPabrik,
  }) {
    return PadiModel(
      id: id ?? this.id,
      namaPetani: namaPetani ?? this.namaPetani,
      tanggal: tanggal ?? this.tanggal,
      jumlahKarung: jumlahKarung ?? this.jumlahKarung,
      catatan: catatan ?? this.catatan,
      status: status ?? this.status,
      totalBeras: totalBeras ?? this.totalBeras,
      diambilPetani: diambilPetani ?? this.diambilPetani,
      dijualPabrik: dijualPabrik ?? this.dijualPabrik,
    );
  }
}
