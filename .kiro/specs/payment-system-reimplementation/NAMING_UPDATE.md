# Payment System Naming Update

## Overview

Updated the payment system terminology to match the correct naming convention.

## Naming Changes

### Tab Names
| Old Name | New Name |
|----------|----------|
| App Services | **Parent Plans** |
| School Services | **Subscriptions** |

### Detail Labels
| Old Name | New Name |
|----------|----------|
| Service Plan | **Parent Plan** |
| School Service | **Subscription** |

## Updated Localizations

### English (en)
- `appServices`: "App Services" → **"Parent Plans"**
- `schoolServices`: "School Services" → **"Subscriptions"**
- `servicePlan`: "Service Plan" → **"Parent Plan"**
- `schoolService`: "School Service" → **"Subscription"**
- `noSchoolServices`: "No School Services" → **"No Subscriptions"**

### Arabic (ar)
- `appServices`: "خدمات التطبيق" → **"خطط الوالدين"**
- `schoolServices`: "خدمات المدرسة" → **"الاشتراكات"**
- `servicePlan`: "خطة الخدمة" → **"خطة الوالدين"**
- `schoolService`: "خدمة مدرسية" → **"اشتراك"**
- `noSchoolServices`: "لا توجد خدمات مدرسية" → **"لا توجد اشتراكات"**

### French (fr)
- `appServices`: "Services de l'application" → **"Plans Parentaux"**
- `schoolServices`: "Services scolaires" → **"Abonnements"**
- `servicePlan`: "Plan de service" → **"Plan Parental"**
- `schoolService`: "Service scolaire" → **"Abonnement"**
- `noSchoolServices`: "Aucun service scolaire" → **"Aucun abonnement"**

### German (de)
- `appServices`: "App-Dienste" → **"Elternpläne"**
- `schoolServices`: "Schuldienste" → **"Abonnements"**
- `servicePlan`: "Serviceplan" → **"Elternplan"**
- `schoolService`: "Schuldienst" → **"Abonnement"**
- `noSchoolServices`: "Keine Schuldienste" → **"Keine Abonnements"**

## Files Updated

1. `lib/l10n/app_en.arb` - English localization
2. `lib/l10n/app_ar.arb` - Arabic localization
3. `lib/l10n/app_fr.arb` - French localization
4. `lib/l10n/app_de.arb` - German localization

## UI Impact

### Payments Screen
The two tabs now display as:
- **Parent Plans** (left tab)
- **Subscriptions** (right tab)

### Payment Detail Screens
When viewing payment details:
- Plan payments show as "Parent Plan"
- Service payments show as "Subscription"

### Empty States
- "No Subscriptions" instead of "No School Services"

## Testing

After rebuilding the app, verify:
1. ✅ Payments screen shows "Parent Plans" and "Subscriptions" tabs
2. ✅ Payment detail screens use correct labels
3. ✅ Empty states show correct messages
4. ✅ All languages display correctly

## Note

The localization files (`.arb`) have been updated. The generated Dart files (`app_localizations_*.dart`) will be automatically regenerated when you run:
```bash
flutter gen-l10n
```

Or when you build the app:
```bash
flutter build
```

The changes will take effect after the next build.
