import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:my_meds/features/locator/data/overpass_places_repository.dart';
import 'package:my_meds/features/locator/domain/models/healthcare_place.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  group('HealthcarePlace model', () {
    test('parses from Overpass JSON correctly', () {
      final json = {
        'id': 123456,
        'lat': 48.8584,
        'lon': 2.2945,
        'tags': {
          'name': 'Pharmacie de la Tour',
          'amenity': 'pharmacy',
          'addr:street': 'Avenue Gustave Eiffel',
          'addr:housenumber': '5',
          'addr:city': 'Paris',
          'phone': '+33 1 45 55 00 00',
          'opening_hours': '24/7',
        },
      };

      final place = HealthcarePlace.fromOverpassJson(json);

      expect(place.id, '123456');
      expect(place.name, 'Pharmacie de la Tour');
      expect(place.type, HealthcarePlaceType.pharmacy);
      expect(place.latitude, 48.8584);
      expect(place.longitude, 2.2945);
      expect(place.address, '5 Avenue Gustave Eiffel, Paris');
      expect(place.phone, '+33 1 45 55 00 00');
      expect(place.isOpenNow, isTrue);
      expect(place.openingHoursText, '24/7');
    });

    test('formats distance correctly (meters vs kilometers)', () {
      const placeMeters = HealthcarePlace(
        id: '1',
        name: 'Local Clinic',
        type: HealthcarePlaceType.clinic,
        latitude: 0,
        longitude: 0,
        address: '123 St',
        distanceInMeters: 450.4,
      );
      expect(placeMeters.formattedDistance, '450 m');

      const placeKm = HealthcarePlace(
        id: '2',
        name: 'General Hospital',
        type: HealthcarePlaceType.hospital,
        latitude: 0,
        longitude: 0,
        address: '456 Ave',
        distanceInMeters: 2340.0,
      );
      expect(placeKm.formattedDistance, '2.3 km');
    });
  });

  group('OverpassPlacesRepository', () {
    late MockHttpClient mockHttpClient;
    late OverpassPlacesRepository repository;

    setUp(() {
      mockHttpClient = MockHttpClient();
      repository = OverpassPlacesRepository(httpClient: mockHttpClient);
    });

    test('fetches and sorts nearby places by distance from Overpass response', () async {
      final overpassResponse = {
        'elements': [
          {
            'id': 101,
            'lat': 48.8600,
            'lon': 2.3000,
            'tags': {
              'name': 'Far Hospital',
              'amenity': 'hospital',
              'addr:street': 'Rue Lointaine',
            },
          },
          {
            'id': 102,
            'lat': 48.8570,
            'lon': 2.2950,
            'tags': {
              'name': 'Close Pharmacy',
              'amenity': 'pharmacy',
              'addr:street': 'Rue Proche',
            },
          },
        ],
      };

      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode(overpassResponse),
            200,
          ));

      final places = await repository.getNearbyPlaces(
        latitude: 48.8566,
        longitude: 2.2940,
        radiusInMeters: 5000,
      );

      expect(places.length, 2);
      expect(places.first.name, 'Close Pharmacy');
      expect(places.last.name, 'Far Hospital');
      expect(places.first.distanceInMeters, isNotNull);
      expect(places.last.distanceInMeters, isNotNull);
      expect(places.first.distanceInMeters! < places.last.distanceInMeters!, isTrue);
    });

    test('returns fallback places on server error (HTTP 500)', () async {
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('Server error', 500));

      final places = await repository.getNearbyPlaces(
        latitude: 48.8566,
        longitude: 2.2940,
        type: HealthcarePlaceType.pharmacy,
      );

      expect(places.isNotEmpty, isTrue);
      expect(places.every((p) => p.type == HealthcarePlaceType.pharmacy), isTrue);
    });

    test('returns fallback places on network timeout/exception', () async {
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenThrow(http.ClientException('Offline'));

      final places = await repository.getNearbyPlaces(
        latitude: 48.8566,
        longitude: 2.2940,
      );

      expect(places.isNotEmpty, isTrue);
      expect(places.any((p) => p.type == HealthcarePlaceType.pharmacy), isTrue);
      expect(places.any((p) => p.type == HealthcarePlaceType.hospital), isTrue);
    });
  });
}
