import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/housing_model.dart';
import '../models/recommendation_model.dart';
import 'api_service.dart';

class RecommendationService {
  final ApiService _api = ApiService();

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token != null) _api.setToken(token);
  }

  // Personalised recommendations for logged-in user
  Future<List<RecommendationModel>> getRecommendations({int limit = 10}) async {
    await _loadToken();
    final result =
        await _api.get('/recommendations?limit=$limit');
    return (result['data']['recommendations'] as List)
        .map((j) => RecommendationModel.fromJson(j))
        .toList();
  }

  // Record that the user opened a listing
  Future<void> recordView(String housingId) async {
    await _loadToken();
    try {
      await _api.post('/recommendations/view/$housingId', {});
    } catch (_) {
      // Non-critical — swallow errors silently
    }
  }

  // Trending listings (no auth needed)
  Future<List<HousingModel>> getTrending({int limit = 6}) async {
    final result = await _api.get('/recommendations/trending?limit=$limit');
    return (result['data']['listings'] as List)
        .map((j) => HousingModel.fromJson(j))
        .toList();
  }
}
