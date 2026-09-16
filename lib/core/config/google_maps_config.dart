/// Google Maps Platform configuration.
abstract final class GoogleMapsConfig {
  /// Browser-visible key used by the Maps JavaScript API on web and by the
  /// existing Places REST integration on native platforms.
  ///
  /// Override this at build/run time with:
  /// `--dart-define=GOOGLE_MAPS_API_KEY=...`.
  static const String apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
}
