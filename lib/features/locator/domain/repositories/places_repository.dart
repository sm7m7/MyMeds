import 'package:my_meds/features/locator/domain/models/healthcare_place.dart';

/// Contract for fetching nearby healthcare facilities and pharmacies.
///
/// Can be backed by Overpass API (OpenStreetMap) or Google Places API.
abstract class PlacesRepository {
  const PlacesRepository();

  /// Fetches nearby healthcare facilities within [radiusInMeters] of ([latitude], [longitude]).
  ///
  /// Can optionally filter by [type].
  Future<List<HealthcarePlace>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radiusInMeters = 5000,
    HealthcarePlaceType? type,
  });
}
