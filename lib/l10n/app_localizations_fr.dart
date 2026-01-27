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
  String get parentLogin => 'Connexion Parent';

  @override
  String get driverLogin => 'Connexion Chauffeur';

  @override
  String get enterCredentials =>
      'Entrez vos identifiants pour accéder à votre compte';

  @override
  String get phoneNumber => 'Numéro de téléphone';

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
  String get payments => 'Payments';

  @override
  String get payment => 'Payment';

  @override
  String get paymentsRetrievedSuccessfully => 'Payments retrieved successfully';

  @override
  String get paymentRetrievedSuccessfully => 'Payment retrieved successfully';

  @override
  String get paymentCreatedSuccessfully => 'Payment created successfully';

  @override
  String get amount => 'Amount';

  @override
  String get date => 'Date';

  @override
  String get receiptImage => 'Receipt Image';

  @override
  String get noPaymentsFound => 'No payments found';

  @override
  String get failedToLoadPayments => 'Failed to load payments';

  @override
  String get createPayment => 'Create Payment';

  @override
  String get plan => 'Plan';
}
