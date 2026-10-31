import 'package:geolocator/geolocator.dart';

/// Status of device location acquisition.
enum LocationPermissionState {
  granted,
  denied,
  deniedForever,
  serviceDisabled,
}

/// Service wrapping Geolocator permission handling and position resolution.
class LocationService {
  const LocationService();

  /// Checks and requests location permission.
  Future<LocationPermissionState> checkAndRequestPermission() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionState.serviceDisabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionState.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionState.deniedForever;
    }

    return LocationPermissionState.granted;
  }

  /// Gets current GPS position with fallback to last known position.
  Future<Position?> getCurrentPosition() async {
    try {
      final state = await checkAndRequestPermission();
      if (state != LocationPermissionState.granted) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  /// Opens the device system settings (for deniedForever scenario).
  Future<bool> openAppSettings() async {
    return Geolocator.openAppSettings();
  }

  /// Opens device location service settings (for serviceDisabled scenario).
  Future<bool> openLocationSettings() async {
    return Geolocator.openLocationSettings();
  }
}
