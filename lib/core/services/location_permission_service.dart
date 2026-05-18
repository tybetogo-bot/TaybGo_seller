import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// State representing the current location permission status.
enum LocationPermissionState {
  /// Permission has been granted (either always or whenInUse).
  granted,

  /// Permission has been denied by the user.
  denied,

  /// Permission has been permanently denied (user must go to settings).
  permanentlyDenied,

  /// Location services (GPS) are disabled on the device.
  serviceDisabled,

  /// The permission status is still being determined.
  loading,
}

/// State used to coordinate the one-time automatic permission request that
/// happens after a fresh login.
enum LocationPermissionAutoRequestState { idle, pending, requesting }

/// Provider that exposes the current location permission status.
///
/// Uses a [Notifier] that checks location permission on build and re-checks
/// whenever the app resumes from background via a [WidgetsBindingObserver].
final locationPermissionProvider =
    NotifierProvider<LocationPermissionNotifier, LocationPermissionState>(
      LocationPermissionNotifier.new,
    );

/// Provider that tracks whether a post-login auto-request should run.
final locationPermissionAutoRequestProvider =
    NotifierProvider<
      LocationPermissionAutoRequestNotifier,
      LocationPermissionAutoRequestState
    >(LocationPermissionAutoRequestNotifier.new);

/// Notifier that monitors location permission status.
///
/// On build it performs an initial check. It registers a
/// [WidgetsBindingObserver] so it can re-check permissions whenever the app
/// returns to the foreground (e.g. after the user changes settings).
class LocationPermissionNotifier extends Notifier<LocationPermissionState> {
  _AppLifecycleObserver? _observer;

  @override
  LocationPermissionState build() {
    _observer = _AppLifecycleObserver(onResumed: checkPermission);
    WidgetsBinding.instance.addObserver(_observer!);

    ref.onDispose(() {
      if (_observer != null) {
        WidgetsBinding.instance.removeObserver(_observer!);
        _observer = null;
      }
    });

    // Kick off the initial check. The state starts as loading and will be
    // updated asynchronously.
    checkPermission();

    return LocationPermissionState.loading;
  }

  /// Checks the current location permission and service status and updates
  /// the state accordingly.
  Future<LocationPermissionState> checkPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = LocationPermissionState.serviceDisabled;
        return state;
      }

      final permission = await Geolocator.checkPermission();
      state = _mapPermission(permission);
      return state;
    } catch (e) {
      debugPrint('[LocationPermission] checkPermission error: $e');
      state = LocationPermissionState.denied;
      return state;
    }
  }

  /// Requests location permission from the user.
  Future<LocationPermissionState> requestPermission() async {
    state = LocationPermissionState.loading;

    try {
      final permission = await Geolocator.requestPermission();
      state = _mapPermission(permission);
    } catch (e) {
      debugPrint('[LocationPermission] requestPermission error: $e');
      state = LocationPermissionState.denied;
    }

    return state;
  }

  /// Automatically requests permission only when the app can still show the
  /// native permission prompt.
  ///
  /// For disabled services or permanently denied permission, the current state
  /// is preserved so the existing banner can guide the user.
  Future<void> requestPermissionIfNeeded() async {
    final currentState = await checkPermission();
    if (currentState != LocationPermissionState.denied) {
      return;
    }

    await requestPermission();
  }

  /// Opens the device's app settings so the user can manually grant
  /// location permission.
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Opens the device's location/GPS settings so the user can enable
  /// location services.
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Performs the appropriate action based on the current state:
  /// - serviceDisabled -> open location settings
  /// - permanentlyDenied -> open app settings
  /// - denied -> request permission
  Future<void> handleEnableAction() async {
    switch (state) {
      case LocationPermissionState.serviceDisabled:
        await openLocationSettings();
      case LocationPermissionState.permanentlyDenied:
        await openAppSettings();
      case LocationPermissionState.denied:
        await requestPermission();
      default:
        break;
    }
  }

  LocationPermissionState _mapPermission(LocationPermission permission) {
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return LocationPermissionState.granted;
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionState.permanentlyDenied;
    }

    return LocationPermissionState.denied;
  }
}

/// Notifier for coordinating a single post-login auto-request.
class LocationPermissionAutoRequestNotifier
    extends Notifier<LocationPermissionAutoRequestState> {
  @override
  LocationPermissionAutoRequestState build() {
    return LocationPermissionAutoRequestState.idle;
  }

  void queueAfterLogin() {
    state = LocationPermissionAutoRequestState.pending;
  }

  void markRequesting() {
    state = LocationPermissionAutoRequestState.requesting;
  }

  void clear() {
    state = LocationPermissionAutoRequestState.idle;
  }
}

/// Internal [WidgetsBindingObserver] that fires a callback when the app
/// lifecycle transitions to [AppLifecycleState.resumed].
class _AppLifecycleObserver extends WidgetsBindingObserver {
  _AppLifecycleObserver({required this.onResumed});

  final VoidCallback onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}
