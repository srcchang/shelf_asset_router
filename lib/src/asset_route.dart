/// Asset route configuration
///
/// Defines rules for serving a single asset directory
///
/// Example:
/// ```dart
/// AssetRoute(
///   basePath: 'docs',
///   defaultDocument: 'index.html',
/// )
/// ```
/// Generates URL: `http://localhost:8080/docs/index.html`
class AssetRoute {
  const AssetRoute({
    required this.basePath,
    this.defaultDocument,
    this.listDirectories = false,
  });

  /// Asset directory path (e.g. 'docs', 'static')
  final String basePath;

  /// Default document (defaults to 'index.html')
  final String? defaultDocument;

  /// Whether to allow directory listing (defaults to false)
  final bool listDirectories;
}
