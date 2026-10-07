import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_meds/features/auth/data/firebase_auth_repository.dart';
import 'package:my_meds/features/auth/domain/auth_repository.dart';
import 'package:my_meds/features/auth/domain/user_entity.dart';

/// Provider for the [AuthRepository] instance.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository();
});

/// Stream provider that yields auth state changes as [AppUser?].
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges();
});

/// Convenience provider for the current [AppUser?].
final currentUserProvider = Provider<AppUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

/// Controller for executing auth actions (login, register, reset, delete).
class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  final AuthRepository _authRepository;

  /// Signs in with email and password.
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signInWithEmailAndPassword(
          email: email,
          password: password,
        ));
    return !state.hasError;
  }

  /// Registers a new user with email and password.
  Future<bool> registerWithEmailAndPassword({
    required String email,
    required String password,
    String preferredLanguage = 'en',
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.registerWithEmailAndPassword(
          email: email,
          password: password,
          preferredLanguage: preferredLanguage,
        ));
    return !state.hasError;
  }

  /// Signs in with Google account.
  Future<bool> signInWithGoogle({String preferredLanguage = 'en'}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signInWithGoogle(
          preferredLanguage: preferredLanguage,
        ));
    return !state.hasError;
  }

  /// Sends a password reset email.
  Future<bool> sendPasswordResetEmail({required String email}) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.sendPasswordResetEmail(
          email: email,
        ));
    return !state.hasError;
  }

  /// Signs out current user.
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.signOut());
  }

  /// Deletes current user account and Firestore data.
  Future<bool> deleteAccount() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authRepository.deleteAccount());
    return !state.hasError;
  }
}

/// Provider for the [AuthController].
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository);
});
