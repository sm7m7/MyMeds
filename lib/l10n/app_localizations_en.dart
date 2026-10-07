// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MyMeds';

  @override
  String get tabCabinet => 'Cabinet';

  @override
  String get tabSearch => 'Search';

  @override
  String get tabReminders => 'Reminders';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get tabMore => 'More';

  @override
  String get medicalDisclaimer =>
      'Informational only. Consult a healthcare professional.';

  @override
  String get cabinetEmpty => 'Your medication cabinet will appear here.';

  @override
  String get searchHint => 'Search for medications here.';

  @override
  String get remindersEmpty => 'Your medication reminders will appear here.';

  @override
  String get dashboardEmpty => 'Your health dashboard will appear here.';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get about => 'About';

  @override
  String get loginTitle => 'Welcome to MyMeds';

  @override
  String get loginSubtitle =>
      'Sign in to manage your medication schedule safely';

  @override
  String get emailLabel => 'Email address';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get confirmPasswordHint => 'Re-enter your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signInButton => 'Sign In';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get orDivider => 'OR';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get logIn => 'Log In';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerSubtitle =>
      'Start tracking your medications and reminders';

  @override
  String get registerButton => 'Create Account';

  @override
  String get preferredLanguageLabel => 'Preferred Language';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email address and we\'ll send you a link to reset your password';

  @override
  String get sendResetLinkButton => 'Send Reset Link';

  @override
  String get backToLogin => 'Back to Sign In';

  @override
  String get resetEmailSent => 'Password reset email sent! Check your inbox.';

  @override
  String get profile => 'Profile';

  @override
  String get logout => 'Log Out';

  @override
  String get logoutConfirmation =>
      'Are you sure you want to log out of MyMeds?';

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to permanently delete your account and all associated medication data? This action cannot be undone.';

  @override
  String get deleteAccountWarning =>
      'This will permanently remove your account and all your saved medication data from Firestore.';

  @override
  String get accountDeletedSuccess => 'Your account has been deleted.';

  @override
  String get errorEmailRequired => 'Please enter an email address';

  @override
  String get errorInvalidEmail => 'Please enter a valid email address';

  @override
  String get errorPasswordRequired => 'Please enter a password';

  @override
  String get errorPasswordTooShort => 'Password must be at least 6 characters';

  @override
  String get errorPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get errorAuthFailed => 'Authentication failed. Please try again.';

  @override
  String get errorUserNotFound => 'No account found with this email.';

  @override
  String get errorWrongPassword => 'Incorrect password. Please try again.';

  @override
  String get errorEmailAlreadyInUse =>
      'An account already exists with this email address.';

  @override
  String get errorInvalidCredential =>
      'The provided credentials are invalid or expired.';

  @override
  String get errorWeakPassword =>
      'The password is too weak. Please use a stronger password.';

  @override
  String get errorNetworkFailed =>
      'Network error. Please check your internet connection.';

  @override
  String get errorTooManyRequests =>
      'Too many failed attempts. Please try again later.';
}
