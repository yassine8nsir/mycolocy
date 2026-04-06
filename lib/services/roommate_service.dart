import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/roommate_model.dart';
import 'api_service.dart';

class RoommateService {
  final ApiService _api = ApiService();

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token != null) _api.setToken(token);
  }

  Future<List<RoommateMatch>> getMatches({int minScore = 0}) async {
    await _loadToken();
    final result =
        await _api.get('/roommates/matches?minScore=$minScore&limit=30');
    return (result['data']['matches'] as List)
        .map((j) => RoommateMatch.fromJson(j))
        .toList();
  }

  Future<RoommateMatch> getScoreWith(String userId) async {
    await _loadToken();
    final result = await _api.get('/roommates/score/$userId');
    return RoommateMatch.fromJson(result['data']);
  }

  Future<void> updatePreferences(Map<String, dynamic> prefs) async {
    await _loadToken();
    await _api.put('/roommates/preferences', prefs);
  }
}
