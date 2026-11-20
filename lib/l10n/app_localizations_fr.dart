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
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get medicalDisclaimer =>
      'À titre informatif uniquement. Consultez un professionnel de santé.';

  @override
  String get consultDoctorOrPharmacist =>
      'Consultez un médecin ou un pharmacien.';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get confirm => 'Confirmer';

  @override
  String get close => 'Fermer';

  @override
  String get retry => 'Réessayer';

  @override
  String get loading => 'Chargement…';

  @override
  String get error => 'Erreur';

  @override
  String get errorGeneric =>
      'Quelque chose s\'est mal passé. Veuillez réessayer.';

  @override
  String get noDataYet => 'Aucune donnée pour l\'instant.';

  @override
  String get tabCabinet => 'Armoire';

  @override
  String get tabSearch => 'Rendez-vous';

  @override
  String get tabReminders => 'Rappels';

  @override
  String get tabDashboard => 'Tableau de bord';

  @override
  String get tabMore => 'Plus';

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
  String get logoutConfirmTitle => 'Se déconnecter';

  @override
  String get logoutConfirmation =>
      'Voulez-vous vraiment vous déconnecter de MyMeds ?';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get deleteAccountTitle => 'Supprimer le compte ?';

  @override
  String get deleteAccountConfirmation =>
      'Voulez-vous vraiment supprimer définitivement votre compte et toutes vos données médicales ? Cette action est irréversible.';

  @override
  String get deleteAccountWarning =>
      'Cette action supprimera définitivement votre compte et vos données sauvegardées dans Firestore.';

  @override
  String get deletePermanently => 'Supprimer définitivement';

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

  @override
  String get settings => 'Paramètres';

  @override
  String get settingsPreferences => 'Préférences';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get settingsStockThresholds => 'Seuils de stock et d\'expiration';

  @override
  String get settingsAbout => 'À propos';

  @override
  String get language => 'Langue';

  @override
  String get languagePickerTitle => 'Choisir la langue';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageArabic => 'العربية';

  @override
  String get about => 'À propos';

  @override
  String get notLoggedIn => 'Non connecté';

  @override
  String get deleteFirestoreData =>
      'Supprimer définitivement l\'utilisateur et les données Firestore';

  @override
  String get expiringThresholdTitle => 'Seuil d\'expiration imminente';

  @override
  String expiringThresholdSubtitle(int days) {
    return 'Signaler les médicaments expirant dans $days jours';
  }

  @override
  String get lowStockThresholdTitle => 'Seuil de stock faible';

  @override
  String lowStockThresholdSubtitle(int units) {
    return 'Signaler quand la quantité est de $units unités ou moins';
  }

  @override
  String get autoDecrementTitle => 'Décrémenter le stock à la prise de dose';

  @override
  String get autoDecrementSubtitle =>
      'Déduire 1 unité automatiquement lors de la validation d\'une dose';

  @override
  String get dailyAlertsTitle =>
      'Alertes quotidiennes de stock et d\'expiration';

  @override
  String get dailyAlertsSubtitle =>
      'Recevoir des notifications quotidiennes résumant les éléments nécessitant attention';

  @override
  String get days7 => '7j';

  @override
  String get days90 => '90j';

  @override
  String get unit1 => '1 unité';

  @override
  String get units20 => '20 unités';

  @override
  String get cabinetTitle => 'Armoire';

  @override
  String get cabinetEmpty => 'Votre armoire à médicaments est vide.';

  @override
  String get cabinetEmptySubtitle =>
      'Appuyez sur + pour ajouter votre premier médicament.';

  @override
  String get cabinetAddMedication => 'Ajouter un médicament';

  @override
  String get cabinetAddFirst => 'Ajoutez votre premier médicament';

  @override
  String get cabinetSearchHint => 'Rechercher des médicaments…';

  @override
  String get cabinetFilterAll => 'Tous';

  @override
  String get cabinetFilterForm => 'Filtrer par forme';

  @override
  String get cabinetFilterStatus => 'Filtrer par statut';

  @override
  String cabinetTotalItems(int count) {
    return '$count éléments';
  }

  @override
  String cabinetExpiredCount(int count) {
    return '$count expirés';
  }

  @override
  String cabinetExpiringCount(int count) {
    return '$count bientôt expirés';
  }

  @override
  String get medicationFormTitle => 'Ajouter un médicament';

  @override
  String get medicationEditTitle => 'Modifier le médicament';

  @override
  String get medicationName => 'Nom du médicament';

  @override
  String get medicationNameHint => 'ex. Amoxicilline, Advil';

  @override
  String get medicationNameRequired => 'Le nom du médicament est requis';

  @override
  String get medicationDosage => 'Dosage / Concentration';

  @override
  String get medicationDosageHint => 'ex. 500 mg, 10 ml';

  @override
  String get medicationDosageRequired => 'Le dosage est requis';

  @override
  String get medicationForm => 'Forme pharmaceutique';

  @override
  String get medicationQuantity => 'Quantité en stock (unités)';

  @override
  String get medicationQuantityHint => 'ex. 30';

  @override
  String get medicationQuantityRequired => 'La quantité est requise';

  @override
  String get medicationQuantityInvalid => 'Entrez un nombre positif valide';

  @override
  String get medicationExpirationDate => 'Date d\'expiration';

  @override
  String get medicationStorage => 'Conditions de stockage (optionnel)';

  @override
  String get medicationStorageHint =>
      'ex. Conserver dans un endroit frais et sec, en dessous de 25°C';

  @override
  String get medicationNotes => 'Notes / Instructions (optionnel)';

  @override
  String get medicationNotesHint =>
      'ex. Prendre avec de la nourriture, prescrit par le Dr Dupont';

  @override
  String get medicationSaveButton => 'Ajouter à l\'armoire';

  @override
  String get medicationUpdateButton => 'Mettre à jour';

  @override
  String medicationAddedSuccess(String name) {
    return '$name ajouté à votre armoire !';
  }

  @override
  String medicationUpdatedSuccess(String name) {
    return '$name mis à jour avec succès !';
  }

  @override
  String get medicationDeleteTitle => 'Supprimer le médicament ?';

  @override
  String medicationDeleteConfirm(String name) {
    return 'Voulez-vous supprimer $name de votre armoire ? Cette action est irréversible.';
  }

  @override
  String medicationDeleteSuccess(String name) {
    return '$name retiré de votre armoire.';
  }

  @override
  String get statusOk => 'OK';

  @override
  String get statusExpired => 'Expiré';

  @override
  String get statusExpiringSoon => 'Bientôt expiré';

  @override
  String get statusLowStock => 'Stock faible';

  @override
  String expiresOn(String date) {
    return 'Expire le $date';
  }

  @override
  String expiresInDays(int days) {
    return 'Expire dans $days jours';
  }

  @override
  String expiredDaysAgo(int days) {
    return 'Expiré il y a $days jours';
  }

  @override
  String stockUnitsRemaining(int units) {
    return '$units unités restantes';
  }

  @override
  String get searchTitle => 'Recherche';

  @override
  String get searchHint => 'Rechercher des médicaments…';

  @override
  String get searchEmpty => 'Recherchez un médicament pour commencer.';

  @override
  String searchNoResults(String query) {
    return 'Aucun résultat pour « $query »';
  }

  @override
  String searchResultsCount(int count) {
    return '$count résultats';
  }

  @override
  String get searchOffline =>
      'Vous semblez hors ligne. Affichage des résultats en cache.';

  @override
  String get addToCabinet => 'Ajouter à mon armoire';

  @override
  String get medicationDetailTitle => 'Détail du médicament';

  @override
  String get medicationPurpose => 'Indication / Utilisation';

  @override
  String get medicationDosageInfo => 'Informations de dosage';

  @override
  String get medicationStorageInfo => 'Stockage';

  @override
  String get medicationWarnings => 'Mises en garde';

  @override
  String get remindersTitle => 'Rappels';

  @override
  String get remindersEmpty => 'Aucun rappel pour l\'instant.';

  @override
  String get remindersEmptySubtitle =>
      'Appuyez sur + pour planifier un rappel médicament.';

  @override
  String get reminderAddTitle => 'Ajouter un rappel';

  @override
  String get reminderEditTitle => 'Modifier le rappel';

  @override
  String get reminderFrequencyLabel => 'Fréquence';

  @override
  String get reminderFrequencyDaily => 'Quotidien';

  @override
  String reminderFrequencyEveryXHours(int hours) {
    return 'Toutes les $hours heures';
  }

  @override
  String get reminderFrequencyWeekdays => 'Jours spécifiques';

  @override
  String get reminderStartDate => 'Date de début';

  @override
  String get reminderDuration => 'Durée (jours)';

  @override
  String get reminderActive => 'Actif';

  @override
  String get reminderTimes => 'Heures de rappel';

  @override
  String get reminderMedicationLabel => 'Sélectionner un médicament';

  @override
  String get reminderSaveSuccess => 'Rappel enregistré.';

  @override
  String get reminderDeleteConfirm => 'Supprimer ce rappel ?';

  @override
  String get reminderDeleteSuccess => 'Rappel supprimé.';

  @override
  String get reminderTodayTitle => 'Aujourd\'hui';

  @override
  String get reminderUpcoming => 'À venir';

  @override
  String get reminderPast => 'Passé';

  @override
  String get doseActionTaken => 'Pris';

  @override
  String get doseActionSkip => 'Ignorer';

  @override
  String get doseActionMissed => 'Manqué';

  @override
  String get doseActionPending => 'En attente';

  @override
  String get doseNoScheduleToday => 'Aucune dose planifiée pour aujourd\'hui.';

  @override
  String notificationDoseDue(String medication, String dosage) {
    return 'Heure de prendre $medication ($dosage)';
  }

  @override
  String get notificationDoseDueTitle => 'Dose à prendre';

  @override
  String get notificationStockAlertTitle =>
      'Attention requise pour vos médicaments';

  @override
  String notificationStockAlertBody(int count) {
    return '$count médicament(s) nécessitent votre attention.';
  }

  @override
  String notificationExpiredItem(String name) {
    return '$name a expiré.';
  }

  @override
  String notificationExpiringItem(String name) {
    return '$name expire bientôt.';
  }

  @override
  String notificationLowStockItem(String name, int units) {
    return '$name est presque épuisé ($units restants).';
  }

  @override
  String get dashboardTitle => 'Tableau de bord';

  @override
  String get dashboardSubtitle => 'Récapitulatif santé et médicaments';

  @override
  String get dashboardTotalItems => 'Total';

  @override
  String get dashboardExpired => 'Expirés';

  @override
  String get dashboardExpiringSoon => 'Bientôt expirés';

  @override
  String get dashboardLowStock => 'Stock faible';

  @override
  String get dashboardTodaySchedule => 'Programme médicaments du jour';

  @override
  String get dashboardViewAll => 'Tout voir';

  @override
  String get dashboardHistory => 'Historique';

  @override
  String get dashboardNoScheduleToday =>
      'Aucune dose planifiée pour aujourd\'hui.';

  @override
  String get adherenceTitle => 'Observance';

  @override
  String get adherenceOverview => 'Vue d\'ensemble de l\'observance';

  @override
  String get adherencePeriodWeek => '7 derniers jours';

  @override
  String get adherencePeriodMonth => '30 derniers jours';

  @override
  String get adherencePeriodWeekShort => 'Semaine';

  @override
  String get adherencePeriodMonthShort => 'Mois';

  @override
  String get adherenceRate => 'Taux d\'observance';

  @override
  String get adherenceScheduled => 'Planifiées';

  @override
  String get adherenceTaken => 'Prises';

  @override
  String get adherenceMissed => 'Manquées';

  @override
  String get adherenceSkipped => 'Ignorées';

  @override
  String get adherenceNoData => 'Aucune dose enregistrée pour cette période.';

  @override
  String get adherenceDailyActivity => 'Activité quotidienne de prise';

  @override
  String get adherenceMedicationBreakdown => 'Détail par médicament';

  @override
  String get adherenceNoBreakdown => 'Aucune donnée d\'observance disponible.';

  @override
  String get adherenceNoActivityDays =>
      'Aucune activité enregistrée pour ces jours.';

  @override
  String adherenceDosesTaken(int taken, int scheduled) {
    return '$taken/$scheduled doses prises';
  }

  @override
  String adherenceMissedSkipped(int missed, int skipped) {
    return '$missed manquées · $skipped ignorées';
  }

  @override
  String get adherenceOutstanding => 'Observance exemplaire ! 🌟';

  @override
  String get adherenceGreat => 'Très bonne régularité ! 👍';

  @override
  String get adherenceModerate => 'Observance modérée ⚠️';

  @override
  String get adherenceLow => 'Action requise — Observance faible 🚨';

  @override
  String adherenceSummaryDetail(int taken, int scheduled) {
    return '$taken sur $scheduled doses planifiées prises à temps.';
  }

  @override
  String get doseHistoryTitle => 'Historique des doses';

  @override
  String get doseHistoryDays7 => '7 jours';

  @override
  String get doseHistoryDays30 => '30 jours';

  @override
  String get doseHistoryAllMeds => 'Tous les médicaments';

  @override
  String get doseHistoryAllStatuses => 'Tous les statuts';

  @override
  String get doseHistoryEmpty => 'Aucun enregistrement trouvé';

  @override
  String get doseHistoryEmptySubtitle =>
      'Essayez de modifier la plage de dates ou les filtres.';

  @override
  String doseLoggedAt(String time) {
    return 'Prise enregistrée à $time';
  }

  @override
  String get attentionNeededTitle => 'Attention requise';

  @override
  String get attentionNoItems => 'Tous vos médicaments sont en bon état.';

  @override
  String get actionUpdateQuantity => 'Mettre à jour la quantité';

  @override
  String get actionMarkDisposed => 'Marquer comme éliminé';

  @override
  String get interactionsTitle => 'Interactions médicamenteuses';

  @override
  String interactionsFound(int count) {
    return '$count trouvées';
  }

  @override
  String get interactionsConsultCTA =>
      'Consultez toujours un médecin ou un pharmacien avant de modifier votre traitement.';

  @override
  String get interactionsNoneFound => 'Aucune interaction détectée';

  @override
  String interactionsNoneFoundFilter(String severity) {
    return 'Aucune interaction de niveau $severity';
  }

  @override
  String get interactionsNoneFoundDetail =>
      'Bonne nouvelle ! Aucune interaction connue n\'a été détectée parmi vos médicaments. Vérifiez toujours avec votre pharmacien lors de l\'ajout de nouveaux médicaments.';

  @override
  String interactionsMayInteract(String name) {
    return '$name pourrait interagir avec :';
  }

  @override
  String get interactionDetailTitle => 'Détail de l\'interaction';

  @override
  String get interactionMedications => 'Médicaments concernés';

  @override
  String get interactionWhatItMeans => 'Ce que cela signifie';

  @override
  String get interactionMechanism => 'Mécanisme pharmacologique';

  @override
  String get interactionSaveAnyway => 'Enregistrer quand même';

  @override
  String get interactionWarningTitle =>
      'Interactions médicamenteuses possibles';

  @override
  String get interactionConsultWarning =>
      'À titre informatif uniquement. Consultez un médecin ou un pharmacien avant toute modification de votre traitement.';

  @override
  String interactionActiveIngredients(String a, String b) {
    return 'Principes actifs : $a ↔ $b';
  }

  @override
  String interactionMechanismLabel(String mechanism) {
    return 'Mécanisme : $mechanism';
  }

  @override
  String get interactionSeverityMajor => 'Majeure';

  @override
  String get interactionSeverityModerate => 'Modérée';

  @override
  String get interactionSeverityContraindicated => 'Contre-indiquée';

  @override
  String get interactionNeverGiveDiagnosis =>
      'Ces informations sont données à titre indicatif uniquement. Ne modifiez jamais votre traitement sans avis médical.';

  @override
  String get interactionConsultCTATitle =>
      'Consultez un médecin ou un pharmacien.';

  @override
  String get labelReaderTitle => 'Scanner l\'étiquette';

  @override
  String get labelReaderCapture => 'Prendre une photo';

  @override
  String get labelReaderGallery => 'Choisir dans la galerie';

  @override
  String get labelReaderScanning => 'Analyse OCR…';

  @override
  String get labelReaderAnalyzing => 'Analyse IA en cours…';

  @override
  String get labelReaderConfirmTitle => 'Confirmer les données extraites';

  @override
  String get labelReaderLowConfidence =>
      'Faible confiance — vérifiez les données';

  @override
  String get labelReaderNoText => 'Aucun texte trouvé dans l\'image.';

  @override
  String get labelReaderBlurry => 'L\'image est peut-être floue. Réessayez.';

  @override
  String get labelReaderFallback =>
      'Impossible de lire ? Recherchez manuellement.';

  @override
  String get labelReaderDisclaimer =>
      'Les données extraites doivent être vérifiées avant l\'enregistrement.';

  @override
  String get labelReaderSaveToCalinet => 'Enregistrer dans l\'armoire';

  @override
  String get moreTitle => 'Plus';

  @override
  String get moreInteractions => 'Interactions médicamenteuses';

  @override
  String get moreScan => 'Scanner une étiquette';

  @override
  String get searchHintText => 'Recherchez des médicaments ici.';

  @override
  String get remindersEmptyText =>
      'Vos rappels de médicaments apparaîtront ici.';

  @override
  String get dashboardEmptyText =>
      'Votre tableau de bord santé apparaîtra ici.';

  @override
  String get uid => 'UID';

  @override
  String get notAvailable => 'N/D';
}
