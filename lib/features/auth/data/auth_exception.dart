import 'package:firebase_auth/firebase_auth.dart';

/// Exception thrown for authentication errors with user-friendly messages.
class AuthException implements Exception {
  const AuthException(this.message, {this.code});

  final String message;
  final String? code;

  /// Creates an [AuthException] from a Firebase [FirebaseAuthException].
  factory AuthException.fromFirebaseAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'user-not-found':
        message = 'No account found with this email address.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email address.';
        break;
      case 'invalid-email':
        message = 'The email address is not valid.';
        break;
      case 'weak-password':
        message = 'The password provided is too weak (minimum 6 characters).';
        break;
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        message = 'Invalid email or password. Please verify your credentials.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many failed login attempts. Please try again later.';
        break;
      case 'operation-not-allowed':
        message = 'This sign-in method is not enabled.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your internet connection.';
        break;
      case 'requires-recent-login':
        message = 'This operation is sensitive and requires recent authentication. Please log in again.';
        break;
      default:
        message = e.message ?? 'An unexpected authentication error occurred.';
    }
    return AuthException(message, code: e.code);
  }

  @override
  String toString() => message;
}
