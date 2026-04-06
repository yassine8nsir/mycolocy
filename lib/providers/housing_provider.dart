import 'dart:io';
import 'package:flutter/material.dart';
import '../models/housing_model.dart';
import '../services/housing_service.dart';
import '../services/api_service.dart';

class HousingProvider extends ChangeNotifier {
  final HousingService _service = HousingService();

  List<HousingModel> _listings = [];
  List<HousingModel> _myListings = [];
  List<HousingModel> _searchResults = [];
  HousingModel? _selected;
  bool _isLoading = false;
  bool _isSearching = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _errorMessage;

  // Filter meta (cities/types from backend)
  List<String> _availableCities = [];
  List<String> _availableTypes = [];

  List<HousingModel> get listings => _listings;
  List<HousingModel> get myListings => _myListings;
  List<HousingModel> get searchResults => _searchResults;
  HousingModel? get selected => _selected;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  bool get hasMore => _hasMore;
  String? get errorMessage => _errorMessage;
  List<String> get availableCities => _availableCities;
  List<String> get availableTypes => _availableTypes;

  // ── Load filter meta (cities + types) ──────────────────────
  Future<void> loadMeta() async {
    try {
      final result = await _service.getMeta();
      _availableCities = List<String>.from(result['cities'] ?? []);
      _availableTypes = List<String>.from(result['types'] ?? []);
      notifyListeners();
    } catch (_) {}
  }

  // ── Search with all filters ─────────────────────────────────
  Future<void> search({
    String? query,
    String? city,
    String? university,
    double? minPrice,
    double? maxPrice,
    int? rooms,
    String? type,
    bool? furnished,
  }) async {
    _isSearching = true;
    notifyListeners();
    try {
      final result = await _service.getAll(
        search: query,
        city: city,
        university: university,
        minPrice: minPrice,
        maxPrice: maxPrice,
        rooms: rooms,
        type: type,
        furnished: furnished,
        limit: 50,
      );
      _searchResults = result['housing'] as List<HousingModel>;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  // ── Load listings (with optional filters) ──────────────────
  Future<void> loadListings({
    bool refresh = false,
    String? city,
    String? university,
    double? minPrice,
    double? maxPrice,
    int? rooms,
    String? type,
    bool? furnished,
    String? search,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _listings = [];
    }
    if (!_hasMore || _isLoading) return;

    _setLoading(true);
    try {
      final result = await _service.getAll(
        city: city,
        university: university,
        minPrice: minPrice,
        maxPrice: maxPrice,
        rooms: rooms,
        type: type,
        furnished: furnished,
        search: search,
        page: _currentPage,
      );

      final newItems = result['housing'] as List<HousingModel>;
      final pagination = result['pagination'] as Map<String, dynamic>;

      _listings.addAll(newItems);
      _hasMore = _currentPage < (pagination['pages'] as int);
      _currentPage++;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  // ── Load single listing ─────────────────────────────────────
  Future<void> loadById(String id) async {
    _setLoading(true);
    try {
      _selected = await _service.getById(id);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  // ── Load my listings ────────────────────────────────────────
  Future<void> loadMyListings() async {
    _setLoading(true);
    try {
      _myListings = await _service.getMyListings();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } finally {
      _setLoading(false);
    }
  }

  // ── Create ──────────────────────────────────────────────────
  Future<bool> create({
    required Map<String, String> fields,
    List<File> images = const [],
  }) async {
    _setLoading(true);
    try {
      final housing = await _service.create(fields: fields, images: images);
      _myListings.insert(0, housing);
      _listings.insert(0, housing);
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

  // ── Delete ──────────────────────────────────────────────────
  Future<bool> delete(String id) async {
    try {
      await _service.delete(id);
      _listings.removeWhere((h) => h.id == id);
      _myListings.removeWhere((h) => h.id == id);
      if (_selected?.id == id) _selected = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
