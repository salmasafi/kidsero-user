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

  @override
  String get safeRides => 'Sichere Fahrten für Ihre Kleinen';

  @override
  String get imParentDesc =>
      'Verfolgen Sie den Bus Ihres Kindes, kommunizieren Sie mit Fahrern und verwalten Sie Abholungen';

  @override
  String get imDriverDesc =>
      'Verwalten Sie Ihre Route, informieren Sie die Eltern und sorgen Sie für sichere Fahrten';

  @override
  String joinParents(Object count) {
    return 'Tritt $count+ Eltern bei';
  }

  @override
  String get trustedDrivers => 'Netzwerk vertrauenswürdiger Fahrer';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get dontHaveAccount => 'Sie haben noch kein Konto?';

  @override
  String get contactAdmin => 'Admin kontaktieren';

  @override
  String get trackSafely => 'Verfolgen Sie Ihr Kind sicher';

  @override
  String get phoneRequired => 'Telefonnummer ist erforderlich';

  @override
  String get passwordRequired => 'Passwort ist erforderlich';

  @override
  String get termsOfService => 'Nutzungsbedingungen';

  @override
  String get byContinuing => 'Indem Sie fortfahren, stimmen Sie unseren zu';

  @override
  String get language => 'Sprache';

  @override
  String childrenCount(Object count) {
    return '$count Registrierte Kinder';
  }

  @override
  String get updateYourInfo => 'Aktualisieren Sie Ihre Informationen';

  @override
  String get updatePassword => 'Aktualisieren Sie Ihr Passwort';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get manageNotifications => 'Benachrichtigungen verwalten';

  @override
  String get privacySecurity => 'Privatsphäre & Sicherheit';

  @override
  String get controlYourData => 'Kontrollieren Sie Ihre Daten';

  @override
  String get helpSupport => 'Hilfe & Support';

  @override
  String get getHelp => 'Hilfe erhalten';

  @override
  String get readOnlyFields => 'Diese Felder können nicht geändert werden';

  @override
  String get phone => 'Telefon';

  @override
  String get role => 'Rolle';

  @override
  String get noAddressProvided => 'Keine Adresse angegeben';

  @override
  String get tapToViewClearly => 'Tippen Sie zur deutlichen Ansicht';

  @override
  String get avatarUrlOptional => 'Avatar-URL (Optional)';

  @override
  String get children => 'Kinder';

  @override
  String get myChildren => 'Meine Kinder';

  @override
  String get noChildrenFound => 'Keine Kinder gefunden';

  @override
  String get noChildrenDescription => 'Sie haben noch keine Kinder hinzugefügt';

  @override
  String get grade => 'Klasse';

  @override
  String get classroom => 'Klassenzimmer';

  @override
  String get status => 'Status';

  @override
  String get active => 'Aktiv';

  @override
  String get inactive => 'Inaktiv';

  @override
  String get failedToLoadChildren => 'Fehler beim Laden der Kinder';

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
