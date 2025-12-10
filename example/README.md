# shelf_asset_router Example

This example demonstrates how to use `shelf_asset_router` to serve bundled web content from Flutter assets via a local HTTP server and display it in a WebView.

## Features Demonstrated

- ✅ Starting a Shelf HTTP server with asset routing
- ✅ Configuring routes with `AssetRoute`
- ✅ Serving HTML, CSS, and JavaScript files from assets
- ✅ Displaying served content in a WebView
- ✅ Automatic MIME type detection
- ✅ Path resolution with default documents

## Project Structure

```
example/
├── lib/
│   └── main.dart                 # Main app with server and WebView
├── assets/
│   └── webapp/                   # Web content bundle
│       ├── index.html            # Home page
│       ├── about.html            # About page
│       ├── styles.css            # Stylesheets
│       └── script.js             # JavaScript
└── pubspec.yaml                  # Dependencies and asset declarations
```

## How It Works

1. **Server Startup**: The app starts a Shelf HTTP server on `localhost` with a random available port
2. **Route Configuration**: Assets are served from the `assets/webapp/` directory
3. **WebView Display**: The bundled web content is loaded in a WebView using the local server URL

### Key Code

```dart
// Configure asset route
final handler = AssetHandler.create([
  const AssetRoute(
    basePath: 'assets/webapp',
    defaultDocument: 'index.html',
  ),
]);

// Start server
final server = await shelf_io.serve(
  handler,
  'localhost',
  0, // System assigns available port
);

// Load in WebView
webViewController.loadRequest(
  Uri.parse('http://localhost:${server.port}/assets/webapp/')
);
```

## Running the Example

### Prerequisites

- Flutter SDK (^3.10.3)
- Android/iOS device or emulator

### Steps

1. Navigate to the example directory:
   ```bash
   cd example
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run on your device:
   ```bash
   # Android
   flutter run

   # iOS
   flutter run -d ios
   ```

## Supported Platforms

- ✅ Android
- ✅ iOS

**Note**: This example is designed specifically for mobile platforms (Android & iOS) as it uses `webview_flutter`.

## Web Content Features

The example web bundle includes:

- **Responsive Design**: Mobile-friendly layout with gradient backgrounds
- **Multiple Pages**: Navigation between index.html and about.html
- **Interactive Elements**: Button click counter with JavaScript
- **CSS Animations**: Smooth transitions and hover effects
- **Asset Loading**: Demonstrates loading of HTML, CSS, and JS files

## Troubleshooting

### WebView not loading content

- Ensure the server started successfully (check debug output)
- Verify assets are properly declared in `pubspec.yaml`
- Check that the WebView has internet permission (Android)

### Assets not found (404 errors)

- Verify asset paths match the `basePath` in `AssetRoute`
- Ensure all assets are listed in `pubspec.yaml`
- Run `flutter clean && flutter pub get` to rebuild asset bundle

### Server port conflicts

The example uses port `0` to automatically assign an available port, avoiding conflicts.

## Learn More

- [shelf_asset_router Documentation](../README.md)
- [Shelf Package](https://pub.dev/packages/shelf)
- [WebView Flutter](https://pub.dev/packages/webview_flutter)
