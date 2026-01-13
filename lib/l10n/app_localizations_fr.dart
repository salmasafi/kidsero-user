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
}
