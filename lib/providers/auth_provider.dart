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
      final doc = await _firestoreService
          .getUserData(firebaseUser.uid)
          .timeout(const Duration(seconds: 10));
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
      // Fetch user document with safety timeout
      final doc = await _firestoreService
          .getUserData(uid)
          .timeout(const Duration(seconds: 10));
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
      } else {
        _error = 'Data pengguna tidak ditemukan. Silakan hubungi admin.';
      }
      return _user != null;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Login gagal';
      return false;
    } catch (e) {
      // Catches FirebaseException (permission-denied), TimeoutException,
      // SocketException, TypeError, and any other unexpected errors
      _error = 'Terjadi kesalahan koneksi. Periksa internet Anda dan coba lagi.';
      debugPrint('Login error: $e');
      return false;
    } finally {
      // Guarantee loading state is always reset, preventing infinite buffering
      _isLoading = false;
      notifyListeners();
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
      await _firestoreService
          .setUserData(uid, userData.toFirestore())
          .timeout(const Duration(seconds: 10));
      _user = userData;
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? 'Registrasi gagal';
      return false;
    } catch (e) {
      _error = 'Terjadi kesalahan koneksi. Periksa internet Anda dan coba lagi.';
      debugPrint('Register error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
