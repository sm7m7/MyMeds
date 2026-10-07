// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_meds/features/cabinet/data/firestore_cabinet_repository.dart';
import 'package:my_meds/features/cabinet/domain/models/medication.dart';
import 'package:my_meds/features/cabinet/domain/models/medication_form.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockUserDoc;
  late MockCollectionReference mockMedsCollection;
  late FirestoreCabinetRepository repository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockMedsCollection = MockCollectionReference();

    when(() => mockFirestore.collection('users'))
        .thenReturn(mockUsersCollection);
    when(() => mockUsersCollection.doc('user-123')).thenReturn(mockUserDoc);
    when(() => mockUserDoc.collection('medications'))
        .thenReturn(mockMedsCollection);

    repository = FirestoreCabinetRepository(firestore: mockFirestore);
  });

  final testMedication = Medication(
    id: 'med-1',
    name: 'Amoxicillin',
    dosage: '500 mg',
    form: MedicationForm.capsule,
    quantity: 20,
    expirationDate: DateTime(2027, 1, 1),
    createdAt: DateTime(2026, 1, 1),
  );

  group('FirestoreCabinetRepository', () {
    test('addMedication sets document in users/{uid}/medications/{id}',
        () async {
      final mockDocRef = MockDocumentReference();
      when(() => mockMedsCollection.doc('med-1')).thenReturn(mockDocRef);
      when(() => mockDocRef.id).thenReturn('med-1');
      when(() => mockDocRef.set(any())).thenAnswer((_) => Future.value());

      await repository.addMedication('user-123', testMedication);

      verify(() => mockDocRef.set(any())).called(1);
    });

    test('updateMedication updates document in Firestore', () async {
      final mockDocRef = MockDocumentReference();
      when(() => mockMedsCollection.doc('med-1')).thenReturn(mockDocRef);
      when(() => mockDocRef.update(any())).thenAnswer((_) => Future.value());

      await repository.updateMedication('user-123', testMedication);

      verify(() => mockDocRef.update(any())).called(1);
    });

    test('deleteMedication deletes document in Firestore', () async {
      final mockDocRef = MockDocumentReference();
      when(() => mockMedsCollection.doc('med-1')).thenReturn(mockDocRef);
      when(() => mockDocRef.delete()).thenAnswer((_) => Future.value());

      await repository.deleteMedication('user-123', 'med-1');

      verify(() => mockDocRef.delete()).called(1);
    });

    test('getMedicationById returns parsed Medication or null', () async {
      final mockDocRef = MockDocumentReference();
      final mockDocSnapshot = MockDocumentSnapshot();

      when(() => mockMedsCollection.doc('med-1')).thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) => Future.value(mockDocSnapshot));
      when(() => mockDocSnapshot.exists).thenReturn(true);
      when(() => mockDocSnapshot.id).thenReturn('med-1');
      when(() => mockDocSnapshot.data()).thenReturn(testMedication.toJson());

      final result = await repository.getMedicationById('user-123', 'med-1');

      expect(result, isNotNull);
      expect(result!.id, equals('med-1'));
      expect(result.name, equals('Amoxicillin'));
    });
  });
}
