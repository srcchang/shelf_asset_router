/// Asset route configuration
///
/// Defines rules for serving a single asset directory
///
/// Example:
/// ```dart
/// AssetRoute(
///   basePath: 'docs',
///   defaultDocument: 'index.html',
///   cacheControl: 'public, max-age=3600',
///   enableETag: true,
/// )
/// ```
/// Generates URL: `http://localhost:8080/docs/index.html`
class AssetRoute {
  const AssetRoute({
    required this.basePath,
    this.defaultDocument,
    this.cacheControl = 'public, max-age=3600',
    this.enableETag = true,
  });

  /// Asset directory path (e.g. 'docs', 'static')
  final String basePath;

  /// Default document (defaults to 'index.html')
  final String? defaultDocument;

  /// Cache-Control header value
  ///
  /// Common values:
  /// - `'no-cache'` - Revalidate on every request
  /// - `'public, max-age=3600'` - Cache for 1 hour (default)
  /// - `'public, max-age=31536000, immutable'` - Cache for 1 year
  final String cacheControl;

  /// Enable ETag validation for conditional requests
  ///
  /// When enabled, generates MD5-based ETags for assets and supports
  /// `If-None-Match` headers to return `304 Not Modified` responses.
  ///
  /// Defaults to `true`.
  final bool enableETag;
}
