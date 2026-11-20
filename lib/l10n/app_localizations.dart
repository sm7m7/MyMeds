import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'MyMeds'**
  String get appTitle;

  /// Version string shown in About
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// Mandatory medical disclaimer
  ///
  /// In en, this message translates to:
  /// **'Informational only. Consult a healthcare professional.'**
  String get medicalDisclaimer;

  /// Drug interaction call-to-action
  ///
  /// In en, this message translates to:
  /// **'Consult a doctor or pharmacist.'**
  String get consultDoctorOrPharmacist;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @noDataYet.
  ///
  /// In en, this message translates to:
  /// **'No data yet.'**
  String get noDataYet;

  /// Bottom nav tab: Cabinet
  ///
  /// In en, this message translates to:
  /// **'Cabinet'**
  String get tabCabinet;

  /// Bottom nav tab: Appointments
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get tabSearch;

  /// Bottom nav tab: Reminders
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get tabReminders;

  /// Bottom nav tab: Dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get tabDashboard;

  /// Bottom nav tab: More
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tabMore;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to MyMeds'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to manage your medication schedule safely'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@example.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get confirmPasswordHint;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get orDivider;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start tracking your medications and reminders'**
  String get registerSubtitle;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerButton;

  /// No description provided for @preferredLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Preferred Language'**
  String get preferredLanguageLabel;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLinkButton;

  /// No description provided for @backToLogin.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToLogin;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent! Check your inbox.'**
  String get resetEmailSent;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of MyMeds?'**
  String get logoutConfirmation;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account and all associated medication data? This action cannot be undone.'**
  String get deleteAccountConfirmation;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove your account and all your saved medication data from Firestore.'**
  String get deleteAccountWarning;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// No description provided for @accountDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Your account has been deleted.'**
  String get accountDeletedSuccess;

  /// No description provided for @errorEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter an email address'**
  String get errorEmailRequired;

  /// No description provided for @errorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get errorInvalidEmail;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get errorPasswordRequired;

  /// No description provided for @errorPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get errorPasswordTooShort;

  /// No description provided for @errorPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordsDoNotMatch;

  /// No description provided for @errorAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get errorAuthFailed;

  /// No description provided for @errorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get errorUserNotFound;

  /// No description provided for @errorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get errorWrongPassword;

  /// No description provided for @errorEmailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with this email address.'**
  String get errorEmailAlreadyInUse;

  /// No description provided for @errorInvalidCredential.
  ///
  /// In en, this message translates to:
  /// **'The provided credentials are invalid or expired.'**
  String get errorInvalidCredential;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak. Please use a stronger password.'**
  String get errorWeakPassword;

  /// No description provided for @errorNetworkFailed.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your internet connection.'**
  String get errorNetworkFailed;

  /// No description provided for @errorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Please try again later.'**
  String get errorTooManyRequests;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settingsPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settingsPreferences;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsStockThresholds.
  ///
  /// In en, this message translates to:
  /// **'Stock & Expiration Thresholds'**
  String get settingsStockThresholds;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languagePickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get languagePickerTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageFrench.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @notLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'Not logged in'**
  String get notLoggedIn;

  /// No description provided for @deleteFirestoreData.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove user & Firestore data'**
  String get deleteFirestoreData;

  /// No description provided for @expiringThresholdTitle.
  ///
  /// In en, this message translates to:
  /// **'Expiring Soon Threshold'**
  String get expiringThresholdTitle;

  /// No description provided for @expiringThresholdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flag medications expiring within {days} days'**
  String expiringThresholdSubtitle(int days);

  /// No description provided for @lowStockThresholdTitle.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Threshold'**
  String get lowStockThresholdTitle;

  /// No description provided for @lowStockThresholdSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Flag when quantity is {units} units or fewer'**
  String lowStockThresholdSubtitle(int units);

  /// No description provided for @autoDecrementTitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-decrement stock on dose taken'**
  String get autoDecrementTitle;

  /// No description provided for @autoDecrementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Deduct 1 unit from cabinet inventory automatically when marking a dose Taken'**
  String get autoDecrementSubtitle;

  /// No description provided for @dailyAlertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily stock & expiry alerts'**
  String get dailyAlertsTitle;

  /// No description provided for @dailyAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive daily notifications summarizing items needing attention'**
  String get dailyAlertsSubtitle;

  /// No description provided for @days7.
  ///
  /// In en, this message translates to:
  /// **'7d'**
  String get days7;

  /// No description provided for @days90.
  ///
  /// In en, this message translates to:
  /// **'90d'**
  String get days90;

  /// No description provided for @unit1.
  ///
  /// In en, this message translates to:
  /// **'1 unit'**
  String get unit1;

  /// No description provided for @units20.
  ///
  /// In en, this message translates to:
  /// **'20 units'**
  String get units20;

  /// No description provided for @cabinetTitle.
  ///
  /// In en, this message translates to:
  /// **'Cabinet'**
  String get cabinetTitle;

  /// No description provided for @cabinetEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your medication cabinet is empty.'**
  String get cabinetEmpty;

  /// No description provided for @cabinetEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add your first medication.'**
  String get cabinetEmptySubtitle;

  /// No description provided for @cabinetAddMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get cabinetAddMedication;

  /// No description provided for @cabinetAddFirst.
  ///
  /// In en, this message translates to:
  /// **'Add your first medication'**
  String get cabinetAddFirst;

  /// No description provided for @cabinetSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search medications…'**
  String get cabinetSearchHint;

  /// No description provided for @cabinetFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get cabinetFilterAll;

  /// No description provided for @cabinetFilterForm.
  ///
  /// In en, this message translates to:
  /// **'Filter by form'**
  String get cabinetFilterForm;

  /// No description provided for @cabinetFilterStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by status'**
  String get cabinetFilterStatus;

  /// No description provided for @cabinetTotalItems.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String cabinetTotalItems(int count);

  /// No description provided for @cabinetExpiredCount.
  ///
  /// In en, this message translates to:
  /// **'{count} expired'**
  String cabinetExpiredCount(int count);

  /// No description provided for @cabinetExpiringCount.
  ///
  /// In en, this message translates to:
  /// **'{count} expiring'**
  String cabinetExpiringCount(int count);

  /// No description provided for @medicationFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get medicationFormTitle;

  /// No description provided for @medicationEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Medication'**
  String get medicationEditTitle;

  /// No description provided for @medicationName.
  ///
  /// In en, this message translates to:
  /// **'Medication Name'**
  String get medicationName;

  /// No description provided for @medicationNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Amoxicillin, Advil'**
  String get medicationNameHint;

  /// No description provided for @medicationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Medication name is required'**
  String get medicationNameRequired;

  /// No description provided for @medicationDosage.
  ///
  /// In en, this message translates to:
  /// **'Dosage / Strength'**
  String get medicationDosage;

  /// No description provided for @medicationDosageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 500 mg, 10 ml'**
  String get medicationDosageHint;

  /// No description provided for @medicationDosageRequired.
  ///
  /// In en, this message translates to:
  /// **'Dosage is required'**
  String get medicationDosageRequired;

  /// No description provided for @medicationForm.
  ///
  /// In en, this message translates to:
  /// **'Formulation Form'**
  String get medicationForm;

  /// No description provided for @medicationQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity in Stock (Units)'**
  String get medicationQuantity;

  /// No description provided for @medicationQuantityHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 30'**
  String get medicationQuantityHint;

  /// No description provided for @medicationQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity is required'**
  String get medicationQuantityRequired;

  /// No description provided for @medicationQuantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid positive number'**
  String get medicationQuantityInvalid;

  /// No description provided for @medicationExpirationDate.
  ///
  /// In en, this message translates to:
  /// **'Expiration Date'**
  String get medicationExpirationDate;

  /// No description provided for @medicationStorage.
  ///
  /// In en, this message translates to:
  /// **'Storage Conditions (Optional)'**
  String get medicationStorage;

  /// No description provided for @medicationStorageHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Store in a cool dry place, below 25°C'**
  String get medicationStorageHint;

  /// No description provided for @medicationNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes / Instructions (Optional)'**
  String get medicationNotes;

  /// No description provided for @medicationNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Take with food, prescribed by Dr. Smith'**
  String get medicationNotesHint;

  /// No description provided for @medicationSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Add to Medicine Cabinet'**
  String get medicationSaveButton;

  /// No description provided for @medicationUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Medication'**
  String get medicationUpdateButton;

  /// No description provided for @medicationAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} added to your cabinet!'**
  String medicationAddedSuccess(String name);

  /// No description provided for @medicationUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} updated successfully!'**
  String medicationUpdatedSuccess(String name);

  /// No description provided for @medicationDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Medication?'**
  String get medicationDeleteTitle;

  /// No description provided for @medicationDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove {name} from your cabinet? This action cannot be undone.'**
  String medicationDeleteConfirm(String name);

  /// No description provided for @medicationDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} removed from your cabinet.'**
  String medicationDeleteSuccess(String name);

  /// No description provided for @statusOk.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get statusOk;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring Soon'**
  String get statusExpiringSoon;

  /// No description provided for @statusLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get statusLowStock;

  /// No description provided for @expiresOn.
  ///
  /// In en, this message translates to:
  /// **'Expires {date}'**
  String expiresOn(String date);

  /// No description provided for @expiresInDays.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String expiresInDays(int days);

  /// No description provided for @expiredDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'Expired {days} days ago'**
  String expiredDaysAgo(int days);

  /// No description provided for @stockUnitsRemaining.
  ///
  /// In en, this message translates to:
  /// **'{units} units remaining'**
  String stockUnitsRemaining(int units);

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search medications…'**
  String get searchHint;

  /// No description provided for @searchEmpty.
  ///
  /// In en, this message translates to:
  /// **'Search for a medication to get started.'**
  String get searchEmpty;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String searchNoResults(String query);

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} results'**
  String searchResultsCount(int count);

  /// No description provided for @searchOffline.
  ///
  /// In en, this message translates to:
  /// **'You appear to be offline. Showing cached results.'**
  String get searchOffline;

  /// No description provided for @addToCabinet.
  ///
  /// In en, this message translates to:
  /// **'Add to My Cabinet'**
  String get addToCabinet;

  /// No description provided for @medicationDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication Detail'**
  String get medicationDetailTitle;

  /// No description provided for @medicationPurpose.
  ///
  /// In en, this message translates to:
  /// **'Purpose / Indication'**
  String get medicationPurpose;

  /// No description provided for @medicationDosageInfo.
  ///
  /// In en, this message translates to:
  /// **'Dosage Information'**
  String get medicationDosageInfo;

  /// No description provided for @medicationStorageInfo.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get medicationStorageInfo;

  /// No description provided for @medicationWarnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get medicationWarnings;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get remindersTitle;

  /// No description provided for @remindersEmpty.
  ///
  /// In en, this message translates to:
  /// **'No reminders yet.'**
  String get remindersEmpty;

  /// No description provided for @remindersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap + to schedule a medication reminder.'**
  String get remindersEmptySubtitle;

  /// No description provided for @reminderAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Reminder'**
  String get reminderAddTitle;

  /// No description provided for @reminderEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Reminder'**
  String get reminderEditTitle;

  /// No description provided for @reminderFrequencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get reminderFrequencyLabel;

  /// No description provided for @reminderFrequencyDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get reminderFrequencyDaily;

  /// No description provided for @reminderFrequencyEveryXHours.
  ///
  /// In en, this message translates to:
  /// **'Every {hours} hours'**
  String reminderFrequencyEveryXHours(int hours);

  /// No description provided for @reminderFrequencyWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Specific weekdays'**
  String get reminderFrequencyWeekdays;

  /// No description provided for @reminderStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get reminderStartDate;

  /// No description provided for @reminderDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration (days)'**
  String get reminderDuration;

  /// No description provided for @reminderActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get reminderActive;

  /// No description provided for @reminderTimes.
  ///
  /// In en, this message translates to:
  /// **'Reminder Times'**
  String get reminderTimes;

  /// No description provided for @reminderMedicationLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Medication'**
  String get reminderMedicationLabel;

  /// No description provided for @reminderSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reminder saved.'**
  String get reminderSaveSuccess;

  /// No description provided for @reminderDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this reminder?'**
  String get reminderDeleteConfirm;

  /// No description provided for @reminderDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Reminder deleted.'**
  String get reminderDeleteSuccess;

  /// No description provided for @reminderTodayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get reminderTodayTitle;

  /// No description provided for @reminderUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get reminderUpcoming;

  /// No description provided for @reminderPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get reminderPast;

  /// No description provided for @doseActionTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get doseActionTaken;

  /// No description provided for @doseActionSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get doseActionSkip;

  /// No description provided for @doseActionMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get doseActionMissed;

  /// No description provided for @doseActionPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get doseActionPending;

  /// No description provided for @doseNoScheduleToday.
  ///
  /// In en, this message translates to:
  /// **'No doses scheduled for today.'**
  String get doseNoScheduleToday;

  /// Push/local notification body for a due dose
  ///
  /// In en, this message translates to:
  /// **'Time to take {medication} ({dosage})'**
  String notificationDoseDue(String medication, String dosage);

  /// No description provided for @notificationDoseDueTitle.
  ///
  /// In en, this message translates to:
  /// **'Dose Due'**
  String get notificationDoseDueTitle;

  /// No description provided for @notificationStockAlertTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication Attention Needed'**
  String get notificationStockAlertTitle;

  /// No description provided for @notificationStockAlertBody.
  ///
  /// In en, this message translates to:
  /// **'{count} medication(s) need your attention.'**
  String notificationStockAlertBody(int count);

  /// No description provided for @notificationExpiredItem.
  ///
  /// In en, this message translates to:
  /// **'{name} has expired.'**
  String notificationExpiredItem(String name);

  /// No description provided for @notificationExpiringItem.
  ///
  /// In en, this message translates to:
  /// **'{name} expires soon.'**
  String notificationExpiringItem(String name);

  /// No description provided for @notificationLowStockItem.
  ///
  /// In en, this message translates to:
  /// **'{name} is running low ({units} left).'**
  String notificationLowStockItem(String name, int units);

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Health & Medication Summary'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardTotalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get dashboardTotalItems;

  /// No description provided for @dashboardExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get dashboardExpired;

  /// No description provided for @dashboardExpiringSoon.
  ///
  /// In en, this message translates to:
  /// **'Expiring Soon'**
  String get dashboardExpiringSoon;

  /// No description provided for @dashboardLowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get dashboardLowStock;

  /// No description provided for @dashboardTodaySchedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Medication Schedule'**
  String get dashboardTodaySchedule;

  /// No description provided for @dashboardViewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get dashboardViewAll;

  /// No description provided for @dashboardHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get dashboardHistory;

  /// No description provided for @dashboardNoScheduleToday.
  ///
  /// In en, this message translates to:
  /// **'No doses scheduled for today.'**
  String get dashboardNoScheduleToday;

  /// No description provided for @adherenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Adherence'**
  String get adherenceTitle;

  /// No description provided for @adherenceOverview.
  ///
  /// In en, this message translates to:
  /// **'Adherence Overview'**
  String get adherenceOverview;

  /// No description provided for @adherencePeriodWeek.
  ///
  /// In en, this message translates to:
  /// **'Last 7 Days'**
  String get adherencePeriodWeek;

  /// No description provided for @adherencePeriodMonth.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get adherencePeriodMonth;

  /// No description provided for @adherencePeriodWeekShort.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get adherencePeriodWeekShort;

  /// No description provided for @adherencePeriodMonthShort.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get adherencePeriodMonthShort;

  /// No description provided for @adherenceRate.
  ///
  /// In en, this message translates to:
  /// **'Adherence Rate'**
  String get adherenceRate;

  /// No description provided for @adherenceScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get adherenceScheduled;

  /// No description provided for @adherenceTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get adherenceTaken;

  /// No description provided for @adherenceMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get adherenceMissed;

  /// No description provided for @adherenceSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get adherenceSkipped;

  /// No description provided for @adherenceNoData.
  ///
  /// In en, this message translates to:
  /// **'No recorded doses for this period.'**
  String get adherenceNoData;

  /// No description provided for @adherenceDailyActivity.
  ///
  /// In en, this message translates to:
  /// **'Daily Intake Activity'**
  String get adherenceDailyActivity;

  /// No description provided for @adherenceMedicationBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Medication Breakdown'**
  String get adherenceMedicationBreakdown;

  /// No description provided for @adherenceNoBreakdown.
  ///
  /// In en, this message translates to:
  /// **'No medication adherence data available.'**
  String get adherenceNoBreakdown;

  /// No description provided for @adherenceNoActivityDays.
  ///
  /// In en, this message translates to:
  /// **'No dose activity logged for these days.'**
  String get adherenceNoActivityDays;

  /// No description provided for @adherenceDosesTaken.
  ///
  /// In en, this message translates to:
  /// **'{taken}/{scheduled} doses taken'**
  String adherenceDosesTaken(int taken, int scheduled);

  /// No description provided for @adherenceMissedSkipped.
  ///
  /// In en, this message translates to:
  /// **'{missed} missed · {skipped} skipped'**
  String adherenceMissedSkipped(int missed, int skipped);

  /// No description provided for @adherenceOutstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Adherence! 🌟'**
  String get adherenceOutstanding;

  /// No description provided for @adherenceGreat.
  ///
  /// In en, this message translates to:
  /// **'Great Consistency! 👍'**
  String get adherenceGreat;

  /// No description provided for @adherenceModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate Adherence ⚠️'**
  String get adherenceModerate;

  /// No description provided for @adherenceLow.
  ///
  /// In en, this message translates to:
  /// **'Action Needed — Low Adherence 🚨'**
  String get adherenceLow;

  /// No description provided for @adherenceSummaryDetail.
  ///
  /// In en, this message translates to:
  /// **'{taken} of {scheduled} scheduled doses taken on time.'**
  String adherenceSummaryDetail(int taken, int scheduled);

  /// No description provided for @doseHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Dose History'**
  String get doseHistoryTitle;

  /// No description provided for @doseHistoryDays7.
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get doseHistoryDays7;

  /// No description provided for @doseHistoryDays30.
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get doseHistoryDays30;

  /// No description provided for @doseHistoryAllMeds.
  ///
  /// In en, this message translates to:
  /// **'All Meds'**
  String get doseHistoryAllMeds;

  /// No description provided for @doseHistoryAllStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get doseHistoryAllStatuses;

  /// No description provided for @doseHistoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No dose records found'**
  String get doseHistoryEmpty;

  /// No description provided for @doseHistoryEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting the date range or filter options.'**
  String get doseHistoryEmptySubtitle;

  /// No description provided for @doseLoggedAt.
  ///
  /// In en, this message translates to:
  /// **'Logged at {time}'**
  String doseLoggedAt(String time);

  /// No description provided for @attentionNeededTitle.
  ///
  /// In en, this message translates to:
  /// **'Attention Needed'**
  String get attentionNeededTitle;

  /// No description provided for @attentionNoItems.
  ///
  /// In en, this message translates to:
  /// **'All medications are in good standing.'**
  String get attentionNoItems;

  /// No description provided for @actionUpdateQuantity.
  ///
  /// In en, this message translates to:
  /// **'Update Quantity'**
  String get actionUpdateQuantity;

  /// No description provided for @actionMarkDisposed.
  ///
  /// In en, this message translates to:
  /// **'Mark Disposed'**
  String get actionMarkDisposed;

  /// No description provided for @interactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Drug Interactions'**
  String get interactionsTitle;

  /// No description provided for @interactionsFound.
  ///
  /// In en, this message translates to:
  /// **'{count} found'**
  String interactionsFound(int count);

  /// No description provided for @interactionsConsultCTA.
  ///
  /// In en, this message translates to:
  /// **'Always consult a doctor or pharmacist before changing your medication regimen.'**
  String get interactionsConsultCTA;

  /// No description provided for @interactionsNoneFound.
  ///
  /// In en, this message translates to:
  /// **'No interactions detected'**
  String get interactionsNoneFound;

  /// No description provided for @interactionsNoneFoundFilter.
  ///
  /// In en, this message translates to:
  /// **'No {severity} interactions'**
  String interactionsNoneFoundFilter(String severity);

  /// No description provided for @interactionsNoneFoundDetail.
  ///
  /// In en, this message translates to:
  /// **'No known interactions were found among the medications in your cabinet. Always check with your pharmacist when adding new medications.'**
  String get interactionsNoneFoundDetail;

  /// No description provided for @interactionsMayInteract.
  ///
  /// In en, this message translates to:
  /// **'{name} may interact with:'**
  String interactionsMayInteract(String name);

  /// No description provided for @interactionDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Interaction Detail'**
  String get interactionDetailTitle;

  /// No description provided for @interactionMedications.
  ///
  /// In en, this message translates to:
  /// **'Medications Involved'**
  String get interactionMedications;

  /// No description provided for @interactionWhatItMeans.
  ///
  /// In en, this message translates to:
  /// **'What This Means'**
  String get interactionWhatItMeans;

  /// No description provided for @interactionMechanism.
  ///
  /// In en, this message translates to:
  /// **'Pharmacological Mechanism'**
  String get interactionMechanism;

  /// No description provided for @interactionSaveAnyway.
  ///
  /// In en, this message translates to:
  /// **'Save Anyway'**
  String get interactionSaveAnyway;

  /// No description provided for @interactionWarningTitle.
  ///
  /// In en, this message translates to:
  /// **'Possible Drug Interactions'**
  String get interactionWarningTitle;

  /// No description provided for @interactionConsultWarning.
  ///
  /// In en, this message translates to:
  /// **'Informational only. Consult a doctor or pharmacist before making any changes to your medications.'**
  String get interactionConsultWarning;

  /// No description provided for @interactionActiveIngredients.
  ///
  /// In en, this message translates to:
  /// **'Active ingredients: {a} ↔ {b}'**
  String interactionActiveIngredients(String a, String b);

  /// No description provided for @interactionMechanismLabel.
  ///
  /// In en, this message translates to:
  /// **'Mechanism: {mechanism}'**
  String interactionMechanismLabel(String mechanism);

  /// No description provided for @interactionSeverityMajor.
  ///
  /// In en, this message translates to:
  /// **'Major'**
  String get interactionSeverityMajor;

  /// No description provided for @interactionSeverityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get interactionSeverityModerate;

  /// No description provided for @interactionSeverityContraindicated.
  ///
  /// In en, this message translates to:
  /// **'Contraindicated'**
  String get interactionSeverityContraindicated;

  /// No description provided for @interactionNeverGiveDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'This information is for awareness only. Never stop, start, or change a medication without professional guidance.'**
  String get interactionNeverGiveDiagnosis;

  /// No description provided for @interactionConsultCTATitle.
  ///
  /// In en, this message translates to:
  /// **'Consult a doctor or pharmacist.'**
  String get interactionConsultCTATitle;

  /// No description provided for @labelReaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Medication Label'**
  String get labelReaderTitle;

  /// No description provided for @labelReaderCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture Photo'**
  String get labelReaderCapture;

  /// No description provided for @labelReaderGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get labelReaderGallery;

  /// No description provided for @labelReaderScanning.
  ///
  /// In en, this message translates to:
  /// **'Scanning…'**
  String get labelReaderScanning;

  /// No description provided for @labelReaderAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'Analysing with AI…'**
  String get labelReaderAnalyzing;

  /// No description provided for @labelReaderConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Extracted Data'**
  String get labelReaderConfirmTitle;

  /// No description provided for @labelReaderLowConfidence.
  ///
  /// In en, this message translates to:
  /// **'Low confidence — please verify'**
  String get labelReaderLowConfidence;

  /// No description provided for @labelReaderNoText.
  ///
  /// In en, this message translates to:
  /// **'No text found in image.'**
  String get labelReaderNoText;

  /// No description provided for @labelReaderBlurry.
  ///
  /// In en, this message translates to:
  /// **'Image may be blurry. Try capturing again.'**
  String get labelReaderBlurry;

  /// No description provided for @labelReaderFallback.
  ///
  /// In en, this message translates to:
  /// **'Can\'t read it? Search manually.'**
  String get labelReaderFallback;

  /// No description provided for @labelReaderDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Extracted data must be verified by you before saving.'**
  String get labelReaderDisclaimer;

  /// No description provided for @labelReaderSaveToCalinet.
  ///
  /// In en, this message translates to:
  /// **'Save to Cabinet'**
  String get labelReaderSaveToCalinet;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @moreInteractions.
  ///
  /// In en, this message translates to:
  /// **'Drug Interactions'**
  String get moreInteractions;

  /// No description provided for @moreScan.
  ///
  /// In en, this message translates to:
  /// **'Scan Label'**
  String get moreScan;

  /// No description provided for @searchHintText.
  ///
  /// In en, this message translates to:
  /// **'Search for medications here.'**
  String get searchHintText;

  /// No description provided for @remindersEmptyText.
  ///
  /// In en, this message translates to:
  /// **'Your medication reminders will appear here.'**
  String get remindersEmptyText;

  /// No description provided for @dashboardEmptyText.
  ///
  /// In en, this message translates to:
  /// **'Your health dashboard will appear here.'**
  String get dashboardEmptyText;

  /// No description provided for @uid.
  ///
  /// In en, this message translates to:
  /// **'UID'**
  String get uid;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get notAvailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
