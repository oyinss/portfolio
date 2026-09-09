/// HTTP layer for the Cloudflare API (§39).
/// Base URL comes from `--dart-define=API_URL=...`; empty means mock mode.
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

const apiBaseUrl = String.fromEnvironment('API_URL', defaultValue: '');

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  const ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final String baseUrl;
  final http.Client _http;

  ApiClient({required this.baseUrl, http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  Future<dynamic> getJson(String path, {String? bearer}) =>
      _send(() => _http.get(_uri(path), headers: _headers(bearer)));

  Future<dynamic> postJson(String path, Map<String, dynamic> body, {String? bearer}) =>
      _send(() => _http.post(_uri(path), headers: _headers(bearer), body: jsonEncode(body)));

  Future<dynamic> putJson(String path, Map<String, dynamic> body, {String? bearer}) =>
      _send(() => _http.put(_uri(path), headers: _headers(bearer), body: jsonEncode(body)));

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Map<String, String> _headers(String? bearer) => {
        'Content-Type': 'application/json',
        if (bearer != null && bearer.isNotEmpty) 'Authorization': 'Bearer $bearer',
      };

  Future<dynamic> _send(Future<http.Response> Function() call) async {
    late http.Response res;
    try {
      res = await call().timeout(const Duration(seconds: 12));
    } on TimeoutException {
      throw const ApiException('Request timed out. Check your connection.');
    } catch (e) {
      throw ApiException('Could not reach the API: $e');
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      String message = 'Request failed';
      try {
        final body = jsonDecode(res.body);
        if (body is Map && body['error'] is String) message = body['error'] as String;
      } catch (_) {}
      throw ApiException(message, res.statusCode);
    }
    return jsonDecode(res.body);
  }

  void close() => _http.close();
}
