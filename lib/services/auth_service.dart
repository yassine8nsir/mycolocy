import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import 'api_service.dart';

/// Handles all auth-related API calls and token persistence.
class AuthService {
  final ApiService _api = ApiService();

  // ── Register ────────────────────────────────────────────────
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    String? phone,
    String? university,
    String role = 'student',
  }) async {
    final result = await _api.post('/auth/register', {
      'fullName': fullName,
      'email': email,
      'password': password,
      if (phone != null) 'phone': phone,
      if (university != null) 'university': university,
      'role': role,
    });

    final token = result['data']['token'] as String;
    final user = UserModel.fromJson(result['data']['user']);
    await _saveToken(token);
    _api.setToken(token);

    return {'token': token, 'user': user};
  }

  // ── Login ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final token = result['data']['token'] as String;
    final user = UserModel.fromJson(result['data']['user']);
    await _saveToken(token);
    _api.setToken(token);

    return {'token': token, 'user': user};
  }

  // ── Get current user ────────────────────────────────────────
  Future<UserModel?> getMe() async {
    final token = await getStoredToken();
    if (token == null) return null;
    _api.setToken(token);

    final result = await _api.get('/auth/me');
    return UserModel.fromJson(result['data']['user']);
  }

  // ── Update profile ──────────────────────────────────────────
  Future<UserModel> updateProfile(Map<String, dynamic> fields) async {
    final result = await _api.put('/auth/update-profile', fields);
    return UserModel.fromJson(result['data']['user']);
  }

  // ── Logout ──────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    _api.clearToken();
  }

  // ── Token helpers ───────────────────────────────────────────
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }
}
