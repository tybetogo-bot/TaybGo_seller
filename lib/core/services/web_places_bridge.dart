/// Conditional access to the Google Maps JavaScript Places bridge.
library;

export 'web_places_bridge_stub.dart'
    if (dart.library.js_interop) 'web_places_bridge_web.dart';
