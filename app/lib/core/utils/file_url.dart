/// Resolves file references to loadable URLs.
/// - Absolute URLs (http/https) and data: URIs pass through.
/// - `/api/files/...` proxy paths resolve against the API base URL.
/// - Bare R2 keys (`uploads/...`) resolve to `/api/files/<key>` on the API.
/// - Null/empty → null (caller shows fallback avatar).
library;

import '../api/api_client.dart';

String? resolveFileUrl(String? ref, {String? baseUrl}) {
  if (ref == null) return null;
  final v = ref.trim();
  if (v.isEmpty || v.toLowerCase() == 'null') return null;
  if (v.startsWith('http://') || v.startsWith('https://') || v.startsWith('data:')) {
    return v;
  }
  final base = (baseUrl ?? apiBaseUrl).replaceAll(RegExp(r'/$'), '');
  if (base.isEmpty) return null;
  if (v.startsWith('/')) return '$base$v';
  return '$base/api/files/$v';
}

/// Initials for avatar fallback (e.g. "Onyinbrakeme Kelvin Ogbe" → "OK").
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    final p = parts.first;
    return p.substring(0, 1).toUpperCase();
  }
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}
