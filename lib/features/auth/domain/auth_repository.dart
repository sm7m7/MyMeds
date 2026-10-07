import 'package:my_meds/features/auth/domain/user_entity.dart';

/// Contract for authentication operations in MyMeds.
abstract class AuthRepository {
  /// Stream of authentication state changes.
  Stream<AppUser?> authStateChanges();

  /// Gets the currently authenticated user, or null.
  AppUser? get currentUser;

  /// Signs in with email and password.
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Registers a new user with email and password and creates their Firestore record.
  Future<AppUser> registerWithEmailAndPassword({
    required String email,
    required String password,
    String preferredLanguage = 'en',
  });

  /// Signs in or registers with Google and ensures a Firestore user record exists.
  Future<AppUser> signInWithGoogle({
    String preferredLanguage = 'en',
  });

  /// Sends a password reset email to [email].
  Future<void> sendPasswordResetEmail({
    required String email,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Deletes the current user's account and all associated Firestore data.
  Future<void> deleteAccount();
}
