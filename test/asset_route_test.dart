import 'package:flutter_test/flutter_test.dart';
import 'package:shelf_asset_router/shelf_asset_router.dart';

void main() {
  group('AssetRoute', () {
    test('creates route with required basePath', () {
      const route = AssetRoute(basePath: 'docs');

      expect(route.basePath, equals('docs'));
      expect(route.defaultDocument, isNull);
      expect(route.listDirectories, isFalse);
    });

    test('creates route with custom defaultDocument', () {
      const route = AssetRoute(
        basePath: 'static',
        defaultDocument: 'home.html',
      );

      expect(route.basePath, equals('static'));
      expect(route.defaultDocument, equals('home.html'));
      expect(route.listDirectories, isFalse);
    });

    test('creates route with listDirectories enabled', () {
      const route = AssetRoute(basePath: 'files', listDirectories: true);

      expect(route.basePath, equals('files'));
      expect(route.defaultDocument, isNull);
      expect(route.listDirectories, isTrue);
    });

    test('creates route with all parameters', () {
      const route = AssetRoute(
        basePath: 'content',
        defaultDocument: 'index.htm',
        listDirectories: true,
      );

      expect(route.basePath, equals('content'));
      expect(route.defaultDocument, equals('index.htm'));
      expect(route.listDirectories, isTrue);
    });

    test('is const constructible', () {
      const route1 = AssetRoute(basePath: 'docs');
      const route2 = AssetRoute(basePath: 'docs');

      expect(identical(route1, route2), isTrue);
    });
  });
}
