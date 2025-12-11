import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:mime/mime.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_asset_router/shelf_asset_router.dart';

/// Asset Handler utility class
///
/// Provides functionality to load files from Flutter assets and create Shelf Handlers
class AssetHandler {
  const AssetHandler._();

  /// ETag cache for bundled assets (static, shared across all handlers)
  ///
  /// Since bundled assets are immutable at runtime, ETags are cached permanently
  /// to avoid recalculation on subsequent requests.
  static final _etagCache = <String, String>{};

  /// Creates an Asset Handler with multi-route support
  ///
  /// Loads files from Flutter assets and responds to HTTP requests
  /// Similar to shelf_static, but uses rootBundle instead of file system
  static Handler create(List<AssetRoute> configs) {
    return (Request request) async {
      try {
        final matchResult = _resolvePath(request.url.path, configs);
        if (matchResult == null) {
          return Response.notFound('Route not found: ${request.url.path}');
        }

        final assetPath = matchResult.assetPath;
        final config = matchResult.config;

        final data = await _loadAsset(assetPath);
        if (data == null) {
          return Response.notFound('Asset not found: ${request.url.path}');
        }

        final mimeType = _detectMimeType(assetPath, data);

        // Handle ETag validation
        if (config.enableETag) {
          final etag = _getOrCalculateETag(assetPath, data);
          final clientETag = request.headers['if-none-match'];

          if (clientETag == etag) {
            return Response.notModified(headers: {
              'ETag': etag,
              'Cache-Control': config.cacheControl,
            });
          }

          return Response.ok(
            data.buffer.asUint8List(),
            headers: {
              'ETag': etag,
              'Cache-Control': config.cacheControl,
              'Content-Type': mimeType,
            },
          );
        }

        // Fallback without ETag
        return Response.ok(
          data.buffer.asUint8List(),
          headers: {
            'Cache-Control': config.cacheControl,
            'Content-Type': mimeType,
          },
        );
      } catch (e) {
        return Response.internalServerError(
          body: 'Error serving asset: ${request.url.path}',
        );
      }
    };
  }

  /// Resolves HTTP request path to asset path and matching config
  ///
  /// Matching rules:
  /// - `/assets/page.html` → `assets/page.html`
  /// - `/assets/` → `assets/index.html` (uses defaultDocument)
  ///
  /// Returns null if no matching route is found
  static _RouteMatch? _resolvePath(
      String requestPath, List<AssetRoute> configs) {
    var path =
        requestPath.startsWith('/') ? requestPath.substring(1) : requestPath;

    for (final config in configs) {
      final basePath = config.basePath;

      if (path.startsWith('$basePath/') || path == basePath) {
        var relativePath =
            path == basePath ? '' : path.substring(basePath.length + 1);

        if (relativePath.isEmpty || relativePath.endsWith('/')) {
          relativePath += config.defaultDocument ?? 'index.html';
        }

        return _RouteMatch(
          assetPath: '$basePath/$relativePath',
          config: config,
        );
      }
    }

    return null;
  }

  /// Gets cached ETag or calculates new one
  ///
  /// Uses MD5 hash of asset content. Results are cached permanently
  /// since bundled assets are immutable at runtime.
  static String _getOrCalculateETag(String path, ByteData data) {
    return _etagCache.putIfAbsent(path, () {
      final bytes = data.buffer.asUint8List();
      final hash = md5.convert(bytes);
      return '"${hash.toString()}"';
    });
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

/// Internal class to hold route matching result
class _RouteMatch {
  const _RouteMatch({
    required this.assetPath,
    required this.config,
  });

  final String assetPath;
  final AssetRoute config;
}
