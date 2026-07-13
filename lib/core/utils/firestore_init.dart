import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreInit {
  static Future<void> initializeSiagaStatus() async {
    final doc = FirebaseFirestore.instance.collection('siaga_status').doc('current');
    final snapshot = await doc.get();
    
    if (!snapshot.exists) {
      await doc.set({
        'level': 1,
        'levelLabel': 'Normal',
        'description': 'Status Normal',
        'updatedBy': '',
        'updatedByName': 'Sistem',
        'updatedAt': Timestamp.now(),
      });
    }
  }

  static Future<void> setUserAsAdmin(String uid) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'role': 'admin',
    });
  }
}
