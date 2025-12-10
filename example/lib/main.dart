import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_asset_router/shelf_asset_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shelf Asset Router Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const WebViewExample(),
    );
  }
}

class WebViewExample extends StatefulWidget {
  const WebViewExample({super.key});

  @override
  State<WebViewExample> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  HttpServer? _server;
  int? _serverPort;
  WebViewController? _webViewController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startServer();
  }

  Future<void> _startServer() async {
    try {
      // Create asset handler with route configuration
      final assetHandler = AssetHandler.create([
        const AssetRoute(
          basePath: 'assets/webapp',
          defaultDocument: 'index.html',
        ),
      ]);

      // Create request handler pipeline with logging middleware
      final handler =
          const Pipeline().addMiddleware(logRequests()).addHandler(assetHandler);

      // Start HTTP server on localhost with random available port
      _server = await shelf_io.serve(
        handler,
        InternetAddress.loopbackIPv4,
        0, // Use 0 to let system assign available port
      );

      setState(() {
        _serverPort = _server!.port;
        _isLoading = false;
      });

      debugPrint('Server started on http://localhost:$_serverPort');

      // Initialize WebView controller
      _initializeWebView();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to start server: $e';
        _isLoading = false;
      });
    }
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (error) {
            debugPrint('Web resource error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse('http://localhost:$_serverPort/assets/webapp/'));
  }

  @override
  void dispose() {
    _server?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Shelf Asset Router Example'),
        actions: [
          if (_serverPort != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _webViewController?.reload();
              },
              tooltip: 'Reload',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Starting server...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    if (_webViewController == null) {
      return const Center(child: Text('Initializing WebView...'));
    }

    return Column(
      children: [
        Container(
          color: Colors.blue.shade50,
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Server running on http://localhost:$_serverPort',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: WebViewWidget(controller: _webViewController!),
        ),
      ],
    );
  }
}
