import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_meds/features/search/data/medication_exception.dart';
import 'package:my_meds/features/search/data/openfda_medication_repository.dart';
import 'package:my_meds/features/search/domain/medication_info.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockHttpClient mockHttpClient;
  late OpenFdaMedicationRepository repository;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://api.fda.gov/drug/label.json'));
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    SharedPreferences.setMockInitialValues({});
    repository = OpenFdaMedicationRepository(httpClient: mockHttpClient);
  });

  const mockOpenFdaJsonResponse = {
    'results': [
      {
        'set_id': 'spl-ibuprofen-001',
        'id': 'fda-001',
        'openfda': {
          'brand_name': ['Advil', 'Motrin'],
          'generic_name': ['Ibuprofen'],
          'substance_name': ['IBUPROFEN'],
          'route': ['ORAL'],
          'product_type': ['HUMAN OTC DRUG'],
        },
        'purpose': ['Pain reliever / Fever reducer'],
        'indications_and_usage': [
          'Temporarily relieves minor aches and pains due to headache, toothache, backache.'
        ],
        'dosage_and_administration': [
          'Do not take more than directed. Adults and children 12 years and over: take 1 tablet every 4 to 6 hours.'
        ],
        'storage_and_handling': [
          'Store at 20-25C (68-77F). Avoid excessive heat 40C (104F).'
        ],
        'warnings': [
          'Stomach bleeding warning: This product contains an NSAID, which may cause severe stomach bleeding.'
        ],
        'boxed_warning': ['Cardiovascular and Gastrointestinal Risk Warning'],
        'active_ingredient': ['Ibuprofen 200mg'],
      }
    ]
  };

  group('OpenFdaMedicationRepository', () {
    group('searchMedications', () {
      test('returns parsed MedicationInfo list on HTTP 200', () async {
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(
            jsonEncode(mockOpenFdaJsonResponse),
            200,
          ),
        );

        final results = await repository.searchMedications('Ibuprofen');

        expect(results.length, equals(1));
        final med = results.first;
        expect(med.id, equals('spl-ibuprofen-001'));
        expect(med.name, equals('Advil'));
        expect(med.genericName, equals('Ibuprofen'));
        expect(med.purpose, equals('Pain reliever / Fever reducer'));
        expect(
          med.dosageAndAdministration,
          contains('take 1 tablet every 4 to 6 hours'),
        );
        expect(med.storageAndHandling, contains('Store at 20-25C'));
        expect(med.boxedWarning, contains('Cardiovascular'));
        expect(med.activeIngredients, contains('Ibuprofen 200mg'));
        expect(med.route, contains('ORAL'));
      });

      test('returns empty list on HTTP 404 (no matches)', () async {
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'error': {'code': 'NOT_FOUND', 'message': 'No matches found!'}
            }),
            404,
          ),
        );

        final results = await repository.searchMedications('NonExistentDrug12345');

        expect(results, isEmpty);
      });

      test('throws MedicationException on HTTP 500 error', () async {
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response('Internal Server Error', 500),
        );

        expect(
          () => repository.searchMedications('Aspirin'),
          throwsA(isA<MedicationException>()),
        );
      });

      test('throws MedicationException with isOffline on ClientException', () async {
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenThrow(
          http.ClientException('Connection failed'),
        );

        expect(
          () => repository.searchMedications('Aspirin'),
          throwsA(predicate((e) =>
              e is MedicationException && e.isOffline == true)),
        );
      });

      test('returns empty list for blank query without network call', () async {
        final results = await repository.searchMedications('   ');
        expect(results, isEmpty);
        verifyNever(() => mockHttpClient.get(any(), headers: any(named: 'headers')));
      });
    });

    group('getMedicationById', () {
      test('returns MedicationInfo on matching set_id', () async {
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(
            jsonEncode(mockOpenFdaJsonResponse),
            200,
          ),
        );

        final med = await repository.getMedicationById('spl-ibuprofen-001');

        expect(med, isNotNull);
        expect(med!.name, equals('Advil'));
      });

      test('returns null when medication is not found', () async {
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(
            jsonEncode({'results': []}),
            200,
          ),
        );

        final med = await repository.getMedicationById('missing-id');

        expect(med, isNull);
      });
    });

    group('Recent Searches Cache', () {
      test('adds, retrieves, deduplicates, and limits recent searches', () async {
        await repository.addRecentSearch('Ibuprofen');
        await repository.addRecentSearch('Amoxicillin');
        await repository.addRecentSearch('Ibuprofen'); // duplicate should move to top

        final searches = await repository.getRecentSearches();

        expect(searches.length, equals(2));
        expect(searches.first, equals('Ibuprofen'));
        expect(searches.last, equals('Amoxicillin'));

        await repository.clearRecentSearches();
        final cleared = await repository.getRecentSearches();
        expect(cleared, isEmpty);
      });
    });

    group('MedicationInfo Serialization', () {
      test('toJson and fromJson cycle works accurately', () {
        const original = MedicationInfo(
          id: 'test-123',
          name: 'Amoxicillin',
          genericName: 'Amoxicillin Trihydrate',
          brandNames: ['Amoxil'],
          purpose: 'Antibacterial',
          indicationsAndUsage: 'Treatment of infections.',
          dosageAndAdministration: '500 mg every 8 hours.',
          storageAndHandling: 'Store below 25C.',
          warnings: 'Hypersensitivity reactions.',
          boxedWarning: null,
          activeIngredients: ['Amoxicillin 500mg'],
          route: ['ORAL'],
          productType: 'PRESCRIPTION',
        );

        final json = original.toJson();
        final recreated = MedicationInfo.fromJson(json);

        expect(recreated.id, equals(original.id));
        expect(recreated.name, equals(original.name));
        expect(recreated.genericName, equals(original.genericName));
        expect(recreated.purpose, equals(original.purpose));
        expect(recreated.dosageAndAdministration, equals(original.dosageAndAdministration));
        expect(recreated.storageAndHandling, equals(original.storageAndHandling));
        expect(recreated.warnings, equals(original.warnings));
        expect(recreated.activeIngredients, equals(original.activeIngredients));
        expect(recreated.route, equals(original.route));
      });
    });
  });
}
