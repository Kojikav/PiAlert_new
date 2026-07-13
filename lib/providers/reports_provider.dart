import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ReportsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  List<ReportModel> _reports = [];
  bool _isLoading = false;
  String? _lastErrorMessage;

  List<ReportModel> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get lastErrorMessage => _lastErrorMessage;

  ReportsProvider() {
    _listenToReports();
  }

  void _listenToReports() {
    _firestoreService.reports
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _reports = snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  Future<({bool success, String? message})> submitReport({
    required String reportId,
    required String authorUid,
    required String authorName,
    required String category,
    required String description,
    File? photoFile,
    required double latitude,
    required double longitude,
    required String locationLabel,
    required int siagaLevel,
  }) async {
    try {
      String? photoUrl;
      if (photoFile != null) {
        photoUrl = await _storageService.uploadReportPhoto(
          reportId: reportId,
          file: photoFile,
        );
      }

      final report = ReportModel(
        id: reportId,
        authorUid: authorUid,
        authorName: authorName,
        category: category,
        description: description,
        photoUrl: photoUrl,
        latitude: latitude,
        longitude: longitude,
        locationLabel: locationLabel,
        isVerified: false,
        isDeleted: false,
        siagaLevel: siagaLevel,
        createdAt: DateTime.now(),
      );

      await _firestoreService.setReport(reportId, report.toFirestore());
      _lastErrorMessage = null;
      return (success: true, message: null);
    } on SocketException {
      _lastErrorMessage = 'Koneksi internet terputus. Periksa koneksi Anda dan coba lagi.';
      debugPrint('Socket error: no internet connection');
      return (success: false, message: _lastErrorMessage);
    } on FirebaseException catch (e) {
      _lastErrorMessage = 'Gagal menyimpan laporan: ${e.message}';
      debugPrint('Firebase error: $e');
      return (success: false, message: _lastErrorMessage);
    } catch (e) {
      _lastErrorMessage = 'Gagal mengirim laporan: terjadi kesalahan yang tidak diketahui';
      debugPrint('Submit report error: $e');
      return (success: false, message: _lastErrorMessage);
    }
  }

  Future<void> refresh() async {
    _isLoading = true;
    notifyListeners();
    final snapshot = await _firestoreService.reports
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();
    _reports = snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteReport(String reportId) async {
    await _firestoreService.deleteReport(reportId);
  }
}
