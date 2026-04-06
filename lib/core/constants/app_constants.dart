/// Central place for every app-wide constant.
/// Change baseUrl here when switching between dev / prod.
class AppConstants {
  AppConstants._(); // prevent instantiation

  // ── API ──────────────────────────────────────────────────────
  /// Production URL (Railway deployment).
  /// For local dev: 'http://10.0.2.2:5000/api' (Android emulator)
  ///                'http://192.168.1.x:5000/api' (real device)
  static const String baseUrl = 'http://localhost:5000/api';

  // ── JWT ──────────────────────────────────────────────────────
  static const String tokenKey = 'auth_token';
  static const String userKey = 'current_user';

  // ── Pagination ───────────────────────────────────────────────
  static const int pageSize = 10;

  // ── App info ─────────────────────────────────────────────────
  static const String appName = 'MyColocy';
  static const String appVersion = '1.0.0';
}
