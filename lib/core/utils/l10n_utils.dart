import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kidsero_parent/l10n/app_localizations.dart';
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

  /// Translate ride status to localized string
  static String translateRideStatus(BuildContext context, String status) {
    final l10n = AppLocalizations.of(context)!;
    
    switch (status.toLowerCase()) {
      case 'scheduled':
        return l10n.scheduled;
      case 'in_progress':
      case 'inprogress':
        return l10n.inProgress;
      case 'completed':
        return l10n.completed;
      case 'pending':
        return l10n.pending;
      case 'absent':
        return l10n.absent;
      case 'excused':
        return l10n.excused;
      case 'cancelled':
        return l10n.cancelled;
      default:
        return status;
    }
  }

  /// Format date according to locale
  /// Returns format like "Jan 15, 2024" for English or "15 يناير 2024" for Arabic
  static String formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat.yMMMd(locale.toString());
    return dateFormat.format(date);
  }

  /// Format date from ISO string according to locale
  static String formatDateFromString(BuildContext context, String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return formatDate(context, date);
    } catch (e) {
      return dateStr;
    }
  }

  /// Format time according to locale
  /// Returns format like "2:30 PM" for English or "14:30" for Arabic
  static String formatTime(BuildContext context, DateTime time) {
    final locale = Localizations.localeOf(context);
    final timeFormat = DateFormat.jm(locale.toString());
    return timeFormat.format(time);
  }

  /// Format time from ISO string according to locale
  static String formatTimeFromString(BuildContext context, String timeStr) {
    try {
      final time = DateTime.parse(timeStr);
      return formatTime(context, time);
    } catch (e) {
      return timeStr;
    }
  }

  /// Format date and time according to locale
  /// Returns format like "Jan 15, 2024 at 2:30 PM"
  static String formatDateTime(BuildContext context, DateTime dateTime) {
    final locale = Localizations.localeOf(context);
    final dateTimeFormat = DateFormat.yMMMd(locale.toString()).add_jm();
    return dateTimeFormat.format(dateTime);
  }

  /// Format date and time from ISO string according to locale
  static String formatDateTimeFromString(BuildContext context, String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return formatDateTime(context, dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  /// Format day of week according to locale
  /// Returns format like "Monday" for English or "الاثنين" for Arabic
  static String formatDayOfWeek(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context);
    final dayFormat = DateFormat.EEEE(locale.toString());
    return dayFormat.format(date);
  }

  /// Check if current locale is RTL (Right-to-Left)
  static bool isRTL(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar';
  }
}
