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
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get medicalDisclaimer =>
      'Informational only. Consult a healthcare professional.';

  @override
  String get consultDoctorOrPharmacist => 'Consult a doctor or pharmacist.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get confirm => 'Confirm';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading…';

  @override
  String get error => 'Error';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get noDataYet => 'No data yet.';

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
  String get logoutConfirmTitle => 'Log Out';

  @override
  String get logoutConfirmation =>
      'Are you sure you want to log out of MyMeds?';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountTitle => 'Delete Account?';

  @override
  String get deleteAccountConfirmation =>
      'Are you sure you want to permanently delete your account and all associated medication data? This action cannot be undone.';

  @override
  String get deleteAccountWarning =>
      'This will permanently remove your account and all your saved medication data from Firestore.';

  @override
  String get deletePermanently => 'Delete Permanently';

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

  @override
  String get settings => 'Settings';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsStockThresholds => 'Stock & Expiration Thresholds';

  @override
  String get settingsAbout => 'About';

  @override
  String get language => 'Language';

  @override
  String get languagePickerTitle => 'Choose Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'العربية';

  @override
  String get about => 'About';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get deleteFirestoreData => 'Permanently remove user & Firestore data';

  @override
  String get expiringThresholdTitle => 'Expiring Soon Threshold';

  @override
  String expiringThresholdSubtitle(int days) {
    return 'Flag medications expiring within $days days';
  }

  @override
  String get lowStockThresholdTitle => 'Low Stock Threshold';

  @override
  String lowStockThresholdSubtitle(int units) {
    return 'Flag when quantity is $units units or fewer';
  }

  @override
  String get autoDecrementTitle => 'Auto-decrement stock on dose taken';

  @override
  String get autoDecrementSubtitle =>
      'Deduct 1 unit from cabinet inventory automatically when marking a dose Taken';

  @override
  String get dailyAlertsTitle => 'Daily stock & expiry alerts';

  @override
  String get dailyAlertsSubtitle =>
      'Receive daily notifications summarizing items needing attention';

  @override
  String get days7 => '7d';

  @override
  String get days90 => '90d';

  @override
  String get unit1 => '1 unit';

  @override
  String get units20 => '20 units';

  @override
  String get cabinetTitle => 'Cabinet';

  @override
  String get cabinetEmpty => 'Your medication cabinet is empty.';

  @override
  String get cabinetEmptySubtitle => 'Tap + to add your first medication.';

  @override
  String get cabinetAddMedication => 'Add Medication';

  @override
  String get cabinetAddFirst => 'Add your first medication';

  @override
  String get cabinetSearchHint => 'Search medications…';

  @override
  String get cabinetFilterAll => 'All';

  @override
  String get cabinetFilterForm => 'Filter by form';

  @override
  String get cabinetFilterStatus => 'Filter by status';

  @override
  String cabinetTotalItems(int count) {
    return '$count items';
  }

  @override
  String cabinetExpiredCount(int count) {
    return '$count expired';
  }

  @override
  String cabinetExpiringCount(int count) {
    return '$count expiring';
  }

  @override
  String get medicationFormTitle => 'Add Medication';

  @override
  String get medicationEditTitle => 'Edit Medication';

  @override
  String get medicationName => 'Medication Name';

  @override
  String get medicationNameHint => 'e.g. Amoxicillin, Advil';

  @override
  String get medicationNameRequired => 'Medication name is required';

  @override
  String get medicationDosage => 'Dosage / Strength';

  @override
  String get medicationDosageHint => 'e.g. 500 mg, 10 ml';

  @override
  String get medicationDosageRequired => 'Dosage is required';

  @override
  String get medicationForm => 'Formulation Form';

  @override
  String get medicationQuantity => 'Quantity in Stock (Units)';

  @override
  String get medicationQuantityHint => 'e.g. 30';

  @override
  String get medicationQuantityRequired => 'Quantity is required';

  @override
  String get medicationQuantityInvalid => 'Enter a valid positive number';

  @override
  String get medicationExpirationDate => 'Expiration Date';

  @override
  String get medicationStorage => 'Storage Conditions (Optional)';

  @override
  String get medicationStorageHint =>
      'e.g. Store in a cool dry place, below 25°C';

  @override
  String get medicationNotes => 'Notes / Instructions (Optional)';

  @override
  String get medicationNotesHint =>
      'e.g. Take with food, prescribed by Dr. Smith';

  @override
  String get medicationSaveButton => 'Add to Medicine Cabinet';

  @override
  String get medicationUpdateButton => 'Update Medication';

  @override
  String medicationAddedSuccess(String name) {
    return '$name added to your cabinet!';
  }

  @override
  String medicationUpdatedSuccess(String name) {
    return '$name updated successfully!';
  }

  @override
  String get medicationDeleteTitle => 'Delete Medication?';

  @override
  String medicationDeleteConfirm(String name) {
    return 'Are you sure you want to remove $name from your cabinet? This action cannot be undone.';
  }

  @override
  String medicationDeleteSuccess(String name) {
    return '$name removed from your cabinet.';
  }

  @override
  String get statusOk => 'OK';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusExpiringSoon => 'Expiring Soon';

  @override
  String get statusLowStock => 'Low Stock';

  @override
  String expiresOn(String date) {
    return 'Expires $date';
  }

  @override
  String expiresInDays(int days) {
    return 'Expires in $days days';
  }

  @override
  String expiredDaysAgo(int days) {
    return 'Expired $days days ago';
  }

  @override
  String stockUnitsRemaining(int units) {
    return '$units units remaining';
  }

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search medications…';

  @override
  String get searchEmpty => 'Search for a medication to get started.';

  @override
  String searchNoResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String searchResultsCount(int count) {
    return '$count results';
  }

  @override
  String get searchOffline =>
      'You appear to be offline. Showing cached results.';

  @override
  String get addToCabinet => 'Add to My Cabinet';

  @override
  String get medicationDetailTitle => 'Medication Detail';

  @override
  String get medicationPurpose => 'Purpose / Indication';

  @override
  String get medicationDosageInfo => 'Dosage Information';

  @override
  String get medicationStorageInfo => 'Storage';

  @override
  String get medicationWarnings => 'Warnings';

  @override
  String get remindersTitle => 'Reminders';

  @override
  String get remindersEmpty => 'No reminders yet.';

  @override
  String get remindersEmptySubtitle =>
      'Tap + to schedule a medication reminder.';

  @override
  String get reminderAddTitle => 'Add Reminder';

  @override
  String get reminderEditTitle => 'Edit Reminder';

  @override
  String get reminderFrequencyLabel => 'Frequency';

  @override
  String get reminderFrequencyDaily => 'Daily';

  @override
  String reminderFrequencyEveryXHours(int hours) {
    return 'Every $hours hours';
  }

  @override
  String get reminderFrequencyWeekdays => 'Specific weekdays';

  @override
  String get reminderStartDate => 'Start Date';

  @override
  String get reminderDuration => 'Duration (days)';

  @override
  String get reminderActive => 'Active';

  @override
  String get reminderTimes => 'Reminder Times';

  @override
  String get reminderMedicationLabel => 'Select Medication';

  @override
  String get reminderSaveSuccess => 'Reminder saved.';

  @override
  String get reminderDeleteConfirm => 'Delete this reminder?';

  @override
  String get reminderDeleteSuccess => 'Reminder deleted.';

  @override
  String get reminderTodayTitle => 'Today';

  @override
  String get reminderUpcoming => 'Upcoming';

  @override
  String get reminderPast => 'Past';

  @override
  String get doseActionTaken => 'Taken';

  @override
  String get doseActionSkip => 'Skip';

  @override
  String get doseActionMissed => 'Missed';

  @override
  String get doseActionPending => 'Pending';

  @override
  String get doseNoScheduleToday => 'No doses scheduled for today.';

  @override
  String notificationDoseDue(String medication, String dosage) {
    return 'Time to take $medication ($dosage)';
  }

  @override
  String get notificationDoseDueTitle => 'Dose Due';

  @override
  String get notificationStockAlertTitle => 'Medication Attention Needed';

  @override
  String notificationStockAlertBody(int count) {
    return '$count medication(s) need your attention.';
  }

  @override
  String notificationExpiredItem(String name) {
    return '$name has expired.';
  }

  @override
  String notificationExpiringItem(String name) {
    return '$name expires soon.';
  }

  @override
  String notificationLowStockItem(String name, int units) {
    return '$name is running low ($units left).';
  }

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardSubtitle => 'Health & Medication Summary';

  @override
  String get dashboardTotalItems => 'Total Items';

  @override
  String get dashboardExpired => 'Expired';

  @override
  String get dashboardExpiringSoon => 'Expiring Soon';

  @override
  String get dashboardLowStock => 'Low Stock';

  @override
  String get dashboardTodaySchedule => 'Today\'s Medication Schedule';

  @override
  String get dashboardViewAll => 'View All';

  @override
  String get dashboardHistory => 'History';

  @override
  String get dashboardNoScheduleToday => 'No doses scheduled for today.';

  @override
  String get adherenceTitle => 'Adherence';

  @override
  String get adherenceOverview => 'Adherence Overview';

  @override
  String get adherencePeriodWeek => 'Last 7 Days';

  @override
  String get adherencePeriodMonth => 'Last 30 Days';

  @override
  String get adherencePeriodWeekShort => 'Week';

  @override
  String get adherencePeriodMonthShort => 'Month';

  @override
  String get adherenceRate => 'Adherence Rate';

  @override
  String get adherenceScheduled => 'Scheduled';

  @override
  String get adherenceTaken => 'Taken';

  @override
  String get adherenceMissed => 'Missed';

  @override
  String get adherenceSkipped => 'Skipped';

  @override
  String get adherenceNoData => 'No recorded doses for this period.';

  @override
  String get adherenceDailyActivity => 'Daily Intake Activity';

  @override
  String get adherenceMedicationBreakdown => 'Medication Breakdown';

  @override
  String get adherenceNoBreakdown => 'No medication adherence data available.';

  @override
  String get adherenceNoActivityDays =>
      'No dose activity logged for these days.';

  @override
  String adherenceDosesTaken(int taken, int scheduled) {
    return '$taken/$scheduled doses taken';
  }

  @override
  String adherenceMissedSkipped(int missed, int skipped) {
    return '$missed missed · $skipped skipped';
  }

  @override
  String get adherenceOutstanding => 'Outstanding Adherence! 🌟';

  @override
  String get adherenceGreat => 'Great Consistency! 👍';

  @override
  String get adherenceModerate => 'Moderate Adherence ⚠️';

  @override
  String get adherenceLow => 'Action Needed — Low Adherence 🚨';

  @override
  String adherenceSummaryDetail(int taken, int scheduled) {
    return '$taken of $scheduled scheduled doses taken on time.';
  }

  @override
  String get doseHistoryTitle => 'Dose History';

  @override
  String get doseHistoryDays7 => '7 Days';

  @override
  String get doseHistoryDays30 => '30 Days';

  @override
  String get doseHistoryAllMeds => 'All Meds';

  @override
  String get doseHistoryAllStatuses => 'All Statuses';

  @override
  String get doseHistoryEmpty => 'No dose records found';

  @override
  String get doseHistoryEmptySubtitle =>
      'Try adjusting the date range or filter options.';

  @override
  String doseLoggedAt(String time) {
    return 'Logged at $time';
  }

  @override
  String get attentionNeededTitle => 'Attention Needed';

  @override
  String get attentionNoItems => 'All medications are in good standing.';

  @override
  String get actionUpdateQuantity => 'Update Quantity';

  @override
  String get actionMarkDisposed => 'Mark Disposed';

  @override
  String get interactionsTitle => 'Drug Interactions';

  @override
  String interactionsFound(int count) {
    return '$count found';
  }

  @override
  String get interactionsConsultCTA =>
      'Always consult a doctor or pharmacist before changing your medication regimen.';

  @override
  String get interactionsNoneFound => 'No interactions detected';

  @override
  String interactionsNoneFoundFilter(String severity) {
    return 'No $severity interactions';
  }

  @override
  String get interactionsNoneFoundDetail =>
      'No known interactions were found among the medications in your cabinet. Always check with your pharmacist when adding new medications.';

  @override
  String interactionsMayInteract(String name) {
    return '$name may interact with:';
  }

  @override
  String get interactionDetailTitle => 'Interaction Detail';

  @override
  String get interactionMedications => 'Medications Involved';

  @override
  String get interactionWhatItMeans => 'What This Means';

  @override
  String get interactionMechanism => 'Pharmacological Mechanism';

  @override
  String get interactionSaveAnyway => 'Save Anyway';

  @override
  String get interactionWarningTitle => 'Possible Drug Interactions';

  @override
  String get interactionConsultWarning =>
      'Informational only. Consult a doctor or pharmacist before making any changes to your medications.';

  @override
  String interactionActiveIngredients(String a, String b) {
    return 'Active ingredients: $a ↔ $b';
  }

  @override
  String interactionMechanismLabel(String mechanism) {
    return 'Mechanism: $mechanism';
  }

  @override
  String get interactionSeverityMajor => 'Major';

  @override
  String get interactionSeverityModerate => 'Moderate';

  @override
  String get interactionSeverityContraindicated => 'Contraindicated';

  @override
  String get interactionNeverGiveDiagnosis =>
      'This information is for awareness only. Never stop, start, or change a medication without professional guidance.';

  @override
  String get interactionConsultCTATitle => 'Consult a doctor or pharmacist.';

  @override
  String get labelReaderTitle => 'Scan Medication Label';

  @override
  String get labelReaderCapture => 'Capture Photo';

  @override
  String get labelReaderGallery => 'Choose from Gallery';

  @override
  String get labelReaderScanning => 'Scanning…';

  @override
  String get labelReaderAnalyzing => 'Analysing with AI…';

  @override
  String get labelReaderConfirmTitle => 'Confirm Extracted Data';

  @override
  String get labelReaderLowConfidence => 'Low confidence — please verify';

  @override
  String get labelReaderNoText => 'No text found in image.';

  @override
  String get labelReaderBlurry => 'Image may be blurry. Try capturing again.';

  @override
  String get labelReaderFallback => 'Can\'t read it? Search manually.';

  @override
  String get labelReaderDisclaimer =>
      'Extracted data must be verified by you before saving.';

  @override
  String get labelReaderSaveToCalinet => 'Save to Cabinet';

  @override
  String get moreTitle => 'More';

  @override
  String get moreInteractions => 'Drug Interactions';

  @override
  String get moreScan => 'Scan Label';

  @override
  String get searchHintText => 'Search for medications here.';

  @override
  String get remindersEmptyText =>
      'Your medication reminders will appear here.';

  @override
  String get dashboardEmptyText => 'Your health dashboard will appear here.';

  @override
  String get uid => 'UID';

  @override
  String get notAvailable => 'N/A';
}
