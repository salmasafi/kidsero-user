import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../main.dart';

class L10nUtils {
  static String translate(BuildContext context, String? message) {
    if (message == null || message.isEmpty) return '';
    
    final l10n = AppLocalizations.of(context)!;
    
    switch (message) {
      case 'loginFailed':
        return l10n.loginFailed;
      case 'loginSuccessful':
        return l10n.loginSuccessful;
      case 'failedToLoadProfile':
        return l10n.failedToLoadProfile;
      case 'updateFailed':
        return l10n.updateFailed;
      case 'profileUpdatedSuccessfully':
        return l10n.profileUpdatedSuccessfully;
      case 'passwordChangeFailed':
        return l10n.passwordChangeFailed;
      case 'passwordChangedSuccessfully':
        return l10n.passwordChangedSuccessfully;
      case 'somethingWentWrong':
        return l10n.somethingWentWrong;
      default:
        return message;
    }
  }

  static String translateWithGlobalContext(String? message) {
    if (navigatorKey.currentContext == null) return message ?? '';
    return translate(navigatorKey.currentContext!, message);
  }
}
