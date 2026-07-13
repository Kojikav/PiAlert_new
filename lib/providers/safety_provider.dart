import 'package:flutter/foundation.dart';
import '../models/safety_confirmation_model.dart';
import '../services/firestore_service.dart';
import '../services/location_service.dart';

class SafetyProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final LocationService _locationService = LocationService();

  SafetyConfirmationModel? _myConfirmation;
  bool _isLoading = false;

  SafetyConfirmationModel? get myConfirmation => _myConfirmation;
  bool get isLoading => _isLoading;

  void listenToMyConfirmation(String uid) {
    _firestoreService.safetyConfirmations.doc(uid).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        _myConfirmation = SafetyConfirmationModel.fromFirestore(snapshot);
      } else {
        _myConfirmation = null;
      }
      notifyListeners();
    });
  }

  Future<bool> confirm({
    required String uid,
    required String name,
    int? siagaLevel,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      double? lat;
      double? lng;
      try {
        final hasPermission = await _locationService.requestPermission();
        if (hasPermission) {
          final pos = await _locationService.getCurrentLocation();
          lat = pos.latitude;
          lng = pos.longitude;
        }
      } catch (_) {}

      await _firestoreService.setSafetyConfirmation(uid, {
        'uid': uid,
        'name': name,
        'latitude': lat,
        'longitude': lng,
        'siagaLevel': siagaLevel,
        'confirmedAt': DateTime.now(),
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Safety confirm error: $e');
      return false;
    }
  }
}
