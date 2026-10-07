// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_meds/features/auth/data/auth_exception.dart';
import 'package:my_meds/features/auth/data/firebase_auth_repository.dart';

// Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockGoogleSignIn mockGoogleSignIn;
  late FirebaseAuthRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockGoogleSignIn = MockGoogleSignIn();

    repository = FirebaseAuthRepository(
      firebaseAuth: mockFirebaseAuth,
      firestore: mockFirestore,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('FirebaseAuthRepository', () {
    const testUid = 'user-123';
    const testEmail = 'test@mymeds.com';
    const testPassword = 'Password123!';

    group('signInWithEmailAndPassword', () {
      test('returns AppUser on successful sign in', () async {
        final mockUser = MockUser();
        when(() => mockUser.uid).thenReturn(testUid);
        when(() => mockUser.email).thenReturn(testEmail);
        when(() => mockUser.displayName).thenReturn('Test User');
        when(() => mockUser.photoURL).thenReturn(null);

        final mockCredential = MockUserCredential();
        when(() => mockCredential.user).thenReturn(mockUser);

        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenAnswer((_) => Future.value(mockCredential));

        final user = await repository.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );

        expect(user.uid, equals(testUid));
        expect(user.email, equals(testEmail));
        expect(user.displayName, equals('Test User'));
      });

      test('throws AuthException on FirebaseAuthException', () async {
        when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenThrow(
          FirebaseAuthException(
            code: 'wrong-password',
            message: 'Wrong password provided.',
          ),
        );

        expect(
          () => repository.signInWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('registerWithEmailAndPassword', () {
      test(
          'creates user in auth and creates minimal users/{uid} document in Firestore',
          () async {
        final mockUser = MockUser();
        when(() => mockUser.uid).thenReturn(testUid);
        when(() => mockUser.email).thenReturn(testEmail);

        final mockCredential = MockUserCredential();
        when(() => mockCredential.user).thenReturn(mockUser);

        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenAnswer((_) => Future.value(mockCredential));

        final mockUsersCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();

        when(() => mockFirestore.collection('users'))
            .thenReturn(mockUsersCollection);
        when(() => mockUsersCollection.doc(testUid)).thenReturn(mockDocRef);
        when(() => mockDocRef.set(any())).thenAnswer((_) => Future.value());

        final user = await repository.registerWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
          preferredLanguage: 'fr',
        );

        expect(user.uid, equals(testUid));
        expect(user.email, equals(testEmail));
        expect(user.preferredLanguage, equals('fr'));

        verify(() => mockDocRef.set(any())).called(1);
      });

      test('throws AuthException when email already in use', () async {
        when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: testEmail,
              password: testPassword,
            )).thenThrow(
          FirebaseAuthException(
            code: 'email-already-in-use',
            message: 'Email in use',
          ),
        );

        expect(
          () => repository.registerWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
          throwsA(isA<AuthException>()),
        );
      });
    });

    group('signInWithGoogle', () {
      test('throws AuthException when Google sign in is cancelled', () async {
        when(() => mockGoogleSignIn.signIn())
            .thenAnswer((_) => Future.value(null));

        expect(
          () => repository.signInWithGoogle(),
          throwsA(predicate((e) =>
              e is AuthException &&
              e.message == 'Google Sign-In was cancelled.')),
        );
      });

      test('signs in and creates Firestore doc if user does not exist',
          () async {
        final mockGoogleUser = MockGoogleSignInAccount();
        final mockGoogleAuth = MockGoogleSignInAuthentication();
        when(() => mockGoogleAuth.accessToken).thenReturn('fake-access-token');
        when(() => mockGoogleAuth.idToken).thenReturn('fake-id-token');
        when(() => mockGoogleUser.authentication)
            .thenAnswer((_) => Future.value(mockGoogleAuth));
        when(() => mockGoogleSignIn.signIn())
            .thenAnswer((_) => Future.value(mockGoogleUser));

        final mockUser = MockUser();
        when(() => mockUser.uid).thenReturn(testUid);
        when(() => mockUser.email).thenReturn(testEmail);
        when(() => mockUser.displayName).thenReturn('Google User');
        when(() => mockUser.photoURL).thenReturn(null);

        final mockCredential = MockUserCredential();
        when(() => mockCredential.user).thenReturn(mockUser);
        when(() => mockFirebaseAuth.signInWithCredential(any()))
            .thenAnswer((_) => Future.value(mockCredential));

        final mockUsersCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();
        final mockDocSnapshot = MockDocumentSnapshot();

        when(() => mockFirestore.collection('users'))
            .thenReturn(mockUsersCollection);
        when(() => mockUsersCollection.doc(testUid)).thenReturn(mockDocRef);
        when(() => mockDocRef.get())
            .thenAnswer((_) => Future.value(mockDocSnapshot));
        when(() => mockDocSnapshot.exists).thenReturn(false);
        when(() => mockDocRef.set(any())).thenAnswer((_) => Future.value());

        final result = await repository.signInWithGoogle(preferredLanguage: 'ar');

        expect(result.uid, equals(testUid));
        expect(result.email, equals(testEmail));
        verify(() => mockDocRef.set(any())).called(1);
      });
    });

    group('sendPasswordResetEmail', () {
      test('calls firebaseAuth.sendPasswordResetEmail', () async {
        when(() => mockFirebaseAuth.sendPasswordResetEmail(email: testEmail))
            .thenAnswer((_) => Future.value());

        await repository.sendPasswordResetEmail(email: testEmail);

        verify(() => mockFirebaseAuth.sendPasswordResetEmail(email: testEmail))
            .called(1);
      });
    });

    group('signOut', () {
      test('signs out from Firebase Auth and GoogleSignIn', () async {
        when(() => mockFirebaseAuth.signOut())
            .thenAnswer((_) => Future.value());
        when(() => mockGoogleSignIn.signOut())
            .thenAnswer((_) => Future.value(null));

        await repository.signOut();

        verify(() => mockFirebaseAuth.signOut()).called(1);
        verify(() => mockGoogleSignIn.signOut()).called(1);
      });
    });

    group('deleteAccount', () {
      test(
          'deletes user document in Firestore and deletes user account in Auth',
          () async {
        final mockUser = MockUser();
        when(() => mockUser.uid).thenReturn(testUid);
        when(() => mockUser.delete()).thenAnswer((_) => Future.value());
        when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);

        final mockUsersCollection = MockCollectionReference();
        final mockDocRef = MockDocumentReference();

        when(() => mockFirestore.collection('users'))
            .thenReturn(mockUsersCollection);
        when(() => mockUsersCollection.doc(testUid)).thenReturn(mockDocRef);
        when(() => mockDocRef.delete()).thenAnswer((_) => Future.value());
        when(() => mockGoogleSignIn.signOut())
            .thenAnswer((_) => Future.value(null));

        await repository.deleteAccount();

        verify(() => mockDocRef.delete()).called(1);
        verify(() => mockUser.delete()).called(1);
      });

      test('throws AuthException when no current user', () async {
        when(() => mockFirebaseAuth.currentUser).thenReturn(null);

        expect(
          () => repository.deleteAccount(),
          throwsA(isA<AuthException>()),
        );
      });
    });
  });
}
