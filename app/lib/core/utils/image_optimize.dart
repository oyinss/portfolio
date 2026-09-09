/// Client-side image optimization (§23): resize + compress before upload
/// to keep the site fast and R2 usage small.
library;

import 'dart:typed_data';

import 'package:image/image.dart' as img;

class OptimizedImage {
  final List<int> bytes;
  final String filename;
  final String mimeType;
  const OptimizedImage({required this.bytes, required this.filename, required this.mimeType});
}

OptimizedImage optimizeImage(List<int> raw, String originalName) {
  final decoded = img.decodeImage(Uint8List.fromList(raw));
  if (decoded == null) {
    throw ArgumentError('Could not decode image (jpeg/png/webp/gif only).');
  }
  const maxDim = 1600;
  final resized = (decoded.width > maxDim || decoded.height > maxDim)
      ? img.copyResize(
          decoded,
          width: decoded.width >= decoded.height ? maxDim : null,
          height: decoded.width >= decoded.height ? null : maxDim,
        )
      : decoded;
  final bytes = img.encodeJpg(resized, quality: 80);
  final base = originalName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
  return OptimizedImage(bytes: bytes, filename: '$base.jpg', mimeType: 'image/jpeg');
}
