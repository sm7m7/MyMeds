import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:my_meds/features/locator/data/overpass_places_repository.dart';
import 'package:my_meds/features/locator/domain/models/healthcare_place.dart';
import 'package:my_meds/features/locator/domain/repositories/places_repository.dart';
import 'package:my_meds/features/locator/domain/services/location_service.dart';

// ── Dependency Providers ──────────────────────────────────────────────────────

final locationServiceProvider = Provider<LocationService>((ref) {
  return const LocationService();
});

final placesRepositoryProvider = Provider<PlacesRepository>((ref) {
  return OverpassPlacesRepository();
});

// ── State Providers ──────────────────────────────────────────────────────────

/// Current filter by place type (null = all).
final healthcareTypeFilterProvider =
    StateProvider<HealthcarePlaceType?>((ref) => null);

/// View mode toggle: Map view or List view.
final locatorViewModeProvider = StateProvider<bool>((ref) => true); // true = map, false = list

/// Selected place for popup card on map.
final selectedPlaceProvider =
    StateProvider<HealthcarePlace?>((ref) => null);

/// Device position provider.
final userPositionProvider =
    FutureProvider.autoDispose<Position?>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return service.getCurrentPosition();
});

/// Nearby places provider based on user position and active type filter.
final nearbyPlacesProvider =
    FutureProvider.autoDispose<List<HealthcarePlace>>((ref) async {
  final positionAsync = ref.watch(userPositionProvider);

  // If location isn't resolved yet or failed, use a default city center coordinates
  final position = positionAsync.valueOrNull;
  final double lat = position?.latitude ?? 48.8566; // Fallback: Paris center
  final double lon = position?.longitude ?? 2.3522;

  final typeFilter = ref.watch(healthcareTypeFilterProvider);
  final repo = ref.watch(placesRepositoryProvider);

  return repo.getNearbyPlaces(
    latitude: lat,
    longitude: lon,
    radiusInMeters: 5000,
    type: typeFilter,
  );
});
