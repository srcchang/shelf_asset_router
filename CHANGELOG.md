## 1.2.0

*   **BREAKING CHANGE**: Removed unused `listDirectories` parameter from `AssetRoute`
*   **NEW**: Configurable `cacheControl` parameter for customizing Cache-Control headers per route
*   **NEW**: ETag support with automatic 304 Not Modified responses (`enableETag` parameter)
*   **NEW**: MD5-based ETag calculation with permanent caching for optimal performance
*   Added `crypto` package dependency for ETag generation
*   Updated documentation with caching configuration examples

### Migration Guide

If you were using the `listDirectories` parameter (which had no effect):

```dart
// Before (v1.1.x)
AssetRoute(
  basePath: 'assets/webapp',
  listDirectories: true,  // This parameter had no effect
)

// After (v1.2.0)
AssetRoute(
  basePath: 'assets/webapp',
  // Simply remove the listDirectories parameter
)
```

New caching features are opt-in with sensible defaults:

```dart
// Use defaults (1 hour cache, ETag enabled)
AssetRoute(basePath: 'assets/webapp')

// Customize caching
AssetRoute(
  basePath: 'assets/static',
  cacheControl: 'public, max-age=31536000, immutable',
  enableETag: false,
)
```

## 1.1.2

*   **Improved SDK compatibility** - Lowered minimum Dart SDK requirement to `^3.0.0`
*   Enables usage in projects with Dart SDK 3.0+

## 1.1.1

*   Code formatting improvements with `dart format`

## 1.1.0

*   **Improved package structure** - All imports now use single entry point: `package:shelf_asset_router/shelf_asset_router.dart`
*   Backward compatible - No breaking changes to public API

## 1.0.0

*   Initial release of `shelf_asset_router` package.
*   Provides a multi-route asset handler for Shelf.
*   Supports serving Flutter bundled assets for WebView integration.
