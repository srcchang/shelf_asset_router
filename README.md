# shelf_asset_router

A multi-route asset handler for Shelf that serves Flutter bundled assets with flexible routing configuration, perfect for WebView integration.

[![pub package](https://img.shields.io/pub/v/shelf_asset_router.svg)](https://pub.dev/packages/shelf_asset_router)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Overview

`shelf_asset_router` enables you to serve static files from Flutter's bundled assets through a Shelf HTTP server. Unlike traditional file-system-based servers, this package uses `rootBundle.load()` to access assets, making it ideal for serving web content within Flutter applications via WebView.

### Key Features

- ✅ **Multi-route support** - Configure multiple asset directories with independent routing rules
- ✅ **Automatic MIME type detection** - Intelligently detects content types based on file extensions and headers
- ✅ **Flexible path resolution** - Supports custom default documents (e.g., `index.html`)
- ✅ **Built-in caching** - Includes cache headers for optimal performance
- ✅ **Zero file system dependencies** - Works entirely with Flutter's asset bundle system
- ✅ **Shelf middleware compatible** - Integrate seamlessly with existing Shelf pipelines

## Use Cases

- **WebView integration** - Serve bundled web applications in mobile apps
- **Hybrid apps** - Bridge native Flutter UI with web-based content
- **Offline-first PWAs** - Deliver web content without network dependencies
- **Documentation viewers** - Display HTML documentation within your app
- **Chart libraries** - Integrate web-based charting solutions (TradingView, Chart.js, etc.)

<!-- TODO: Add demo video/GIF here showing the example app in action -->
<!-- Suggested content: Screen recording of the example app running on Android/iOS -->
<!-- showing the web content loading in WebView with navigation between pages -->

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  shelf_asset_router: ^0.0.1
  shelf: ^1.4.2
```

Then run:

```bash
flutter pub get
```

## Quick Start

### 1. Declare Your Assets

In your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/webapp/index.html
    - assets/webapp/styles.css
    - assets/webapp/script.js
```

### 2. Create the Server

```dart
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_asset_router/asset_handler.dart';
import 'package:shelf_asset_router/asset_route.dart';

// Configure routes
final assetHandler = AssetHandler.create([
  AssetRoute(
    basePath: 'assets/webapp',
    defaultDocument: 'index.html',
  ),
]);

final handler = const Pipeline().addMiddleware(logRequests()).addHandler(assetHandler);

// Start server
final server = await shelf_io.serve(
  handler,
  'localhost',
  8080,
);

print('Server running on http://localhost:${server.port}');
```

### 3. Load in WebView

```dart
import 'package:webview_flutter/webview_flutter.dart';

final controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..loadRequest(Uri.parse('http://localhost:8080/assets/webapp/'));
```

## Usage

### Basic Configuration

Serve a single asset directory:

```dart
final handler = AssetHandler.create([
  AssetRoute(
    basePath: 'assets/webapp',
    defaultDocument: 'index.html',
  ),
]);
```

**URL Mapping:**
- `http://localhost:8080/assets/webapp/` → `assets/webapp/index.html`
- `http://localhost:8080/assets/webapp/about.html` → `assets/webapp/about.html`
- `http://localhost:8080/assets/webapp/css/styles.css` → `assets/webapp/css/styles.css`

### Multiple Routes

Serve multiple asset directories with different configurations:

```dart
final handler = AssetHandler.create([
  AssetRoute(
    basePath: 'assets/docs',
    defaultDocument: 'index.html',
  ),
  AssetRoute(
    basePath: 'assets/charts',
    defaultDocument: 'chart.html',
  ),
  AssetRoute(
    basePath: 'assets/static',
  ),
]);
```

**URL Mapping:**
- `http://localhost:8080/assets/docs/` → `assets/docs/index.html`
- `http://localhost:8080/assets/charts/` → `assets/charts/chart.html`
- `http://localhost:8080/assets/static/image.png` → `assets/static/image.png`

### With Shelf Middleware

Integrate with Shelf's middleware pipeline:

```dart
import 'package:shelf/shelf.dart';

final assetHandler = AssetHandler.create([
  AssetRoute(basePath: 'assets/webapp'),
]);

final handler = Pipeline()
  .addMiddleware(logRequests())
  .addHandler(assetHandler);

final server = await shelf_io.serve(handler, 'localhost', 8080);
```

### Custom Default Document

Specify a different default file:

```dart
final handler = AssetHandler.create([
  AssetRoute(
    basePath: 'assets/app',
    defaultDocument: 'home.html', // Serves home.html instead of index.html
  ),
]);
```

### Dynamic Port Assignment

Let the system assign an available port:

```dart
final server = await shelf_io.serve(
  handler,
  InternetAddress.loopbackIPv4,
  0, // System assigns available port
);

print('Server started on port ${server.port}');
```

## Complete Example

See the [example](example/) directory for a full Flutter application demonstrating:

- Server lifecycle management
- WebView integration
- Interactive web content with JavaScript
- Multiple page navigation
- Error handling
- Request logging

Run the example:

```bash
cd example
flutter pub get
flutter run
```

<!-- TODO: Add screenshot here showing the example app UI -->
<!-- Suggested content: Screenshot of the example app showing the WebView -->
<!-- with the gradient background and interactive elements -->

## API Reference

### `AssetRoute`

Configuration class for defining asset routing rules.

```dart
class AssetRoute {
  const AssetRoute({
    required String basePath,
    String? defaultDocument,
    bool listDirectories = false,
  });
}
```

**Parameters:**

- `basePath` (required) - Asset directory path (e.g., `'assets/webapp'`)
- `defaultDocument` (optional) - Default file name, defaults to `'index.html'`
- `listDirectories` (optional) - Directory listing support (currently not implemented)

### `AssetHandler`

Static utility class for creating Shelf handlers.

```dart
class AssetHandler {
  static Handler create(List<AssetRoute> configs);
}
```

**Returns:** A Shelf `Handler` function that processes HTTP requests.

**Response Codes:**
- `200 OK` - Asset found and served successfully
- `404 Not Found` - No matching route or asset not found
- `500 Internal Server Error` - Server error during asset loading

**Response Headers:**
- `Content-Type` - Automatically detected MIME type
- `Cache-Control` - Set to `public, max-age=3600`

## How It Works

1. **Request Matching** - Incoming requests are matched against configured routes
2. **Path Resolution** - URL paths are resolved to asset bundle paths
3. **Asset Loading** - Files are loaded using `rootBundle.load()`
4. **MIME Detection** - Content type is determined from file extension and headers
5. **Response Building** - HTTP response is constructed with appropriate headers

### Path Resolution Logic

```
HTTP Request: /assets/webapp/page.html
            ↓
Route Match: basePath = 'assets/webapp'
            ↓
Asset Path: assets/webapp/page.html
            ↓
rootBundle.load('assets/webapp/page.html')
```

For directory requests:
```
HTTP Request: /assets/webapp/
            ↓
Route Match: basePath = 'assets/webapp', defaultDocument = 'index.html'
            ↓
Asset Path: assets/webapp/index.html
```

## Platform Support

| Platform | Supported | Notes |
|----------|-----------|-------|
| Android  | ✅ | Full support |
| iOS      | ✅ | Full support |

**Note:** This package is designed primarily for mobile platforms (Android/iOS) where serving bundled assets to a WebView is a common pattern.

## Troubleshooting

### Assets not loading (404 errors)

**Problem:** Server returns 404 for existing assets.

**Solution:**
1. Verify assets are declared in `pubspec.yaml`
2. Ensure `basePath` matches your asset directory structure
3. Run `flutter clean && flutter pub get` to rebuild the asset bundle
4. Check that file paths don't include the `assets/` prefix in routes

```dart
// ❌ Wrong
AssetRoute(basePath: 'assets/assets/webapp')

// ✅ Correct
AssetRoute(basePath: 'assets/webapp')
```

### MIME type issues

**Problem:** Assets served with incorrect `Content-Type`.

**Solution:** The package automatically detects MIME types. If detection fails:
- Ensure files have proper extensions (`.html`, `.css`, `.js`)
- File headers are checked for binary files (images, fonts)

### Server port conflicts

**Problem:** Port already in use error.

**Solution:** Use dynamic port assignment:

```dart
final server = await shelf_io.serve(handler, 'localhost', 0);
```

### WebView not loading content

**Problem:** WebView shows blank page.

**Solution:**
1. Enable JavaScript: `controller.setJavaScriptMode(JavaScriptMode.unrestricted)`
2. Check server is running before loading WebView
3. Verify correct URL format: `http://localhost:PORT/assets/PATH/`
4. Check console for error messages: `controller.setNavigationDelegate(...)`

## Performance Considerations

- **Asset Bundle Size** - Keep web assets optimized; large bundles increase app size
- **Caching** - Built-in `Cache-Control` headers reduce repeated asset loads
- **Memory Usage** - Assets are loaded into memory; monitor usage for large files
- **Concurrent Requests** - Shelf handles concurrent requests efficiently

## Security

- **Localhost Only** - Server binds to `localhost`/`127.0.0.1` by default
- **No External Access** - Not accessible from outside the device
- **Asset Sandboxing** - Only serves assets from configured routes

## Comparison with Alternatives

| Feature | shelf_asset_router | shelf_static |
|---------|-------------------|--------------|
| Asset Bundle Support | ✅ | ❌ |
| File System Access | ❌ | ✅ |
| Multi-route Support | ✅ | ❌ |
| MIME Detection | ✅ | ✅ |
| Flutter Integration | ✅ | ⚠️ |
| Mobile Optimized | ✅ | ❌ |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

```bash
# Clone repository
git clone https://github.com/srcchang/shelf_asset_router.git

# Install dependencies
flutter pub get

# Run tests
flutter test

# Run example
cd example && flutter run
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes.

## Acknowledgments

- Built on top of the excellent [shelf](https://pub.dev/packages/shelf) package
- Inspired by the need for better WebView integration in Flutter apps
- Thanks to the Flutter and Dart communities

## Related Packages

- [shelf](https://pub.dev/packages/shelf) - HTTP server framework
- [shelf_static](https://pub.dev/packages/shelf_static) - File system-based static file serving
- [webview_flutter](https://pub.dev/packages/webview_flutter) - WebView widget for Flutter
- [mime](https://pub.dev/packages/mime) - MIME type detection
