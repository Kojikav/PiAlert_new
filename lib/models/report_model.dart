import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String id;
  final String authorUid;
  final String authorName;
  final String category;
  final String description;
  final String? photoUrl;
  final double latitude;
  final double longitude;
  final String locationLabel;
  final bool isVerified;
  final bool isDeleted;
  final int siagaLevel;
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.category,
    required this.description,
    this.photoUrl,
    required this.latitude,
    required this.longitude,
    required this.locationLabel,
    this.isVerified = false,
    this.isDeleted = false,
    required this.siagaLevel,
    required this.createdAt,
  });

  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: data['id'] ?? '',
      authorUid: data['authorUid'] ?? '',
      authorName: data['authorName'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      photoUrl: data['photoUrl'],
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      locationLabel: data['locationLabel'] ?? '',
      isVerified: data['isVerified'] ?? false,
      isDeleted: data['isDeleted'] ?? false,
      siagaLevel: data['siagaLevel'] ?? 1,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'authorUid': authorUid,
      'authorName': authorName,
      'category': category,
      'description': description,
      'photoUrl': photoUrl,
      'latitude': latitude,
      'longitude': longitude,
      'locationLabel': locationLabel,
      'isVerified': isVerified,
      'isDeleted': isDeleted,
      'siagaLevel': siagaLevel,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
