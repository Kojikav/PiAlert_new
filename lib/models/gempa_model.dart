class GempaModel {
  final String tanggal;
  final String jam;
  final String dateTime;
  final String coordinates;
  final String lintang;
  final String bujur;
  final String magnitude;
  final String kedalaman;
  final String wilayah;
  final String? potensi;
  final String? dirasakan;
  final String? shakemap;

  GempaModel({
    required this.tanggal,
    required this.jam,
    required this.dateTime,
    required this.coordinates,
    required this.lintang,
    required this.bujur,
    required this.magnitude,
    required this.kedalaman,
    required this.wilayah,
    this.potensi,
    this.dirasakan,
    this.shakemap,
  });

  factory GempaModel.fromJson(Map<String, dynamic> json) {
    return GempaModel(
      tanggal: json['Tanggal'] ?? '',
      jam: json['Jam'] ?? '',
      dateTime: json['DateTime'] ?? '',
      coordinates: json['Coordinates'] ?? '',
      lintang: json['Lintang'] ?? '',
      bujur: json['Bujur'] ?? '',
      magnitude: json['Magnitude'] ?? '',
      kedalaman: json['Kedalaman'] ?? '',
      wilayah: json['Wilayah'] ?? '',
      potensi: json['Potensi'],
      dirasakan: json['Dirasakan'],
      shakemap: json['Shakemap'],
    );
  }

  double get magnitudeValue => double.tryParse(magnitude) ?? 0;

  double get lat {
    final parts = coordinates.split(',');
    return double.tryParse(parts[0]) ?? 0;
  }

  double get lng {
    final parts = coordinates.split(',');
    return parts.length > 1 ? (double.tryParse(parts[1]) ?? 0) : 0;
  }
}
