import 'package:flutter/foundation.dart';
import '../models/siaga_status_model.dart';
import '../services/firestore_service.dart';

class SiagaProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  SiagaStatusModel? _status;

  SiagaStatusModel? get status => _status;

  SiagaProvider() {
    _listenToSiagaStatus();
  }

  void _listenToSiagaStatus() {
    _firestoreService.siagaStatus.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        _status = SiagaStatusModel.fromFirestore(snapshot);
        notifyListeners();
      }
    });
  }

  Future<void> updateStatus({
    required int level,
    required String levelLabel,
    required String description,
    required String updatedBy,
    required String updatedByName,
    required double dangerRadius,
  }) async {
    await _firestoreService.updateSiagaStatus({
      'level': level,
      'levelLabel': levelLabel,
      'description': description,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'updatedAt': DateTime.now(),
      'dangerRadius': dangerRadius,
    });
  }
}
