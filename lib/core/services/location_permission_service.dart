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

  /// Location services are disabled on the device.
  serviceDisabled,

  /// The permission status is still being determined.
  loading,
}

/// Provider that exposes the current location permission status.
///
/// Uses a [Notifier] that checks location permission on build and re-checks
/// whenever the app resumes from background via a [WidgetsBindingObserver].
final locationPermissionProvider =
    NotifierProvider<LocationPermissionNotifier, LocationPermissionState>(
  LocationPermissionNotifier.new,
);

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
  Future<void> checkPermission() async {
    try {
      // First check if location services are enabled at the OS level.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = LocationPermissionState.serviceDisabled;
        return;
      }

      // Then check the app-level permission using Geolocator.
      final permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        state = LocationPermissionState.granted;
      } else if (permission == LocationPermission.deniedForever) {
        state = LocationPermissionState.permanentlyDenied;
      } else {
        state = LocationPermissionState.denied;
      }
    } catch (e) {
      debugPrint('⚠️ [LocationPermission] checkPermission error: $e');
      // Default to denied so the banner shows and user can take action
      state = LocationPermissionState.denied;
    }
  }

  /// Requests location permission from the user.
  ///
  /// After the request completes the state is re-evaluated automatically.
  Future<void> requestPermission() async {
    final permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      state = LocationPermissionState.granted;
    } else if (permission == LocationPermission.deniedForever) {
      state = LocationPermissionState.permanentlyDenied;
    } else {
      state = LocationPermissionState.denied;
    }
  }

  /// Opens the device's app settings so the user can manually grant
  /// location permission.
  Future<void> openSettings() async {
    await Geolocator.openAppSettings();
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
