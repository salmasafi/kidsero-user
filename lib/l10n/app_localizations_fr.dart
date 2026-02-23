// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get welcome => 'Bienvenue chez Kidsero';

  @override
  String get selectRole => 'Veuillez sélectionner votre rôle pour continuer';

  @override
  String get imParent => 'Je suis un parent';

  @override
  String get imDriver => 'Je suis un chauffeur';

  @override
  String get parentLogin => 'Connexion';

  @override
  String get driverLogin => 'Connexion Chauffeur';

  @override
  String get enterCredentials =>
      'Entrez vos identifiants pour accéder à votre compte';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get emailOrPhone => 'Email/Numéro de téléphone';

  @override
  String get password => 'Mot de passe';

  @override
  String get login => 'Se connecter';

  @override
  String get loginSuccessful => 'Connexion réussie';

  @override
  String get loginFailed => 'Échec de la connexion';

  @override
  String get profile => 'Profil';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get fullName => 'Nom complet';

  @override
  String get avatarUrl => 'URL de l\'avatar';

  @override
  String get saveChanges => 'Sauvegarder les modifications';

  @override
  String get oldPassword => 'Ancien mot de passe';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get failedToLoadProfile => 'Échec du chargement du profil';

  @override
  String get updateFailed => 'Mise à jour échouée';

  @override
  String get profileUpdatedSuccessfully => 'Profil mis à jour avec succès';

  @override
  String get passwordChangeFailed => 'Échec du changement de mot de passe';

  @override
  String get passwordChangedSuccessfully => 'Mot de passe changé avec succès';

  @override
  String get somethingWentWrong =>
      'Quelque chose s\'est mal passé, veuillez réessayer';

  @override
  String get safeRides => 'Des trajets sûrs pour vos petits';

  @override
  String get imParentDesc =>
      'Suivez le bus de votre enfant, communiquez avec les chauffeurs et gérez les ramassages';

  @override
  String get imDriverDesc =>
      'Gérez votre itinéraire, informez les parents et assurez des trajets sûrs';

  @override
  String joinParents(Object count) {
    return 'Rejoignez $count+ parents';
  }

  @override
  String get trustedDrivers => 'Réseau de chauffeurs de confiance';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get dontHaveAccount => 'Vous n\'avez pas de compte ?';

  @override
  String get contactAdmin => 'Contacter l\'administrateur';

  @override
  String get trackSafely => 'Suivez votre enfant en toute sécurité';

  @override
  String get phoneRequired => 'Le numéro de téléphone est requis';

  @override
  String get passwordRequired => 'Le mot de passe est requis';

  @override
  String get termsOfService => 'Conditions d\'utilisation';

  @override
  String get byContinuing => 'En continuant, vous acceptez nos';

  @override
  String get language => 'Langue';

  @override
  String childrenCount(Object count) {
    return '$count Enfants enregistrés';
  }

  @override
  String get updateYourInfo => 'Mettez à jour vos informations';

  @override
  String get updatePassword => 'Mettez à jour votre mot de passe';

  @override
  String get notifications => 'Notifications';

  @override
  String get manageNotifications => 'Gérer les notifications';

  @override
  String get privacySecurity => 'Confidentialité et sécurité';

  @override
  String get controlYourData => 'Contrôlez vos données';

  @override
  String get helpSupport => 'Aide et support';

  @override
  String get getHelp => 'Obtenir de l\'aide';

  @override
  String get readOnlyFields => 'Ces champs ne peuvent pas être modifiés';

  @override
  String get phone => 'Téléphone';

  @override
  String get role => 'Rôle';

  @override
  String get noAddressProvided => 'Aucune adresse fournie';

  @override
  String get tapToViewClearly => 'Appuyez pour voir plus clair';

  @override
  String get avatarUrlOptional => 'URL de l\'avatar (facultatif)';

  @override
  String get children => 'Enfants';

  @override
  String get myChildren => 'Mes Enfants';

  @override
  String get noChildrenFound => 'Aucun enfant trouvé';

  @override
  String get noChildrenDescription =>
      'Vous n\'avez pas encore ajouté d\'enfants';

  @override
  String get grade => 'Niveau';

  @override
  String get classroom => 'Salle de classe';

  @override
  String get status => 'Statut';

  @override
  String get active => 'Actif';

  @override
  String get inactive => 'Inactif';

  @override
  String get failedToLoadChildren => 'Échec du chargement des enfants';

  @override
  String get payments => 'Paiements';

  @override
  String get payment => 'Paiement';

  @override
  String get paymentsRetrievedSuccessfully => 'Paiements récupérés avec succès';

  @override
  String get paymentRetrievedSuccessfully => 'Paiement récupéré avec succès';

  @override
  String get paymentCreatedSuccessfully => 'Paiement créé avec succès';

  @override
  String get amount => 'Montant';

  @override
  String get date => 'Date';

  @override
  String get receiptImage => 'Image du reçu';

  @override
  String get noPaymentsFound => 'Aucun paiement trouvé';

  @override
  String get failedToLoadPayments => 'Échec du chargement des paiements';

  @override
  String get createPayment => 'Créer un paiement';

  @override
  String get paymentStatusPending => 'En attente';

  @override
  String get paymentStatusCompleted => 'Terminé';

  @override
  String get paymentStatusRejected => 'Rejeté';

  @override
  String get plan => 'Plan';

  @override
  String get home => 'Accueil';

  @override
  String get track => 'Suivre';

  @override
  String get alerts => 'Alertes';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get liveRides => 'Trajets en direct';

  @override
  String get viewSchedule => 'Voir l\'horaire';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get upcoming => 'À venir';

  @override
  String get history => 'Historique';

  @override
  String get liveNow => 'EN DIRECT';

  @override
  String get trackLive => 'Suivre en direct';

  @override
  String get scheduled => 'Programmé';

  @override
  String get completed => 'Terminé';

  @override
  String get cancelled => 'Annulé';

  @override
  String get driver => 'Chauffeur';

  @override
  String get eta => 'Heure d\'arrivée estimée';

  @override
  String get noRidesToday => 'Aucun trajet aujourd\'hui';

  @override
  String get noRidesTodayDesc =>
      'Il n\'y a pas de trajets programmés pour aujourd\'hui.';

  @override
  String get noUpcomingRides => 'Aucun trajet à venir';

  @override
  String get noUpcomingRidesDesc =>
      'Il n\'y a pas de trajets programmés à venir.';

  @override
  String get noRideHistory => 'Aucun historique de trajet';

  @override
  String get noRideHistoryDesc => 'Aucun trajet passé trouvé.';

  @override
  String get scheduledRides => 'Trajets programmés';

  @override
  String get morningTrip => 'Trajet du matin';

  @override
  String get returnTrip => 'Trajet de retour';

  @override
  String get homeToSchool => 'Maison → École';

  @override
  String get schoolToHome => 'École → Maison';

  @override
  String get errorLoadingRides => 'Erreur lors du chargement des trajets';

  @override
  String get noChildrenFoundRides => 'Aucun enfant trouvé';

  @override
  String get addChildrenToTrack =>
      'Ajoutez vos enfants pour commencer à suivre leurs trajets.';

  @override
  String get appServices => 'Services de l\'application';

  @override
  String get schoolServices => 'Services scolaires';

  @override
  String get appSubscriptionsTitle => 'Abonnements de l\'application';

  @override
  String get noAppSubscriptions =>
      'Vous n\'avez pas encore d\'abonnements à l\'application.';

  @override
  String get browseParentPlans =>
      'Consultez les plans ci-dessous pour commencer.';

  @override
  String get parentPlansTitle => 'Plans parents';

  @override
  String get subscribeAppPlan => 'Souscrire au plan de l\'application';

  @override
  String get subscribeSchoolPlan => 'Souscrire au plan scolaire';

  @override
  String get activeServices => 'Services actifs';

  @override
  String get availableServices => 'Services disponibles';

  @override
  String get schoolSubscribedServices => 'Services scolaires souscrits';

  @override
  String get availableSchoolServices => 'Services scolaires disponibles';

  @override
  String get filterByChild => 'Filtrer par enfant';

  @override
  String get noSchoolSubscriptions =>
      'You have no school service subscriptions yet.';

  @override
  String get browseSchoolServices =>
      'Browse the available school services below.';

  @override
  String get noServicesAvailable => 'Aucun service disponible';

  @override
  String get checkBackLater => 'Revenez plus tard pour de nouveaux services.';

  @override
  String get noSchoolServices => 'Aucun service scolaire';

  @override
  String get noServicesForChild => 'Aucun service disponible pour cet enfant.';

  @override
  String get price => 'Prix';

  @override
  String get servicePlan => 'Plan de Service';

  @override
  String get schoolService => 'Service Scolaire';

  @override
  String get selectPaymentMethod => 'Sélectionner la méthode de paiement';

  @override
  String get uploadReceipt => 'Télécharger le reçu';

  @override
  String get tapToChooseReceipt => 'Appuyez pour choisir le reçu';

  @override
  String get subscribeNow => 'S\'abonner maintenant';

  @override
  String get noActiveSubscriptions => 'Aucun service scolaire actif';

  @override
  String get choosePlanToSubscribe =>
      'Veuillez choisir un service pour vous abonner';

  @override
  String get chooseServiceToSubscribe =>
      'Veuillez choisir un service pour vous abonner';

  @override
  String get student => 'Étudiant';

  @override
  String get all => 'All';

  @override
  String get subscriptionFees => 'Service Fees';

  @override
  String get minPayment => 'Min. Payment';

  @override
  String get liveTracking => 'Suivi en direct';

  @override
  String get timelineTracking => 'Chronologie';

  @override
  String get morningRide => 'Trajet du matin';

  @override
  String get afternoonRide => 'Trajet de l\'après-midi';

  @override
  String get reportAbsence => 'Signaler une absence';

  @override
  String get reportAbsenceDescription =>
      'Veuillez fournir une raison pour l\'absence.';

  @override
  String get rideAlreadyStartedError =>
      'Impossible de signaler une absence pour un trajet déjà commencé';

  @override
  String get reason => 'Raison';

  @override
  String get enterReasonHint => 'Entrez la raison de l\'absence...';

  @override
  String get cancel => 'Annuler';

  @override
  String get submit => 'Soumettre';

  @override
  String get rideSummary => 'Résumé du trajet';

  @override
  String get totalScheduled => 'Total programmé';

  @override
  String get attended => 'Présent';

  @override
  String get absent => 'Absent';

  @override
  String get lateLabel => 'En retard';

  @override
  String get attendanceRate => 'Taux de présence';

  @override
  String get close => 'Fermer';

  @override
  String get paymentType => 'Type de paiement';

  @override
  String get paymentMethod => 'Méthode de paiement';

  @override
  String get oneTimePayment => 'Paiement unique';

  @override
  String get installmentPayment => 'Paiement échelonné';

  @override
  String get numberOfInstallments => 'Nombre d\'acomptes';

  @override
  String get perInstallmentAmount => 'Par acompte';

  @override
  String get remainingAmount => 'Montant restant';

  @override
  String get currency => 'EGP';

  @override
  String get installmentsRequired => 'Le nombre d\'acomptes est requis';

  @override
  String get installmentsMustBePositive =>
      'Le nombre d\'acomptes doit être un nombre positif';

  @override
  String get selectFromGallery => 'Sélectionner dans la galerie';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String imageSizeError(String maxSize, String actualSize) {
    return 'La taille de l\'image dépasse $maxSize Mo. L\'image sélectionnée est $actualSize.';
  }

  @override
  String get imagePickerError =>
      'Échec de la sélection de l\'image. Veuillez réessayer.';

  @override
  String get changeImage => 'Changer l\'image';

  @override
  String get planPayments => 'Paiements de plan';

  @override
  String get servicePayments => 'Paiements de service';

  @override
  String get retry => 'Réessayer';

  @override
  String get noPlanPayments => 'Aucun paiement de plan';

  @override
  String get noPlanPaymentsDesc =>
      'Vous n\'avez pas encore effectué de paiements de plan.';

  @override
  String get noServicePayments => 'Aucun paiement de service';

  @override
  String get noServicePaymentsDesc =>
      'Vous n\'avez pas encore effectué de paiements de service.';

  @override
  String get paymentHistory => 'Historique des paiements';

  @override
  String get createPlanPayment => 'Créer un paiement de plan';

  @override
  String get createServicePayment => 'Créer un paiement de service';

  @override
  String get totalAmount => 'Montant total';

  @override
  String get notes => 'Notes';

  @override
  String get upcomingNotices => 'Upcoming Notices';

  @override
  String get upcomingNoticesSubtitle => 'Stay informed about school events.';

  @override
  String get noUpcomingNotices => 'No Upcoming Notices';

  @override
  String get noUpcomingNoticesDesc =>
      'There are no events or holidays in the next few days.';

  @override
  String get noticeTypeHoliday => 'Holiday';

  @override
  String get noticeTypeEvent => 'Event';

  @override
  String get noticeTypeOther => 'Notice';

  @override
  String get ridesAffected => 'Rides affected';

  @override
  String get ridesNotAffected => 'Rides not affected';

  @override
  String inDays(int days) {
    return 'in $days days';
  }

  @override
  String get rejectionReason => 'Motif de rejet';

  @override
  String get service => 'Service';

  @override
  String get planRequired => 'Le plan est requis';

  @override
  String get serviceRequired => 'Le service est requis';

  @override
  String get studentRequired => 'L\'étudiant est requis';

  @override
  String get paymentMethodRequired => 'Le mode de paiement est requis';

  @override
  String get amountRequired => 'Le montant est requis';

  @override
  String get amountMustBePositive => 'Le montant doit être supérieur à zéro';

  @override
  String get receiptRequired => 'L\'image du reçu est requise';

  @override
  String get optional => 'Optionnel';
}
