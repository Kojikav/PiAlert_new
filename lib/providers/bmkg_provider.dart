import 'package:flutter/foundation.dart';
import '../models/gempa_model.dart';
import '../services/bmkg_service.dart';

class BmkgProvider extends ChangeNotifier {
  final BmkgService _service = BmkgService();

  GempaModel? _gempaTerbaru;
  List<GempaModel> _gempaTerkini = [];
  List<GempaModel> _gempaDirasakan = [];
  bool _isLoading = false;
  String? _errorMessage;

  GempaModel? get gempaTerbaru => _gempaTerbaru;
  List<GempaModel> get gempaTerkini => _gempaTerkini;
  List<GempaModel> get gempaDirasakan => _gempaDirasakan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BmkgProvider() {
    fetchAll();
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _service.getGempaTerbaru(),
        _service.getGempaTerkini(),
        _service.getGempaDirasakan(),
      ]);
      _gempaTerbaru = results[0] as GempaModel;
      _gempaTerkini = results[1] as List<GempaModel>;
      _gempaDirasakan = results[2] as List<GempaModel>;
    } catch (e) {
      _errorMessage = 'Gagal memuat data BMKG. Periksa koneksi internet.';
      debugPrint('BmkgProvider fetchAll error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
