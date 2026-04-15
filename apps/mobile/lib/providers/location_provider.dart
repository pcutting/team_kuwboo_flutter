import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Fallback coordinates (Central London) used until the device grants
/// location permission or while the first fix is still resolving.
class LatLng {
  const LatLng({required this.lat, required this.lng});
  final double lat;
  final double lng;

  static const london = LatLng(lat: 51.5074, lng: -0.1278);
}

/// Resolve the device's current location. Returns [LatLng.london] if
/// permission is denied, location services are off, or the request
/// errors — so callers always get a usable coordinate.
Future<LatLng> resolveCurrentLocation() async {
  try {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return LatLng.london;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return LatLng.london;
    }

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 5),
      ),
    );
    return LatLng(lat: pos.latitude, lng: pos.longitude);
  } catch (_) {
    return LatLng.london;
  }
}

/// Riverpod provider — cached for the session. Invalidate to re-query.
final currentLocationProvider = FutureProvider<LatLng>((ref) {
  return resolveCurrentLocation();
});
