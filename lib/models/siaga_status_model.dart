import 'package:cloud_firestore/cloud_firestore.dart';

class SiagaStatusModel {
  final int level;
  final String levelLabel;
  final String description;
  final String updatedBy;
  final String updatedByName;
  final DateTime updatedAt;
  final double dangerRadius;

  SiagaStatusModel({
    required this.level,
    required this.levelLabel,
    required this.description,
    required this.updatedBy,
    required this.updatedByName,
    required this.updatedAt,
    required this.dangerRadius,
  });

  factory SiagaStatusModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SiagaStatusModel(
      level: data['level'] ?? 1,
      levelLabel: data['levelLabel'] ?? 'Normal',
      description: data['description'] ?? '',
      updatedBy: data['updatedBy'] ?? '',
      updatedByName: data['updatedByName'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      dangerRadius: (data['dangerRadius'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'level': level,
      'levelLabel': levelLabel,
      'description': description,
      'updatedBy': updatedBy,
      'updatedByName': updatedByName,
      'updatedAt': Timestamp.fromDate(updatedAt),
      'dangerRadius': dangerRadius,
    };
  }
}
