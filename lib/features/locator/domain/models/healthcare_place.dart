import 'package:flutter/foundation.dart';

/// Healthcare facility categories supported by the locator.
enum HealthcarePlaceType {
  pharmacy,
  hospital,
  clinic;

  String get displayName {
    switch (this) {
      case HealthcarePlaceType.pharmacy:
        return 'Pharmacy';
      case HealthcarePlaceType.hospital:
        return 'Hospital';
      case HealthcarePlaceType.clinic:
        return 'Clinic';
    }
  }

  /// OSM Amenity tag match.
  static HealthcarePlaceType fromOsmAmenity(String? amenity) {
    switch (amenity?.toLowerCase()) {
      case 'hospital':
        return HealthcarePlaceType.hospital;
      case 'clinic':
      case 'doctors':
      case 'health_post':
        return HealthcarePlaceType.clinic;
      case 'pharmacy':
      default:
        return HealthcarePlaceType.pharmacy;
    }
  }
}

/// Domain model representing a nearby pharmacy or healthcare facility.
@immutable
class HealthcarePlace {
  const HealthcarePlace({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.phone,
    this.isOpenNow,
    this.distanceInMeters,
    this.openingHoursText,
  });

  final String id;
  final String name;
  final HealthcarePlaceType type;
  final double latitude;
  final double longitude;
  final String address;
  final String? phone;
  final bool? isOpenNow;
  final double? distanceInMeters;
  final String? openingHoursText;

  /// Formatted human-readable distance (e.g. "350 m" or "2.4 km").
  String get formattedDistance {
    if (distanceInMeters == null) return '';
    if (distanceInMeters! < 1000) {
      return '${distanceInMeters!.round()} m';
    }
    final km = distanceInMeters! / 1000.0;
    return '${km.toStringAsFixed(1)} km';
  }

  HealthcarePlace copyWith({
    String? id,
    String? name,
    HealthcarePlaceType? type,
    double? latitude,
    double? longitude,
    String? address,
    String? phone,
    bool? isOpenNow,
    double? distanceInMeters,
    String? openingHoursText,
  }) {
    return HealthcarePlace(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
      openingHoursText: openingHoursText ?? this.openingHoursText,
    );
  }

  /// Creates a [HealthcarePlace] from an Overpass API JSON node/way element.
  factory HealthcarePlace.fromOverpassJson(Map<String, dynamic> json) {
    final tags = (json['tags'] as Map<String, dynamic>?) ?? {};
    final id = json['id']?.toString() ?? UniqueKey().toString();

    // Coordinates can be direct (for node) or in 'center' (for way/relation)
    final double lat = (json['lat'] as num?)?.toDouble() ??
        ((json['center'] as Map<String, dynamic>?)?['lat'] as num?)?.toDouble() ??
        0.0;
    final double lon = (json['lon'] as num?)?.toDouble() ??
        ((json['center'] as Map<String, dynamic>?)?['lon'] as num?)?.toDouble() ??
        0.0;

    final name = tags['name'] as String? ??
        tags['name:en'] as String? ??
        tags['operator'] as String? ??
        tags['amenity']?.toString().toUpperCase() ??
        'Healthcare Facility';

    // Construct address from OSM street/housenumber tags
    final street = tags['addr:street'] as String?;
    final houseNumber = tags['addr:housenumber'] as String?;
    final city = tags['addr:city'] as String?;

    String computedAddress = '';
    if (street != null) {
      computedAddress = houseNumber != null ? '$houseNumber $street' : street;
      if (city != null) computedAddress += ', $city';
    } else if (tags['addr:full'] != null) {
      computedAddress = tags['addr:full'] as String;
    } else {
      computedAddress = city ?? 'Nearby address';
    }

    final phone = tags['phone'] as String? ??
        tags['contact:phone'] as String? ??
        tags['contact:mobile'] as String?;

    final openingHours = tags['opening_hours'] as String?;
    bool? isOpen;
    if (openingHours != null) {
      if (openingHours == '24/7') {
        isOpen = true;
      }
    }

    return HealthcarePlace(
      id: id,
      name: name,
      type: HealthcarePlaceType.fromOsmAmenity(tags['amenity'] as String?),
      latitude: lat,
      longitude: lon,
      address: computedAddress,
      phone: phone,
      isOpenNow: isOpen,
      openingHoursText: openingHours,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'phone': phone,
      'isOpenNow': isOpenNow,
      'distanceInMeters': distanceInMeters,
      'openingHoursText': openingHoursText,
    };
  }

  factory HealthcarePlace.fromJson(Map<String, dynamic> json) {
    return HealthcarePlace(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: HealthcarePlaceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HealthcarePlaceType.pharmacy,
      ),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
      phone: json['phone'] as String?,
      isOpenNow: json['isOpenNow'] as bool?,
      distanceInMeters: (json['distanceInMeters'] as num?)?.toDouble(),
      openingHoursText: json['openingHoursText'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthcarePlace &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
