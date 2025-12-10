/// A multi-route asset handler for Shelf that serves Flutter bundled assets.
///
/// This package enables serving static files from Flutter's bundled assets
/// through a Shelf HTTP server, ideal for WebView integration in mobile apps.
///
/// ## Usage
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
library;

export 'src/asset_handler.dart';
export 'src/asset_route.dart';
