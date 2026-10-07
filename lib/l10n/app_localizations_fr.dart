// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'MyMeds';

  @override
  String get tabCabinet => 'Armoire';

  @override
  String get tabSearch => 'Recherche';

  @override
  String get tabReminders => 'Rappels';

  @override
  String get tabDashboard => 'Tableau de bord';

  @override
  String get tabMore => 'Plus';

  @override
  String get medicalDisclaimer =>
      'À titre informatif uniquement. Consultez un professionnel de santé.';

  @override
  String get cabinetEmpty => 'Votre armoire à médicaments apparaîtra ici.';

  @override
  String get searchHint => 'Recherchez des médicaments ici.';

  @override
  String get remindersEmpty => 'Vos rappels de médicaments apparaîtront ici.';

  @override
  String get dashboardEmpty => 'Votre tableau de bord santé apparaîtra ici.';

  @override
  String get settings => 'Paramètres';

  @override
  String get language => 'Langue';

  @override
  String get about => 'À propos';

  @override
  String get loginTitle => 'Bienvenue sur MyMeds';

  @override
  String get loginSubtitle =>
      'Connectez-vous pour gérer votre traitement en toute sécurité';

  @override
  String get emailLabel => 'Adresse e-mail';

  @override
  String get emailHint => 'vous@exemple.com';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordHint => 'Entrez votre mot de passe';

  @override
  String get confirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get confirmPasswordHint => 'Retapez votre mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get signInButton => 'Se connecter';

  @override
  String get signInWithGoogle => 'Continuer avec Google';

  @override
  String get orDivider => 'OU';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get signUp => 'S\'inscrire';

  @override
  String get alreadyHaveAccount => 'Vous avez déjà un compte ?';

  @override
  String get logIn => 'Connexion';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get registerSubtitle =>
      'Commencez à suivre vos médicaments et rappels';

  @override
  String get registerButton => 'Créer mon compte';

  @override
  String get preferredLanguageLabel => 'Langue préférée';

  @override
  String get forgotPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get forgotPasswordSubtitle =>
      'Entrez votre e-mail pour recevoir le lien de réinitialisation';

  @override
  String get sendResetLinkButton => 'Envoyer le lien';

  @override
  String get backToLogin => 'Retour à la connexion';

  @override
  String get resetEmailSent =>
      'E-mail de réinitialisation envoyé ! Vérifiez votre boîte de réception.';

  @override
  String get profile => 'Profil';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get logoutConfirmation =>
      'Voulez-vous vraiment vous déconnecter de MyMeds ?';

  @override
  String get cancel => 'Annuler';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountConfirmation =>
      'Voulez-vous vraiment supprimer définitivement votre compte et toutes vos données médicales ? Cette action est irréversible.';

  @override
  String get deleteAccountWarning =>
      'Cette action supprimera définitivement votre compte et vos données sauvegardées dans Firestore.';

  @override
  String get accountDeletedSuccess =>
      'Votre compte a été supprimé avec succès.';

  @override
  String get errorEmailRequired => 'Veuillez entrer une adresse e-mail';

  @override
  String get errorInvalidEmail => 'Veuillez entrer une adresse e-mail valide';

  @override
  String get errorPasswordRequired => 'Veuillez entrer un mot de passe';

  @override
  String get errorPasswordTooShort =>
      'Le mot de passe doit comporter au moins 6 caractères';

  @override
  String get errorPasswordsDoNotMatch =>
      'Les mots de passe ne correspondent pas';

  @override
  String get errorAuthFailed =>
      'Échec de l\'authentification. Veuillez réessayer.';

  @override
  String get errorUserNotFound =>
      'Aucun compte associé à cette adresse e-mail.';

  @override
  String get errorWrongPassword =>
      'Mot de passe incorrect. Veuillez réessayer.';

  @override
  String get errorEmailAlreadyInUse =>
      'Un compte existe déjà avec cette adresse e-mail.';

  @override
  String get errorInvalidCredential =>
      'Les identifiants fournis sont invalides ou expirés.';

  @override
  String get errorWeakPassword =>
      'Le mot de passe est trop faible. Veuillez choisir un mot de passe plus fort.';

  @override
  String get errorNetworkFailed =>
      'Erreur réseau. Vérifiez votre connexion Internet.';

  @override
  String get errorTooManyRequests =>
      'Trop de tentatives infructueuses. Veuillez réessayer plus tard.';
}
