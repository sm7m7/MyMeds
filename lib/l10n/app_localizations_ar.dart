// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'أدويتي';

  @override
  String appVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get medicalDisclaimer =>
      'للأغراض المعلوماتية فقط. استشر أخصائي رعاية صحية.';

  @override
  String get consultDoctorOrPharmacist => 'استشر طبيبك أو الصيدلاني.';

  @override
  String get ok => 'حسناً';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get confirm => 'تأكيد';

  @override
  String get close => 'إغلاق';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get error => 'خطأ';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مرة أخرى.';

  @override
  String get noDataYet => 'لا توجد بيانات بعد.';

  @override
  String get tabCabinet => 'الخزانة';

  @override
  String get tabSearch => 'بحث';

  @override
  String get tabReminders => 'التذكيرات';

  @override
  String get tabDashboard => 'لوحة القيادة';

  @override
  String get tabMore => 'المزيد';

  @override
  String get loginTitle => 'مرحباً بك في أدويتي';

  @override
  String get loginSubtitle => 'سجّل دخولك لإدارة جدول أدويتك بأمان';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get confirmPasswordHint => 'أعد إدخال كلمة المرور';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get signInButton => 'تسجيل الدخول';

  @override
  String get signInWithGoogle => 'المتابعة بحساب Google';

  @override
  String get orDivider => 'أو';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get registerTitle => 'إنشاء حساب';

  @override
  String get registerSubtitle => 'ابدأ في متابعة أدويتك وتذكيراتك';

  @override
  String get registerButton => 'إنشاء الحساب';

  @override
  String get preferredLanguageLabel => 'اللغة المفضلة';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابط إعادة التعيين';

  @override
  String get sendResetLinkButton => 'إرسال رابط إعادة التعيين';

  @override
  String get backToLogin => 'العودة إلى تسجيل الدخول';

  @override
  String get resetEmailSent =>
      'تم إرسال بريد إعادة التعيين! تحقق من صندوق الوارد.';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmTitle => 'تسجيل الخروج';

  @override
  String get logoutConfirmation => 'هل أنت متأكد من تسجيل الخروج من أدويتي؟';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountTitle => 'حذف الحساب؟';

  @override
  String get deleteAccountConfirmation =>
      'هل أنت متأكد من حذف حسابك وجميع بياناتك الدوائية نهائياً؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deleteAccountWarning =>
      'سيؤدي هذا إلى حذف حسابك وجميع بياناتك المحفوظة في Firestore نهائياً.';

  @override
  String get deletePermanently => 'حذف نهائي';

  @override
  String get accountDeletedSuccess => 'تم حذف حسابك بنجاح.';

  @override
  String get errorEmailRequired => 'يرجى إدخال البريد الإلكتروني';

  @override
  String get errorInvalidEmail => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get errorPasswordRequired => 'يرجى إدخال كلمة المرور';

  @override
  String get errorPasswordTooShort =>
      'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';

  @override
  String get errorPasswordsDoNotMatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get errorAuthFailed => 'فشل المصادقة. يرجى المحاولة مرة أخرى.';

  @override
  String get errorUserNotFound =>
      'لم يتم العثور على حساب بهذا البريد الإلكتروني.';

  @override
  String get errorWrongPassword =>
      'كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى.';

  @override
  String get errorEmailAlreadyInUse =>
      'يوجد حساب بهذا البريد الإلكتروني بالفعل.';

  @override
  String get errorInvalidCredential =>
      'بيانات الاعتماد المقدمة غير صالحة أو منتهية الصلاحية.';

  @override
  String get errorWeakPassword =>
      'كلمة المرور ضعيفة جداً. يرجى استخدام كلمة مرور أقوى.';

  @override
  String get errorNetworkFailed =>
      'خطأ في الشبكة. يرجى التحقق من اتصالك بالإنترنت.';

  @override
  String get errorTooManyRequests =>
      'محاولات فاشلة كثيرة. يرجى المحاولة لاحقاً.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get settingsPreferences => 'التفضيلات';

  @override
  String get settingsAccount => 'الحساب';

  @override
  String get settingsStockThresholds => 'حدود المخزون والانتهاء';

  @override
  String get settingsAbout => 'حول';

  @override
  String get language => 'اللغة';

  @override
  String get languagePickerTitle => 'اختر اللغة';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'العربية';

  @override
  String get about => 'حول';

  @override
  String get notLoggedIn => 'غير مسجل';

  @override
  String get deleteFirestoreData => 'حذف المستخدم وبيانات Firestore نهائياً';

  @override
  String get expiringThresholdTitle => 'عتبة الانتهاء الوشيك';

  @override
  String expiringThresholdSubtitle(int days) {
    return 'تنبيه للأدوية التي تنتهي خلال $days يوم';
  }

  @override
  String get lowStockThresholdTitle => 'عتبة المخزون المنخفض';

  @override
  String lowStockThresholdSubtitle(int units) {
    return 'تنبيه عندما تبلغ الكمية $units وحدات أو أقل';
  }

  @override
  String get autoDecrementTitle => 'تقليل المخزون تلقائياً عند الجرعة';

  @override
  String get autoDecrementSubtitle =>
      'خصم وحدة واحدة تلقائياً عند تأكيد أخذ الجرعة';

  @override
  String get dailyAlertsTitle => 'تنبيهات المخزون والانتهاء اليومية';

  @override
  String get dailyAlertsSubtitle =>
      'استقبال إشعارات يومية تلخص العناصر التي تحتاج انتباهاً';

  @override
  String get days7 => '٧ أيام';

  @override
  String get days90 => '٩٠ يوماً';

  @override
  String get unit1 => 'وحدة واحدة';

  @override
  String get units20 => '٢٠ وحدة';

  @override
  String get cabinetTitle => 'الخزانة';

  @override
  String get cabinetEmpty => 'خزانة أدويتك فارغة.';

  @override
  String get cabinetEmptySubtitle => 'اضغط + لإضافة دوائك الأول.';

  @override
  String get cabinetAddMedication => 'إضافة دواء';

  @override
  String get cabinetAddFirst => 'أضف دواءك الأول';

  @override
  String get cabinetSearchHint => 'البحث في الأدوية…';

  @override
  String get cabinetFilterAll => 'الكل';

  @override
  String get cabinetFilterForm => 'تصفية حسب الشكل';

  @override
  String get cabinetFilterStatus => 'تصفية حسب الحالة';

  @override
  String cabinetTotalItems(int count) {
    return '$count عناصر';
  }

  @override
  String cabinetExpiredCount(int count) {
    return '$count منتهية الصلاحية';
  }

  @override
  String cabinetExpiringCount(int count) {
    return '$count على وشك الانتهاء';
  }

  @override
  String get medicationFormTitle => 'إضافة دواء';

  @override
  String get medicationEditTitle => 'تعديل الدواء';

  @override
  String get medicationName => 'اسم الدواء';

  @override
  String get medicationNameHint => 'مثال: أموكسيسيلين، أدفيل';

  @override
  String get medicationNameRequired => 'اسم الدواء مطلوب';

  @override
  String get medicationDosage => 'الجرعة / التركيز';

  @override
  String get medicationDosageHint => 'مثال: 500 مجم، 10 مل';

  @override
  String get medicationDosageRequired => 'الجرعة مطلوبة';

  @override
  String get medicationForm => 'الشكل الصيدلاني';

  @override
  String get medicationQuantity => 'الكمية في المخزون (وحدات)';

  @override
  String get medicationQuantityHint => 'مثال: 30';

  @override
  String get medicationQuantityRequired => 'الكمية مطلوبة';

  @override
  String get medicationQuantityInvalid => 'أدخل رقماً موجباً صالحاً';

  @override
  String get medicationExpirationDate => 'تاريخ الانتهاء';

  @override
  String get medicationStorage => 'ظروف التخزين (اختياري)';

  @override
  String get medicationStorageHint =>
      'مثال: يحفظ في مكان بارد وجاف، أقل من 25°م';

  @override
  String get medicationNotes => 'ملاحظات / تعليمات (اختياري)';

  @override
  String get medicationNotesHint => 'مثال: يؤخذ مع الطعام، بوصفة الدكتور أحمد';

  @override
  String get medicationSaveButton => 'إضافة إلى الخزانة';

  @override
  String get medicationUpdateButton => 'تحديث الدواء';

  @override
  String medicationAddedSuccess(String name) {
    return 'تمت إضافة $name إلى خزانتك!';
  }

  @override
  String medicationUpdatedSuccess(String name) {
    return 'تم تحديث $name بنجاح!';
  }

  @override
  String get medicationDeleteTitle => 'حذف الدواء؟';

  @override
  String medicationDeleteConfirm(String name) {
    return 'هل أنت متأكد من حذف $name من خزانتك؟ لا يمكن التراجع عن هذا الإجراء.';
  }

  @override
  String medicationDeleteSuccess(String name) {
    return 'تم حذف $name من خزانتك.';
  }

  @override
  String get statusOk => 'جيد';

  @override
  String get statusExpired => 'منتهي الصلاحية';

  @override
  String get statusExpiringSoon => 'قريب الانتهاء';

  @override
  String get statusLowStock => 'مخزون منخفض';

  @override
  String expiresOn(String date) {
    return 'ينتهي بتاريخ $date';
  }

  @override
  String expiresInDays(int days) {
    return 'ينتهي خلال $days يوم';
  }

  @override
  String expiredDaysAgo(int days) {
    return 'انتهى منذ $days يوم';
  }

  @override
  String stockUnitsRemaining(int units) {
    return '$units وحدات متبقية';
  }

  @override
  String get searchTitle => 'بحث';

  @override
  String get searchHint => 'البحث في الأدوية…';

  @override
  String get searchEmpty => 'ابحث عن دواء للبدء.';

  @override
  String searchNoResults(String query) {
    return 'لا نتائج لـ \"$query\"';
  }

  @override
  String searchResultsCount(int count) {
    return '$count نتيجة';
  }

  @override
  String get searchOffline =>
      'يبدو أنك غير متصل بالإنترنت. يتم عرض نتائج مؤقتة.';

  @override
  String get addToCabinet => 'إضافة إلى خزانتي';

  @override
  String get medicationDetailTitle => 'تفاصيل الدواء';

  @override
  String get medicationPurpose => 'الغرض / الدواعي';

  @override
  String get medicationDosageInfo => 'معلومات الجرعة';

  @override
  String get medicationStorageInfo => 'التخزين';

  @override
  String get medicationWarnings => 'التحذيرات';

  @override
  String get remindersTitle => 'التذكيرات';

  @override
  String get remindersEmpty => 'لا توجد تذكيرات بعد.';

  @override
  String get remindersEmptySubtitle => 'اضغط + لجدولة تذكير دواء.';

  @override
  String get reminderAddTitle => 'إضافة تذكير';

  @override
  String get reminderEditTitle => 'تعديل التذكير';

  @override
  String get reminderFrequencyLabel => 'التكرار';

  @override
  String get reminderFrequencyDaily => 'يومي';

  @override
  String reminderFrequencyEveryXHours(int hours) {
    return 'كل $hours ساعات';
  }

  @override
  String get reminderFrequencyWeekdays => 'أيام محددة من الأسبوع';

  @override
  String get reminderStartDate => 'تاريخ البدء';

  @override
  String get reminderDuration => 'المدة (أيام)';

  @override
  String get reminderActive => 'نشط';

  @override
  String get reminderTimes => 'أوقات التذكير';

  @override
  String get reminderMedicationLabel => 'اختر الدواء';

  @override
  String get reminderSaveSuccess => 'تم حفظ التذكير.';

  @override
  String get reminderDeleteConfirm => 'حذف هذا التذكير؟';

  @override
  String get reminderDeleteSuccess => 'تم حذف التذكير.';

  @override
  String get reminderTodayTitle => 'اليوم';

  @override
  String get reminderUpcoming => 'القادمة';

  @override
  String get reminderPast => 'المنتهية';

  @override
  String get doseActionTaken => 'تم الأخذ';

  @override
  String get doseActionSkip => 'تخطي';

  @override
  String get doseActionMissed => 'فُوِّتت';

  @override
  String get doseActionPending => 'معلقة';

  @override
  String get doseNoScheduleToday => 'لا توجد جرعات مجدولة لليوم.';

  @override
  String notificationDoseDue(String medication, String dosage) {
    return 'حان وقت تناول $medication ($dosage)';
  }

  @override
  String get notificationDoseDueTitle => 'موعد الجرعة';

  @override
  String get notificationStockAlertTitle => 'تنبيه حول أدويتك';

  @override
  String notificationStockAlertBody(int count) {
    return '$count دواء/أدوية تحتاج انتباهك.';
  }

  @override
  String notificationExpiredItem(String name) {
    return 'انتهت صلاحية $name.';
  }

  @override
  String notificationExpiringItem(String name) {
    return '$name على وشك الانتهاء.';
  }

  @override
  String notificationLowStockItem(String name, int units) {
    return 'مخزون $name منخفض ($units متبقية).';
  }

  @override
  String get dashboardTitle => 'لوحة القيادة';

  @override
  String get dashboardSubtitle => 'ملخص الصحة والأدوية';

  @override
  String get dashboardTotalItems => 'إجمالي العناصر';

  @override
  String get dashboardExpired => 'منتهية الصلاحية';

  @override
  String get dashboardExpiringSoon => 'قريبة الانتهاء';

  @override
  String get dashboardLowStock => 'مخزون منخفض';

  @override
  String get dashboardTodaySchedule => 'جدول أدوية اليوم';

  @override
  String get dashboardViewAll => 'عرض الكل';

  @override
  String get dashboardHistory => 'السجل';

  @override
  String get dashboardNoScheduleToday => 'لا توجد جرعات مجدولة لليوم.';

  @override
  String get adherenceTitle => 'الالتزام بالعلاج';

  @override
  String get adherenceOverview => 'نظرة عامة على الالتزام';

  @override
  String get adherencePeriodWeek => 'آخر 7 أيام';

  @override
  String get adherencePeriodMonth => 'آخر 30 يوماً';

  @override
  String get adherencePeriodWeekShort => 'أسبوع';

  @override
  String get adherencePeriodMonthShort => 'شهر';

  @override
  String get adherenceRate => 'معدل الالتزام';

  @override
  String get adherenceScheduled => 'مجدولة';

  @override
  String get adherenceTaken => 'مأخوذة';

  @override
  String get adherenceMissed => 'فائتة';

  @override
  String get adherenceSkipped => 'متخطاة';

  @override
  String get adherenceNoData => 'لا توجد جرعات مسجلة لهذه الفترة.';

  @override
  String get adherenceDailyActivity => 'نشاط الجرعات اليومي';

  @override
  String get adherenceMedicationBreakdown => 'التفصيل حسب الدواء';

  @override
  String get adherenceNoBreakdown => 'لا توجد بيانات التزام متاحة.';

  @override
  String get adherenceNoActivityDays => 'لا يوجد نشاط مسجل لهذه الأيام.';

  @override
  String adherenceDosesTaken(int taken, int scheduled) {
    return '$taken/$scheduled جرعة مأخوذة';
  }

  @override
  String adherenceMissedSkipped(int missed, int skipped) {
    return '$missed فائتة · $skipped متخطاة';
  }

  @override
  String get adherenceOutstanding => 'التزام استثنائي! 🌟';

  @override
  String get adherenceGreat => 'انتظام رائع! 👍';

  @override
  String get adherenceModerate => 'التزام متوسط ⚠️';

  @override
  String get adherenceLow => 'يحتاج تدخلاً — التزام منخفض 🚨';

  @override
  String adherenceSummaryDetail(int taken, int scheduled) {
    return '$taken من أصل $scheduled جرعة مجدولة مأخوذة في الوقت المناسب.';
  }

  @override
  String get doseHistoryTitle => 'سجل الجرعات';

  @override
  String get doseHistoryDays7 => '7 أيام';

  @override
  String get doseHistoryDays30 => '30 يوماً';

  @override
  String get doseHistoryAllMeds => 'كل الأدوية';

  @override
  String get doseHistoryAllStatuses => 'كل الحالات';

  @override
  String get doseHistoryEmpty => 'لا توجد سجلات';

  @override
  String get doseHistoryEmptySubtitle =>
      'جرب تعديل نطاق التاريخ أو خيارات التصفية.';

  @override
  String doseLoggedAt(String time) {
    return 'تم التسجيل في $time';
  }

  @override
  String get attentionNeededTitle => 'يحتاج انتباهاً';

  @override
  String get attentionNoItems => 'جميع أدويتك في حالة جيدة.';

  @override
  String get actionUpdateQuantity => 'تحديث الكمية';

  @override
  String get actionMarkDisposed => 'تمييز كمتخلص منه';

  @override
  String get interactionsTitle => 'التفاعلات الدوائية';

  @override
  String interactionsFound(int count) {
    return '$count موجودة';
  }

  @override
  String get interactionsConsultCTA =>
      'استشر دائماً طبيبك أو الصيدلاني قبل تغيير نظام أدويتك.';

  @override
  String get interactionsNoneFound => 'لم يتم اكتشاف أي تفاعلات';

  @override
  String interactionsNoneFoundFilter(String severity) {
    return 'لا توجد تفاعلات من مستوى $severity';
  }

  @override
  String get interactionsNoneFoundDetail =>
      'لم يتم العثور على أي تفاعلات معروفة بين أدويتك. تحقق دائماً مع الصيدلاني عند إضافة أدوية جديدة.';

  @override
  String interactionsMayInteract(String name) {
    return 'قد يتفاعل $name مع:';
  }

  @override
  String get interactionDetailTitle => 'تفاصيل التفاعل';

  @override
  String get interactionMedications => 'الأدوية المعنية';

  @override
  String get interactionWhatItMeans => 'ماذا يعني ذلك';

  @override
  String get interactionMechanism => 'الآلية الدوائية';

  @override
  String get interactionSaveAnyway => 'الحفظ على أي حال';

  @override
  String get interactionWarningTitle => 'تفاعلات دوائية محتملة';

  @override
  String get interactionConsultWarning =>
      'للأغراض المعلوماتية فقط. استشر طبيبك أو الصيدلاني قبل إجراء أي تغييرات على أدويتك.';

  @override
  String interactionActiveIngredients(String a, String b) {
    return 'المواد الفعالة: $a ↔ $b';
  }

  @override
  String interactionMechanismLabel(String mechanism) {
    return 'الآلية: $mechanism';
  }

  @override
  String get interactionSeverityMajor => 'خطير';

  @override
  String get interactionSeverityModerate => 'متوسط';

  @override
  String get interactionSeverityContraindicated => 'محظور';

  @override
  String get interactionNeverGiveDiagnosis =>
      'هذه المعلومات للتوعية فقط. لا تغير علاجك أبداً دون استشارة طبية.';

  @override
  String get interactionConsultCTATitle => 'استشر طبيبك أو الصيدلاني.';

  @override
  String get labelReaderTitle => 'مسح ملصق الدواء';

  @override
  String get labelReaderCapture => 'التقاط صورة';

  @override
  String get labelReaderGallery => 'اختيار من المعرض';

  @override
  String get labelReaderScanning => 'جارٍ المسح…';

  @override
  String get labelReaderAnalyzing => 'جارٍ التحليل بالذكاء الاصطناعي…';

  @override
  String get labelReaderConfirmTitle => 'تأكيد البيانات المستخرجة';

  @override
  String get labelReaderLowConfidence => 'ثقة منخفضة — يرجى التحقق';

  @override
  String get labelReaderNoText => 'لم يتم العثور على نص في الصورة.';

  @override
  String get labelReaderBlurry => 'الصورة قد تكون ضبابية. حاول مرة أخرى.';

  @override
  String get labelReaderFallback => 'لا يمكن قراءته؟ ابحث يدوياً.';

  @override
  String get labelReaderDisclaimer =>
      'يجب التحقق من البيانات المستخرجة قبل الحفظ.';

  @override
  String get labelReaderSaveToCalinet => 'حفظ في الخزانة';

  @override
  String get moreTitle => 'المزيد';

  @override
  String get moreInteractions => 'التفاعلات الدوائية';

  @override
  String get moreScan => 'مسح ملصق';

  @override
  String get searchHintText => 'ابحث عن الأدوية هنا.';

  @override
  String get remindersEmptyText => 'ستظهر تذكيرات الأدوية الخاصة بك هنا.';

  @override
  String get dashboardEmptyText => 'ستظهر لوحة القيادة الصحية الخاصة بك هنا.';

  @override
  String get uid => 'المعرّف';

  @override
  String get notAvailable => 'غير متاح';
}
