import 'package:cloud_firestore/cloud_firestore.dart';

class SafetyConfirmationModel {
  final String uid;
  final String name;
  final double? latitude;
  final double? longitude;
  final int siagaLevel;
  final DateTime confirmedAt;

  SafetyConfirmationModel({
    required this.uid,
    required this.name,
    this.latitude,
    this.longitude,
    required this.siagaLevel,
    required this.confirmedAt,
  });

  factory SafetyConfirmationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SafetyConfirmationModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      siagaLevel: data['siagaLevel'] ?? 1,
      confirmedAt: (data['confirmedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'siagaLevel': siagaLevel,
      'confirmedAt': Timestamp.fromDate(confirmedAt),
    };
  }
}
