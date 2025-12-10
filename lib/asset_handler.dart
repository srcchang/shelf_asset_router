import 'dart:math';

import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_asset_router/asset_route.dart';

/// Asset Handler utility class
///
/// Provides functionality to load files from Flutter assets and create Shelf Handlers
class AssetHandler {
  const AssetHandler._();

  /// Creates an Asset Handler with multi-route support
  ///
  /// Loads files from Flutter assets and responds to HTTP requests
  /// Similar to shelf_static, but uses rootBundle instead of file system
  static Handler create(List<AssetRoute> configs) {
    return (Request request) async {
      try {
        final assetPath = _resolvePath(request.url.path, configs);
        if (assetPath == null) {
          return Response.notFound('Route not found: ${request.url.path}');
        }

        final data = await _loadAsset(assetPath);
        if (data == null) {
          return Response.notFound('Asset not found: ${request.url.path}');
        }

        final mimeType = _detectMimeType(assetPath, data);

        return Response.ok(
          data.buffer.asUint8List(),
          headers: {
            'Cache-Control': 'public, max-age=3600',
            'Content-Type': mimeType,
          },
        );
      } catch (e) {
        return Response.internalServerError(body: 'Error serving asset: ${request.url.path}');
      }
    };
  }

  /// Resolves HTTP request path to asset path
  ///
  /// Matching rules:
  /// - `/assets/page.html` → `assets/page.html`
  /// - `/assets/` → `assets/index.html` (uses defaultDocument)
  ///
  /// Returns null if no matching route is found
  static String? _resolvePath(String requestPath, List<AssetRoute> configs) {
    var path = requestPath.startsWith('/') ? requestPath.substring(1) : requestPath;

    for (final config in configs) {
      final basePath = config.basePath;

      if (path.startsWith('$basePath/') || path == basePath) {
        var relativePath = path == basePath ? '' : path.substring(basePath.length + 1);

        if (relativePath.isEmpty || relativePath.endsWith('/')) {
          relativePath += config.defaultDocument ?? 'index.html';
        }

        return '$basePath/$relativePath';
      }
    }

    return null;
  }

  /// Loads Flutter asset (returns null on failure)
  static Future<ByteData?> _loadAsset(String path) async {
    try {
      return await rootBundle.load(path);
    } catch (e) {
      return null;
    }
  }

  /// Detects file MIME type (based on extension and file header)
  static String _detectMimeType(String path, ByteData data) {
    final headerBytes = data.buffer.asUint8List(0, min(data.lengthInBytes, 12));
    final mimeType = lookupMimeType(path, headerBytes: headerBytes);
    return mimeType ?? 'application/octet-stream';
  }
}
