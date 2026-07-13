import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get users => _db.collection('users');

  Future<void> setUserData(String uid, Map<String, dynamic> data) async {
    await users.doc(uid).set(data, SetOptions(merge: true));
  }

  Future<DocumentSnapshot> getUserData(String uid) async {
    return await users.doc(uid).get();
  }

  Future<void> updateUserField(String uid, Map<String, dynamic> fields) async {
    await users.doc(uid).update(fields);
  }

  DocumentReference get siagaStatus => _db.collection('siaga_status').doc('current');

  Future<void> updateSiagaStatus(Map<String, dynamic> data) async {
    await siagaStatus.set(data);
  }

  CollectionReference get reports => _db.collection('reports');

  Future<void> setReport(String id, Map<String, dynamic> data) async {
    await reports.doc(id).set(data);
  }

  Future<DocumentReference> createReport(Map<String, dynamic> data) async {
    return await reports.add(data);
  }

  Future<void> deleteReport(String reportId) async {
    await reports.doc(reportId).update({'isDeleted': true});
  }

  CollectionReference get announcements => _db.collection('announcements');

  Future<DocumentReference> createAnnouncement(Map<String, dynamic> data) async {
    return await announcements.add(data);
  }

  Future<void> deactivateAnnouncement(String announcementId) async {
    await announcements.doc(announcementId).update({'isActive': false});
  }

  CollectionReference get safetyConfirmations => _db.collection('safety_confirmations');

  Future<void> setSafetyConfirmation(String uid, Map<String, dynamic> data) async {
    await safetyConfirmations.doc(uid).set(data);
  }

  Future<DocumentSnapshot> getSafetyConfirmation(String uid) async {
    return await safetyConfirmations.doc(uid).get();
  }
}
