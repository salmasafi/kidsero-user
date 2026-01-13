// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get welcome => 'Willkommen bei Kidsero';

  @override
  String get selectRole => 'Bitte wählen Sie Ihre Rolle aus, um fortzufahren';

  @override
  String get imParent => 'Ich bin ein Elternteil';

  @override
  String get imDriver => 'Ich bin ein Fahrer';

  @override
  String get parentLogin => 'Eltern-Login';

  @override
  String get driverLogin => 'Fahrer-Login';

  @override
  String get enterCredentials =>
      'Geben Sie Ihre Zugangsdaten ein, um auf Ihr Konto zuzugreifen';

  @override
  String get phoneNumber => 'Telefonnummer';

  @override
  String get password => 'Passwort';

  @override
  String get login => 'Anmelden';

  @override
  String get loginSuccessful => 'Anmeldung erfolgreich';

  @override
  String get loginFailed => 'Anmeldung fehlgeschlagen';

  @override
  String get profile => 'Profil';

  @override
  String get editProfile => 'Profil bearbeiten';

  @override
  String get changePassword => 'Passwort ändern';

  @override
  String get logout => 'Abmelden';

  @override
  String get fullName => 'Vollständiger Name';

  @override
  String get avatarUrl => 'Avatar-URL';

  @override
  String get saveChanges => 'Änderungen speichern';

  @override
  String get oldPassword => 'Altes Passwort';

  @override
  String get newPassword => 'Neues Passwort';

  @override
  String get failedToLoadProfile => 'Profil konnte nicht geladen werden';

  @override
  String get updateFailed => 'Aktualisierung fehlgeschlagen';

  @override
  String get profileUpdatedSuccessfully => 'Profil erfolgreich aktualisiert';

  @override
  String get passwordChangeFailed => 'Passwortänderung fehlgeschlagen';

  @override
  String get passwordChangedSuccessfully => 'Passwort erfolgreich geändert';

  @override
  String get somethingWentWrong =>
      'Etwas ist schief gelaufen, bitte versuchen Sie es erneut';
}
