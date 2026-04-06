import 'package:flutter/material.dart';
import '../models/housing_model.dart';
import '../models/recommendation_model.dart';
import '../services/recommendation_service.dart';
import '../services/api_service.dart';

class RecommendationProvider extends ChangeNotifier {
  final RecommendationService _service = RecommendationService();

  List<RecommendationModel> _recommendations = [];
  List<HousingModel> _trending = [];
  bool _isLoading = false;
  bool _trendingLoaded = false;
  String? _errorMessage;

  List<RecommendationModel> get recommendations => _recommendations;
  List<HousingModel> get trending => _trending;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRecommendations() async {
    _setLoading(true);
    try {
      _recommendations = await _service.getRecommendations();
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTrending() async {
    if (_trendingLoaded) return; // load once per session
    try {
      _trending = await _service.getTrending();
      _trendingLoaded = true;
      notifyListeners();
    } catch (_) {}
  }

  // Call this when the user taps on a listing — fire and forget
  void recordView(String housingId) {
    _service.recordView(housingId);
    // Optimistically remove from recommendations so it won't show again
    _recommendations.removeWhere((r) => r.housing.id == housingId);
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
