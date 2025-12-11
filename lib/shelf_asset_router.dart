/// A multi-route asset handler for Shelf that serves Flutter bundled assets.
///
/// This package enables serving static files from Flutter's bundled assets
/// through a Shelf HTTP server, ideal for WebView integration in mobile apps.
///
/// ## Features
///
/// - **Multi-route support**: Serve multiple asset directories
/// - **Configurable caching**: Control Cache-Control headers per route
/// - **ETag validation**: Automatic 304 Not Modified responses
/// - **MIME type detection**: Automatic content-type headers
///
/// ## Usage
///
/// ### Basic Usage
///
/// ```dart
/// import 'package:shelf/shelf_io.dart' as shelf_io;
/// import 'package:shelf_asset_router/shelf_asset_router.dart';
///
/// // Configure routes
/// final assetHandler = AssetHandler.create([
///   AssetRoute(
///     basePath: 'assets/webapp',
///     defaultDocument: 'index.html',
///   ),
/// ]);
///
/// final handler = const Pipeline()
///     .addMiddleware(logRequests())
///     .addHandler(assetHandler);
///
/// // Start server
/// final server = await shelf_io.serve(handler, 'localhost', 8080);
/// ```
///
/// ### Advanced Caching Configuration
///
/// ```dart
/// final assetHandler = AssetHandler.create([
///   // Long-term caching for static assets
///   AssetRoute(
///     basePath: 'assets/static',
///     cacheControl: 'public, max-age=31536000, immutable',
///     enableETag: false, // Not needed with immutable
///   ),
///   // Short caching with ETag validation for HTML
///   AssetRoute(
///     basePath: 'assets/webapp',
///     cacheControl: 'public, max-age=300',
///     enableETag: true,
///   ),
///   // No caching for development
///   AssetRoute(
///     basePath: 'assets/dev',
///     cacheControl: 'no-cache',
///     enableETag: false,
///   ),
/// ]);
/// ```
library;

export 'src/asset_handler.dart';
export 'src/asset_route.dart';
