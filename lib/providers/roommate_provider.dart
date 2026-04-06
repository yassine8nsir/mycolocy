import 'package:flutter/material.dart';
import '../models/roommate_model.dart';
import '../services/roommate_service.dart';
import '../services/api_service.dart';

class RoommateProvider extends ChangeNotifier {
  final RoommateService _service = RoommateService();

  List<RoommateMatch> _matches = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  int _minScore = 0;

  List<RoommateMatch> get matches => _matches;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  int get minScore => _minScore;

  Future<void> loadMatches({int minScore = 0}) async {
    _minScore = minScore;
    _setLoading(true);
    try {
      _matches = await _service.getMatches(minScore: minScore);
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> savePreferences(Map<String, dynamic> prefs) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _service.updatePreferences(prefs);
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void filterByMinScore(int score) {
    _minScore = score;
    notifyListeners();
  }

  List<RoommateMatch> get filtered =>
      _matches.where((m) => m.score >= _minScore).toList();

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
