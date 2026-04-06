import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

/// Base HTTP service — all other services extend or use this.
/// Handles auth headers, JSON parsing, and error normalization.
class ApiService {
  final String _base = AppConstants.baseUrl;
  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ── GET ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('$_base$endpoint');
    final response = await http.get(uri, headers: _headers);
    return _parse(response);
  }

  // ── POST ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_base$endpoint');
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _parse(response);
  }

  // ── PUT ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_base$endpoint');
    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _parse(response);
  }

  // ── DELETE ─────────────────────────────────────────────────
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final uri = Uri.parse('$_base$endpoint');
    final response = await http.delete(uri, headers: _headers);
    return _parse(response);
  }

  // ── Response parser ─────────────────────────────────────────
  Map<String, dynamic> _parse(http.Response response) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      message: body['message'] ?? 'Something went wrong',
      statusCode: response.statusCode,
    );
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  const ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
