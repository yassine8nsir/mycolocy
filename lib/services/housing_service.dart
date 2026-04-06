import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/housing_model.dart';
import 'api_service.dart';

class HousingService {
  final ApiService _api = ApiService();
  final String _base = AppConstants.baseUrl;

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    if (token != null) _api.setToken(token);
  }

  // ── Get all (with optional filters) ────────────────────────
  Future<Map<String, dynamic>> getAll({
    String? city,
    String? university,
    double? minPrice,
    double? maxPrice,
    int? rooms,
    String? type,
    bool? furnished,
    String? search,
    int page = 1,
    int limit = 10,
  }) async {
    await _loadToken();

    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (city != null && city.isNotEmpty) 'city': city,
      if (university != null && university.isNotEmpty) 'university': university,
      if (minPrice != null) 'minPrice': '$minPrice',
      if (maxPrice != null) 'maxPrice': '$maxPrice',
      if (rooms != null) 'rooms': '$rooms',
      if (type != null) 'type': type,
      if (furnished != null) 'furnished': '$furnished',
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final uri = Uri.parse('$_base/housing').replace(queryParameters: params);
    final result = await _api.get('/housing?${uri.query}');

    final items = (result['data']['housing'] as List)
        .map((j) => HousingModel.fromJson(j))
        .toList();

    return {
      'housing': items,
      'pagination': result['data']['pagination'],
    };
  }

  // ── Get filter meta (cities + types) ───────────────────────
  Future<Map<String, dynamic>> getMeta() async {
    final result = await _api.get('/housing/meta/filters');
    return result['data'] as Map<String, dynamic>;
  }

  // ── Get single ──────────────────────────────────────────────
  Future<HousingModel> getById(String id) async {
    await _loadToken();
    final result = await _api.get('/housing/$id');
    return HousingModel.fromJson(result['data']['housing']);
  }

  // ── Get my listings ─────────────────────────────────────────
  Future<List<HousingModel>> getMyListings() async {
    await _loadToken();
    final result = await _api.get('/housing/my-listings');
    return (result['data']['housing'] as List)
        .map((j) => HousingModel.fromJson(j))
        .toList();
  }

  // ── Create (multipart — supports images) ───────────────────
  Future<HousingModel> create({
    required Map<String, String> fields,
    List<File> images = const [],
  }) async {
    await _loadToken();
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);

    final uri = Uri.parse('$_base/housing');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.fields.addAll(fields);

    for (final img in images) {
      request.files.add(await http.MultipartFile.fromPath('images', img.path));
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 201) {
      throw ApiException(
          message: body['message'] ?? 'Failed to create listing',
          statusCode: response.statusCode);
    }

    return HousingModel.fromJson(body['data']['housing']);
  }

  // ── Update ──────────────────────────────────────────────────
  Future<HousingModel> update(String id, Map<String, dynamic> fields) async {
    await _loadToken();
    final result = await _api.put('/housing/$id', fields);
    return HousingModel.fromJson(result['data']['housing']);
  }

  // ── Delete ──────────────────────────────────────────────────
  Future<void> delete(String id) async {
    await _loadToken();
    await _api.delete('/housing/$id');
  }
}
