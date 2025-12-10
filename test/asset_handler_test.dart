import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_asset_router/shelf_asset_router.dart';

void main() {
  group('Error Handling', () {
    test('returns 404 for non-matching route', () async {
      final handler = AssetHandler.create([const AssetRoute(basePath: 'docs')]);

      final request = Request(
        'GET',
        Uri.parse('http://localhost/other/file.html'),
      );
      final response = await handler(request);

      expect(response.statusCode, equals(404));
      final body = await response.readAsString();
      expect(body, contains('Route not found'));
    });

    test('returns 404 for non-existent asset in valid route', () async {
      final handler = AssetHandler.create([const AssetRoute(basePath: 'docs')]);

      final request = Request(
        'GET',
        Uri.parse('http://localhost/docs/missing.html'),
      );
      final response = await handler(request);

      expect(response.statusCode, equals(404));
      final body = await response.readAsString();
      expect(body, contains('Asset not found'));
    });

    test('handles empty route list gracefully', () async {
      final handler = AssetHandler.create([]);

      final request = Request(
        'GET',
        Uri.parse('http://localhost/docs/page.html'),
      );
      final response = await handler(request);

      expect(response.statusCode, equals(404));
      final body = await response.readAsString();
      expect(body, contains('Route not found'));
    });
  });

  group('Route Configuration', () {
    test('handles multiple routes with different base paths', () async {
      final handler = AssetHandler.create([
        const AssetRoute(basePath: 'docs'),
        const AssetRoute(basePath: 'static'),
        const AssetRoute(basePath: 'assets'),
      ]);

      // All should return 404 (asset not found) not "route not found"
      final docsRequest = Request(
        'GET',
        Uri.parse('http://localhost/docs/test.html'),
      );
      final docsResponse = await handler(docsRequest);
      expect(docsResponse.statusCode, equals(404));
      expect(await docsResponse.readAsString(), contains('Asset not found'));

      final staticRequest = Request(
        'GET',
        Uri.parse('http://localhost/static/test.js'),
      );
      final staticResponse = await handler(staticRequest);
      expect(staticResponse.statusCode, equals(404));
      expect(await staticResponse.readAsString(), contains('Asset not found'));

      final assetsRequest = Request(
        'GET',
        Uri.parse('http://localhost/assets/test.png'),
      );
      final assetsResponse = await handler(assetsRequest);
      expect(assetsResponse.statusCode, equals(404));
      expect(await assetsResponse.readAsString(), contains('Asset not found'));
    });

    test('first matching route takes precedence', () async {
      final handler = AssetHandler.create([
        const AssetRoute(basePath: 'shared'),
        const AssetRoute(basePath: 'shared', defaultDocument: 'home.html'),
      ]);

      final request = Request('GET', Uri.parse('http://localhost/shared/'));
      final response = await handler(request);

      // Should use first route's defaultDocument (index.html by default)
      expect(response.statusCode, equals(404));
      final body = await response.readAsString();
      expect(body, contains('Asset not found'));
    });
  });

  group('Path Patterns', () {
    test('handles root path with trailing slash', () async {
      final handler = AssetHandler.create([const AssetRoute(basePath: 'docs')]);

      final request = Request('GET', Uri.parse('http://localhost/docs/'));
      final response = await handler(request);

      // Should resolve to docs/index.html (which doesn't exist, so 404)
      expect(response.statusCode, equals(404));
      final body = await response.readAsString();
      expect(body, contains('Asset not found'));
    });

    test('handles root path without trailing slash', () async {
      final handler = AssetHandler.create([const AssetRoute(basePath: 'docs')]);

      final request = Request('GET', Uri.parse('http://localhost/docs'));
      final response = await handler(request);

      // Should resolve to docs/index.html (which doesn't exist, so 404)
      expect(response.statusCode, equals(404));
      final body = await response.readAsString();
      expect(body, contains('Asset not found'));
    });

    test('handles nested paths', () async {
      final handler = AssetHandler.create([const AssetRoute(basePath: 'docs')]);

      final request = Request(
        'GET',
        Uri.parse('http://localhost/docs/guides/intro.html'),
      );
      final response = await handler(request);

      // Should resolve to docs/guides/intro.html (which doesn't exist, so 404)
      expect(response.statusCode, equals(404));
      final body = await response.readAsString();
      expect(body, contains('Asset not found'));
    });

    test('does not match partial base paths', () async {
      final handler = AssetHandler.create([const AssetRoute(basePath: 'docs')]);

      final request = Request(
        'GET',
        Uri.parse('http://localhost/documentation/file.html'),
      );
      final response = await handler(request);

      // Should not match "docs" base path
      expect(response.statusCode, equals(404));
      final body = await response.readAsString();
      expect(body, contains('Route not found'));
    });
  });

  group('Custom Default Document', () {
    test('uses custom defaultDocument for directory requests', () async {
      final handler = AssetHandler.create([
        const AssetRoute(basePath: 'docs', defaultDocument: 'home.html'),
      ]);

      final request = Request('GET', Uri.parse('http://localhost/docs/'));
      final response = await handler(request);

      // Should try to load docs/home.html (which doesn't exist, so 404)
      expect(response.statusCode, equals(404));
      final body = await response.readAsString();
      expect(body, contains('Asset not found'));
    });
  });
}
