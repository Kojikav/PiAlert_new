import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/notification_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAdmin => _user?.role == 'admin';

  AuthProvider() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser == null) return;
    try {
      final doc = await _firestoreService.getUserData(firebaseUser.uid);
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
        notifyListeners();
      }
      await _saveFcmToken();
    } catch (_) {}
  }

  Future<void> _saveFcmToken() async {
    if (_user == null) return;
    try {
      final token = await _notificationService.getToken();
      if (token != null && token != _user!.fcmToken) {
        await _firestoreService.updateUserField(_user!.uid, {'fcmToken': token});
      }
    } catch (_) {}
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.login(email: email, password: password);
      final uid = _authService.currentUser!.uid;
      final doc = await _firestoreService.getUserData(uid);
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
      }
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Login gagal';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final cred = await _authService.register(
        email: email,
        password: password,
      );
      final uid = cred.user!.uid;
      final userData = UserModel(
        uid: uid,
        name: name,
        email: email,
        role: 'warga',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestoreService.setUserData(uid, userData.toFirestore());
      _user = userData;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Registrasi gagal';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    notifyListeners();
    await _authService.logout();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
