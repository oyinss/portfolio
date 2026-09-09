/// Phase 6: authenticated admin API (CRUD, uploads, settings).
library;

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'api_client.dart';
import 'auth_service.dart';

class AdminRepository {
  final AuthService auth;
  final String baseUrl;
  final http.Client _http;

  AdminRepository({required this.auth, String? baseUrl, http.Client? httpClient})
      : baseUrl = baseUrl ?? apiBaseUrl,
        _http = httpClient ?? http.Client();

  Future<dynamic> _send(Future<http.Response> Function(Map<String, String> headers) call) async {
    final token = auth.token;
    if (token == null || token.isEmpty) throw const ApiException('Not signed in.');
    late http.Response res;
    try {
      res = await call({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const ApiException('Request timed out. Check your connection.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Could not reach the API: $e');
    }
    if (res.statusCode == 401) {
      await auth.dropInvalidToken();
      throw const ApiException('Session expired. Sign in again.', 401);
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

  Future<dynamic> get(String path) =>
      _send((h) => _http.get(Uri.parse('$baseUrl$path'), headers: h));

  Future<dynamic> post(String path, Map<String, dynamic> body) => _send(
        (h) => _http.post(Uri.parse('$baseUrl$path'), headers: h, body: jsonEncode(body)),
      );

  Future<dynamic> put(String path, Map<String, dynamic> body) => _send(
        (h) => _http.put(Uri.parse('$baseUrl$path'), headers: h, body: jsonEncode(body)),
      );

  Future<void> delete(String path) async {
    final token = auth.token;
    if (token == null || token.isEmpty) throw const ApiException('Not signed in.');
    final res = await _http
        .delete(Uri.parse('$baseUrl$path'), headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));
    if (res.statusCode == 401) {
      await auth.dropInvalidToken();
      throw const ApiException('Session expired. Sign in again.', 401);
    }
    if (res.statusCode != 200) throw ApiException('Delete failed', res.statusCode);
  }

  // ----- typed helpers -----
  Future<List<Map<String, dynamic>>> allProjects() async =>
      ((await get('/api/admin/projects')) as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

  Future<Map<String, dynamic>> saveProject(Map<String, dynamic> data, {String? id}) async =>
      Map<String, dynamic>.from(id == null
          ? await post('/api/projects', data) as Map
          : await put('/api/projects/$id', data) as Map);

  Future<Map<String, dynamic>> saveSkill(Map<String, dynamic> data, {String? id}) async =>
      Map<String, dynamic>.from(id == null
          ? await post('/api/skills', data) as Map
          : await put('/api/skills/$id', data) as Map);

  Future<Map<String, dynamic>> saveExperience(Map<String, dynamic> data, {String? id}) async =>
      Map<String, dynamic>.from(id == null
          ? await post('/api/experience', data) as Map
          : await put('/api/experience/$id', data) as Map);

  Future<Map<String, dynamic>> saveEducation(Map<String, dynamic> data, {String? id}) async =>
      Map<String, dynamic>.from(id == null
          ? await post('/api/education', data) as Map
          : await put('/api/education/$id', data) as Map);

  Future<Map<String, dynamic>> saveSocial(Map<String, dynamic> data, {String? id}) async =>
      Map<String, dynamic>.from(id == null
          ? await post('/api/socials', data) as Map
          : await put('/api/socials/$id', data) as Map);

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async =>
      Map<String, dynamic>.from(await put('/api/profile', data) as Map);

  Future<Map<String, String>> getSettings() async =>
      Map<String, String>.from((await get('/api/settings') as Map).map((k, v) => MapEntry('$k', '$v')));

  Future<void> updateSettings(Map<String, String> settings) async {
    await put('/api/settings', settings);
  }

  /// Uploads an image to R2. Returns the public URL (or storage key when no
  /// public domain is configured).
  Future<Map<String, dynamic>> uploadImage({
    required List<int> bytes,
    required String filename,
    required String mimeType,
  }) async {
    final token = auth.token;
    if (token == null || token.isEmpty) throw const ApiException('Not signed in.');
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/uploads'))
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(http.MultipartFile.fromBytes('file', bytes,
          filename: filename, contentType: MediaType.parse(mimeType)));
    final streamed = await req.send().timeout(const Duration(seconds: 30));
    final body = await streamed.stream.bytesToString();
    if (streamed.statusCode == 401) {
      await auth.dropInvalidToken();
      throw const ApiException('Session expired. Sign in again.', 401);
    }
    if (streamed.statusCode != 201) {
      String message = 'Upload failed';
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map && decoded['error'] is String) message = decoded['error'] as String;
      } catch (_) {}
      throw ApiException(message, streamed.statusCode);
    }
    return Map<String, dynamic>.from(jsonDecode(body) as Map);
  }
}
