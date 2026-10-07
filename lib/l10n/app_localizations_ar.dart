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
  String get medicalDisclaimer =>
      'للأغراض المعلوماتية فقط. استشر أخصائي رعاية صحية.';

  @override
  String get cabinetEmpty => 'ستظهر خزانة الأدوية الخاصة بك هنا.';

  @override
  String get searchHint => 'ابحث عن الأدوية هنا.';

  @override
  String get remindersEmpty => 'ستظهر تذكيرات الأدوية الخاصة بك هنا.';

  @override
  String get dashboardEmpty => 'ستظهر لوحة القيادة الصحية الخاصة بك هنا.';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get about => 'حول';

  @override
  String get loginTitle => 'مرحبًا بك في أدويتي';

  @override
  String get loginSubtitle => 'سجّل الدخول لإدارة جدول أدويتك بأمان';

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
  String get forgotPassword => 'هل نسيت كلمة المرور؟';

  @override
  String get signInButton => 'تسجيل الدخول';

  @override
  String get signInWithGoogle => 'المتابعة باستخدام Google';

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
  String get registerTitle => 'إنشاء حساب جديد';

  @override
  String get registerSubtitle => 'ابدأ في تتبع أدويتك وتذكيراتك';

  @override
  String get registerButton => 'إنشاء الحساب';

  @override
  String get preferredLanguageLabel => 'اللغة المفضلة';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابطًا لإعادة تعيين كلمة المرور';

  @override
  String get sendResetLinkButton => 'إرسال رابط إعادة التعيين';

  @override
  String get backToLogin => 'العودة إلى تسجيل الدخول';

  @override
  String get resetEmailSent =>
      'تم إرسال رابط إعادة التعيين! تحقق من بريدك الإلكتروني.';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmation =>
      'هل أنت متأكد من رغبتك في تسجيل الخروج من أدويتي؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get deleteAccount => 'حذف الحساب';

  @override
  String get deleteAccountConfirmation =>
      'هل أنت متأكد من رغبتك في حذف حسابك وجميع بيانات أدويتك نهائيًا؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get deleteAccountWarning =>
      'سيؤدي هذا إلى حذف حسابك وجميع بياناتك المحفوظة في Firestore نهائيًا.';

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
  String get errorAuthFailed => 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.';

  @override
  String get errorUserNotFound => 'لا يوجد حساب مسجل بهذا البريد الإلكتروني.';

  @override
  String get errorWrongPassword =>
      'كلمة المرور غير صحيحة. يرجى المحاولة مرة أخرى.';

  @override
  String get errorEmailAlreadyInUse =>
      'يوجد حساب مسجل بهذا البريد الإلكتروني بالفعل.';

  @override
  String get errorInvalidCredential =>
      'بيانات الاعتماد المقدمة غير صالحة أو منتهية الصلاحية.';

  @override
  String get errorWeakPassword =>
      'كلمة المرور ضعيفة جدًا. يرجى اختيار كلمة مرور أقوى.';

  @override
  String get errorNetworkFailed =>
      'خطأ في الاتصال بالشبكة. يرجى التحقق من اتصال الإنترنت.';

  @override
  String get errorTooManyRequests =>
      'محاولات كثيرة غير ناجحة. يرجى المحاولة لاحقًا.';
}
