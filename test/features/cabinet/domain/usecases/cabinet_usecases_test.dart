import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_status.dart';
import 'package:my_meds/features/cabinet/domain/repositories/cabinet_repository.dart';
import 'package:my_meds/features/cabinet/domain/usecases/add_medication_usecase.dart';
import 'package:my_meds/features/cabinet/domain/usecases/delete_medication_usecase.dart';
import 'package:my_meds/features/cabinet/domain/usecases/filter_medications_usecase.dart';
import 'package:my_meds/features/cabinet/domain/usecases/update_medication_usecase.dart';
import 'package:my_meds/features/cabinet/domain/usecases/watch_medications_usecase.dart';

class MockCabinetRepository extends Mock implements CabinetRepository {}

class FakeMedication extends Fake implements Medication {}

void main() {
  late MockCabinetRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeMedication());
  });

  setUp(() {
    mockRepository = MockCabinetRepository();
  });

  final baseDate = DateTime(2026, 6, 1);
  final testMeds = [
    Medication(
      id: '1',
      name: 'Amoxicillin',
      dosage: '500 mg',
      form: MedicationForm.capsule,
      quantity: 20,
      expirationDate: baseDate.add(const Duration(days: 100)),
      createdAt: baseDate,
    ),
    Medication(
      id: '2',
      name: 'Advil',
      dosage: '200 mg',
      form: MedicationForm.tablet,
      quantity: 4, // low stock
      expirationDate: baseDate.add(const Duration(days: 15)), // expiring soon
      createdAt: baseDate,
    ),
    Medication(
      id: '3',
      name: 'Cough Syrup',
      dosage: '15 ml',
      form: MedicationForm.syrup,
      quantity: 30,
      expirationDate: baseDate.subtract(const Duration(days: 5)), // expired
      createdAt: baseDate,
    ),
  ];

  group('FilterMedicationsUseCase', () {
    const useCase = FilterMedicationsUseCase();

    test('filters by text query in name, dosage, or notes', () {
      final results = useCase(medications: testMeds, query: 'Advil');
      expect(results.length, equals(1));
      expect(results.first.name, equals('Advil'));
    });

    test('filters by medication form', () {
      final results =
          useCase(medications: testMeds, formFilter: MedicationForm.syrup);
      expect(results.length, equals(1));
      expect(results.first.name, equals('Cough Syrup'));
    });

    test('filters by medication status (expired, low stock, etc.)', () {
      final expired = useCase(
        medications: testMeds,
        statusFilter: MedicationStatus.expired,
        now: baseDate,
      );
      expect(expired.length, equals(1));
      expect(expired.first.name, equals('Cough Syrup'));

      final lowStock = useCase(
        medications: testMeds,
        statusFilter: MedicationStatus.lowStock,
        now: baseDate,
      );
      expect(lowStock.length, equals(1));
      expect(lowStock.first.name, equals('Advil'));
    });
  });

  group('AddMedicationUseCase', () {
    late AddMedicationUseCase useCase;

    setUp(() {
      useCase = AddMedicationUseCase(mockRepository);
    });

    test('calls repository when input is valid', () async {
      when(() => mockRepository.addMedication(any(), any()))
          .thenAnswer((_) => Future.value());

      final med = testMeds.first;
      await useCase(userId: 'user-123', medication: med);

      verify(() => mockRepository.addMedication('user-123', med)).called(1);
    });

    test('throws FormatException when medication name is empty', () async {
      final invalidMed = testMeds.first.copyWith(name: '   ');

      expect(
        () => useCase(userId: 'user-123', medication: invalidMed),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('UpdateMedicationUseCase', () {
    late UpdateMedicationUseCase useCase;

    setUp(() {
      useCase = UpdateMedicationUseCase(mockRepository);
    });

    test('calls repository update on valid input', () async {
      when(() => mockRepository.updateMedication(any(), any()))
          .thenAnswer((_) => Future.value());

      final med = testMeds.first;
      await useCase(userId: 'user-123', medication: med);

      verify(() => mockRepository.updateMedication('user-123', any()))
          .called(1);
    });
  });

  group('DeleteMedicationUseCase', () {
    test('calls repository delete with userId and medicationId', () async {
      final useCase = DeleteMedicationUseCase(mockRepository);
      when(() => mockRepository.deleteMedication(any(), any()))
          .thenAnswer((_) => Future.value());

      await useCase(userId: 'user-123', medicationId: 'med-1');

      verify(() => mockRepository.deleteMedication('user-123', 'med-1'))
          .called(1);
    });
  });

  group('WatchMedicationsUseCase', () {
    test('calls repository watchMedications and returns stream', () {
      final useCase = WatchMedicationsUseCase(mockRepository);
      when(() => mockRepository.watchMedications('user-123'))
          .thenAnswer((_) => Stream.value(testMeds));

      final stream = useCase('user-123');

      expect(stream, emits(testMeds));
      verify(() => mockRepository.watchMedications('user-123')).called(1);
    });
  });
}
