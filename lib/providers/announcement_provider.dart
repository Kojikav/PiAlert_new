import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/announcement_model.dart';
import '../services/firestore_service.dart';

class AnnouncementProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<AnnouncementModel> _announcements = [];

  List<AnnouncementModel> get announcements => _announcements;

  AnnouncementProvider() {
    _listenToAnnouncements();
  }

  void _listenToAnnouncements() {
    _firestoreService.announcements
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _announcements = snapshot.docs.map((doc) => AnnouncementModel.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  Future<void> createAnnouncement({
    required String title,
    required String content,
    required String type,
    required String createdBy,
    required String createdByName,
  }) async {
    final id = const Uuid().v4();
    final now = DateTime.now();
    await _firestoreService.createAnnouncement({
      'id': id,
      'title': title,
      'content': content,
      'type': type,
      'isActive': true,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<void> deactivateAnnouncement(String id) async {
    await _firestoreService.deactivateAnnouncement(id);
  }
}
