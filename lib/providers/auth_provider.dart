import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Global auth state — wrap MaterialApp with `ChangeNotifierProvider<AuthProvider>`.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Expose the stored JWT so other providers (e.g. ChatProvider) can use it.
  Future<String?> getToken() => _authService.getStoredToken();

  // ── Called once at app start ────────────────────────────────
  Future<void> checkAuth() async {
    try {
      final user = await _authService.getMe();
      if (user != null) {
        _user = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Register ────────────────────────────────────────────────
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? university,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        phone: phone,
        university: university,
      );
      _user = result['user'] as UserModel;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Login ───────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.login(email: email, password: password);
      _user = result['user'] as UserModel;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout ──────────────────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Update profile ──────────────────────────────────────────
  Future<bool> updateProfile(Map<String, dynamic> fields) async {
    _setLoading(true);
    try {
      _user = await _authService.updateProfile(fields);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
