/// Phase 5 auth state (§50): token persisted locally, notifies route guards.
library;

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';

class AuthService extends ChangeNotifier {
  static const _tokenKey = 'pf_auth_token';
  static const _emailKey = 'pf_auth_email';

  final SharedPreferences _prefs;
  final ApiClient? _api;

  String? _token;
  String? _email;

  AuthService._(this._prefs, this._api) {
    _token = _prefs.getString(_tokenKey);
    _email = _prefs.getString(_emailKey);
  }

  static Future<AuthService> load({String? baseUrl, ApiClient? api}) async {
    final prefs = await SharedPreferences.getInstance();
    final url = baseUrl ?? apiBaseUrl;
    return AuthService._(prefs, api ?? (url.isEmpty ? null : ApiClient(baseUrl: url)));
  }

  /// Test/seam constructor.
  @visibleForTesting
  AuthService.test(this._prefs, this._api, [this._token, this._email]);

  bool get isAuthed => _token != null && _token!.isNotEmpty;
  String? get token => _token;
  String? get email => _email;

  Future<void> login(String email, String password) async {
    final api = _api;
    if (api == null) throw const ApiException('API is not configured (mock mode).');
    final res = Map<String, dynamic>.from(
      await api.postJson('/api/auth/login', {'email': email.trim(), 'password': password}) as Map,
    );
    _token = res['token'] as String;
    _email = (res['email'] as String?) ?? email.trim();
    await _prefs.setString(_tokenKey, _token!);
    await _prefs.setString(_emailKey, _email!);
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _email = null;
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_emailKey);
    notifyListeners();
  }

  /// Drops a locally stored token the server rejects (expired/revoked).
  Future<void> dropInvalidToken() async {
    if (_token == null) return;
    await logout();
  }
}

class AuthScope extends InheritedWidget {
  final AuthService auth;
  const AuthScope({super.key, required this.auth, required super.child});

  static AuthService of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()!.auth;

  @override
  bool updateShouldNotify(AuthScope oldWidget) => auth != oldWidget.auth;
}
